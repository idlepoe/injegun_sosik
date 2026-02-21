import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/dashboard_slider.dart';
import 'dashboard_style.dart';

/// 대시보드 상단 배너 슬라이더 (dashboardSliders 컬렉션 최신 1건의 items 표시)
class DashboardSliderBanner extends StatelessWidget {
  const DashboardSliderBanner({super.key});

  static const double _height = 168;
  static const double _dotSize = 6;
  static const double _dotSpacing = 6;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('dashboardSliders')
          .orderBy('updatedAt', descending: true)
          .limit(1)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox.shrink();
        }
        final doc = snapshot.data!.docs.first;
        final data = doc.data();
        final itemsRaw = data['items'] as List<dynamic>? ?? [];
        final items = itemsRaw
            .map((e) => DashboardSliderItem.fromMap(e as Map<String, dynamic>))
            .toList();
        if (items.isEmpty) return const SizedBox.shrink();

        return _SliderContent(items: items);
      },
    );
  }
}

class _SliderContent extends StatefulWidget {
  const _SliderContent({required this.items});

  final List<DashboardSliderItem> items;

  @override
  State<_SliderContent> createState() => _SliderContentState();
}

class _SliderContentState extends State<_SliderContent> {
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final items = widget.items;
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CarouselSlider(
          items: items
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _BannerTile(item: item),
                ),
              )
              .toList(),
          options: CarouselOptions(
            height: DashboardSliderBanner._height,
            viewportFraction: 1.0,
            enlargeCenterPage: false,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 5),
            autoPlayAnimationDuration: const Duration(milliseconds: 400),
            onPageChanged: (index, reason) {
              if (mounted) setState(() => _currentPage = index);
            },
          ),
        ),
        if (items.length > 1) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              items.length,
              (i) => Container(
                margin: const EdgeInsets.symmetric(horizontal: DashboardSliderBanner._dotSpacing / 2),
                width: DashboardSliderBanner._dotSize,
                height: DashboardSliderBanner._dotSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentPage == i ? tossBlue : Colors.grey.shade300,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ] else
          const SizedBox(height: 12),
      ],
    );
  }
}

class _BannerTile extends StatelessWidget {
  const _BannerTile({required this.item});

  final DashboardSliderItem item;

  @override
  Widget build(BuildContext context) {
    final url = item.imageUrl;
    final linkUrl = item.linkUrl;

    Widget content = ClipRRect(
      borderRadius: BorderRadius.circular(tossCardRadius),
      child: url.isEmpty
          ? Container(
              color: Colors.grey.shade200,
              child: Center(
                child: Text(
                  item.title,
                  style: TextStyle(color: tossGreyText, fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              placeholder: (_, __) => Container(
                color: Colors.grey.shade200,
                child: const Center(child: CircularProgressIndicator(color: tossBlue)),
              ),
              errorWidget: (_, __, e) => Container(
                color: Colors.grey.shade200,
                child: Center(
                  child: Text(
                    item.title,
                    style: TextStyle(color: tossGreyText, fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
    );

    if (linkUrl != null && linkUrl.isNotEmpty) {
      content = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () async {
          final uri = Uri.tryParse(linkUrl);
          if (uri == null) return;
          try {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } catch (_) {}
        },
        child: content,
      );
    }

    return content;
  }
}
