import * as logger from "firebase-functions/logger";

/**
 * Check if image URL is a dynamic transformation URL
 */
export function isDynamicImageUrl(imageUrl: string): boolean {
  if (!imageUrl.includes("?")) {
    return false;
  }

  const url = new URL(imageUrl);
  return (
    url.searchParams.has("w") ||
    url.searchParams.has("h") ||
    url.searchParams.has("p") ||
    url.searchParams.has("q") ||
    url.searchParams.has("fit")
  );
}

/**
 * Pre-fetch image URL to warm up CDN edge cache
 * @returns true if warm-up succeeded, false otherwise
 */
export async function warmUpImageCache(imageUrl: string): Promise<boolean> {
  if (!imageUrl || !imageUrl.trim()) {
    return false;
  }

  const isDynamic = isDynamicImageUrl(imageUrl);

  try {
    const headers: Record<string, string> = {
      "User-Agent": "Mozilla/5.0 (compatible; FirebaseCloudFunctions/1.0)",
    };

    // Only use Range header for non-dynamic URLs
    if (!isDynamic) {
      headers["Range"] = "bytes=0-1024";
    }

    const response = await fetch(imageUrl, {
      method: "GET",
      headers,
      signal: AbortSignal.timeout(5000),
    });

    // Consume and discard response body (only warm up the cache)
    if (response.ok || response.status === 206) {
      if (response.body) {
        const reader = response.body.getReader();
        await reader.cancel();
      }
      logger.info("Image cache warmed up successfully", { imageUrl });
      return true;
    } else {
      logger.warn("Image cache warm-up returned non-ok status", {
        status: response.status,
        imageUrl,
      });
      return false;
    }
  } catch (error: unknown) {
    const msg = error instanceof Error ? error.message : String(error);
    logger.warn("Image cache warm-up failed (non-blocking)", { imageUrl, message: msg });
    return false;
  }
}
