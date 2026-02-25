import { getFirestore, Timestamp } from "firebase-admin/firestore";
import { getMessaging } from "firebase-admin/messaging";
import * as logger from "firebase-functions/logger";
import { warmUpImageCache } from "./utils/warmUpImageCache.js";

const ARTICLE_TYPES = ["weekschedule", "notice", "job", "livelihood", "free"] as const;
type ArticleType = (typeof ARTICLE_TYPES)[number];

const TYPE_LABELS: Record<ArticleType, string> = {
  weekschedule: "행사소식",
  notice: "공지사항",
  job: "구인구직",
  livelihood: "생활장터",
  free: "자유게시판",
};

/** Firestore article document shape (필요 필드만) */
interface ArticleDoc {
  type: string;
  title: string;
  url?: string;
  articleSeq: string;
  content?: string;
  attachments?: Array< { attachmentUrl: string; attachmentName: string } >;
  updatedAt?: unknown;
}

const MAX_CONTENT_LENGTH = 150;

/**
 * HTML 태그 제거 후 150자 이내로 자른 본문
 */
function stripHtmlAndTruncate(html: string | undefined, maxLen: number = MAX_CONTENT_LENGTH): string {
  if (!html || !html.trim()) return "";
  const stripped = html.replace(/<[^>]*>/g, " ").replace(/\s+/g, " ").trim();
  if (stripped.length <= maxLen) return stripped;
  return stripped.slice(0, maxLen);
}

const IMAGE_EXTENSIONS = [".jpg", ".jpeg", ".png", ".gif", ".webp"];

function isImageAttachment(attachmentName: string): boolean {
  const lower = attachmentName.toLowerCase();
  return IMAGE_EXTENSIONS.some((ext) => lower.endsWith(ext));
}

/**
 * Get first image URL from article attachments (사진인 경우만)
 */
function getFirstImageUrl(article: ArticleDoc): string {
  const attachments = article.attachments ?? [];
  const first = attachments.find((a) => isImageAttachment(a.attachmentName ?? ""));
  return first?.attachmentUrl ?? "";
}

/**
 * Query articles updated in the last hour for a given type
 */
async function getArticlesUpdatedInLastHour(
  type: ArticleType
): Promise<ArticleDoc[]> {
  const db = getFirestore();
  const oneHourAgo = Timestamp.fromMillis(Date.now() - 60 * 60 * 1000);
  const snapshot = await db
    .collection("articles")
    .where("type", "==", type)
    .where("updatedAt", ">=", oneHourAgo)
    .orderBy("updatedAt", "desc")
    .get();

  return snapshot.docs.map((doc) => ({ ...doc.data(), articleSeq: doc.id })) as ArticleDoc[];
}

/**
 * Send FCM topic push for one article type (1시간 이내 업데이트된 글이 있을 때만)
 */
async function sendPushForType(type: ArticleType): Promise<void> {
  const articles = await getArticlesUpdatedInLastHour(type);
  if (articles.length === 0) return;

  const latest = articles[0];
  const imageUrl = getFirstImageUrl(latest);
  let isValidImage = false;
  if (imageUrl) {
    isValidImage = await warmUpImageCache(imageUrl);
    if (isValidImage) {
      await new Promise((resolve) => setTimeout(resolve, 1500));
    } else {
      logger.warn("Article push: image URL excluded (warm-up failed)", {
        type,
        articleSeq: latest.articleSeq,
        imageUrl,
      });
    }
  }

  const topic = type;
  const topicLabel = TYPE_LABELS[type];
  const articleTitle = latest.title ?? "";
  const notificationTitle =
    articles.length > 1
      ? `(${topicLabel}) ${articleTitle} 외 ${articles.length}건`
      : `(${topicLabel}) ${articleTitle}`;
  const contentExcerpt = stripHtmlAndTruncate(latest.content);
  const body = contentExcerpt || articleTitle || "새 글이 올라왔습니다.";
  const detailUrl = latest.url ?? "";

  const dataFields: Record<string, string> = {
    type: "new_article",
    articleType: type,
    count: String(articles.length),
    articleSeq: latest.articleSeq,
    title: latest.title ?? "",
    url: detailUrl,
    imageUrl: imageUrl ?? "",
    content: body,
  };

  const message: Record<string, unknown> = {
    topic,
    notification: {
      title: notificationTitle,
      body,
    },
    data: dataFields,
    android: {
      notification: {
        icon: "push_icon",
        sound: "default",
        channelId: "high_importance_channel",
      },
    },
  };

  if (imageUrl && isValidImage) {
    (message.notification as Record<string, string>).image = imageUrl;
    ((message.android as Record<string, unknown>).notification as Record<string, string>).imageUrl = imageUrl;
    message.apns = {
      payload: {
        aps: {
          "mutable-content": 1,
        },
      },
      fcm_options: {
        image: imageUrl,
      },
    };
  }

  const messaging = getMessaging();
  const response = await messaging.send(message as unknown as import("firebase-admin/messaging").Message);
  logger.info("Article topic push sent", {
    topic,
    articleSeq: latest.articleSeq,
    count: articles.length,
    response,
    notification: { title: notificationTitle, body },
    data: dataFields,
    imageUrl: imageUrl || undefined,
  });
}

/**
 * For each article type, query articles with updatedAt in the last hour and send one FCM topic push per type.
 * Push failures are logged but do not throw (fetch success is preserved).
 */
export async function sendPushForArticlesUpdatedInLastHour(): Promise<void> {
  for (const type of ARTICLE_TYPES) {
    try {
      await sendPushForType(type);
    } catch (err) {
      const msg = err instanceof Error ? err.message : String(err);
      logger.error("Article topic push failed", { type, error: msg });
      // Do not rethrow: keep fetch success independent of push
    }
  }
}
