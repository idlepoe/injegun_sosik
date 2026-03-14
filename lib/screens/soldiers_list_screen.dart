import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:platform_maps_flutter/platform_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/soldier.dart';
import '../repository/soldier_repository.dart';
import '../utils/map_launcher.dart';
import '../widgets/dashboard_style.dart';

/// 군장병우대업소(상품권환급) 화면 — Firestore soldiers 컬렉션 표시
class SoldiersListScreen extends StatefulWidget {
  const SoldiersListScreen({super.key, required this.repository});

  final SoldierRepository repository;

  @override
  State<SoldiersListScreen> createState() => _SoldiersListScreenState();
}

class _SoldiersListScreenState extends State<SoldiersListScreen> {
  static const String _infoUrl =
      'https://www.inje.go.kr/portal/inje-news/soldier/givePreference';

  List<Soldier> _all = [];
  bool _loading = true;
  String _selectedCategory = SoldierCategory.restaurant;
  Position? _userPosition;
  bool _sortByDistance = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final list = await widget.repository.getAll();
      if (mounted) {
        setState(() {
          _all = list;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  List<Soldier> get _filtered {
    var list = _all.where((s) => s.category == _selectedCategory).toList();
    if (_sortByDistance && _userPosition != null) {
      final pos = _userPosition!;
      list = list.where((s) => s.lat != null && s.lng != null).toList();
      list = List.from(list)
        ..sort((a, b) {
          final da = _distanceKm(pos.latitude, pos.longitude, a.lat!, a.lng!);
          final db = _distanceKm(pos.latitude, pos.longitude, b.lat!, b.lng!);
          return da.compareTo(db);
        });
    }
    return list;
  }

  double _distanceKm(double lat1, double lon1, double lat2, double lon2) {
    const p = math.pi / 180;
    final a =
        0.5 -
        math.cos((lat2 - lat1) * p) / 2 +
        math.cos(lat1 * p) *
            math.cos(lat2 * p) *
            (1 - math.cos((lon2 - lon1) * p)) /
            2;
    return 12742 * math.asin(math.sqrt(a)); // 2 * R; R = 6371 km
  }

  double? _distanceFor(Soldier s) {
    if (_userPosition == null || s.lat == null || s.lng == null) return null;
    return _distanceKm(
      _userPosition!.latitude,
      _userPosition!.longitude,
      s.lat!,
      s.lng!,
    );
  }

  Future<void> _showInfoDialog() async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          '환급대상 : 군사병에 한함 *부사관 등 간부급 제외',
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _bullet('휴가증, 외출·외박증 등 지참'),
              _bullet('나라사랑카드 결제시에만 환급 가능'),
              _bullet('군사병 1명 최대 5만원까지 환급 가능'),
              _bullet('결제금액별 환급 시행'),
              _bullet(
                '2026.4.1.부터 인제채워드림카드 인센티브로 환급 시행\n'
                '(군 장병 인제채워드림카드 소지 및 "그리고"어플 등록 必)',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              final uri = Uri.parse(_infoUrl);
              try {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              } catch (_) {}
            },
            child: const Text('원본 페이지 보기'),
          ),
        ],
      ),
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '* ',
            style: TextStyle(color: tossBlue, fontWeight: FontWeight.w500),
          ),
          Expanded(
            child: Text(text, style: TextStyle(color: tossBlue, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Future<void> _tapNearbySort() async {
    final result = await _getUserLocation();
    if (!mounted) return;
    switch (result) {
      case _LocationAccessResult.deniedForever:
        await _showLocationDialog('위치 권한이 항상 거부되어 있습니다. 설정에서 위치 권한을 허용해 주세요.');
        break;
      case _LocationAccessResult.denied:
      case _LocationAccessResult.serviceDisabled:
      case _LocationAccessResult.error:
        await _showLocationDialog(
          '위치 정보를 가져오는데 실패했습니다. 설정에서 위치 권한과 서비스를 확인해 주세요.',
        );
        break;
      case _LocationAccessResult.success:
        setState(() {
          _sortByDistance = true;
          _userPosition = userPosition;
        });
        break;
    }
  }

  Position? userPosition;

  Future<_LocationAccessResult> _getUserLocation() async {
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        return _LocationAccessResult.denied;
      }
      if (permission == LocationPermission.deniedForever) {
        return _LocationAccessResult.deniedForever;
      }
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return _LocationAccessResult.serviceDisabled;
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      userPosition = position;
      return _LocationAccessResult.success;
    } catch (e) {
      return _LocationAccessResult.error;
    }
  }

  Future<void> _showLocationDialog(String message) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('위치 권한'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await Geolocator.openAppSettings();
            },
            child: const Text('설정으로 이동'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  title: const Text('군장병우대업소(상품권환급)'),
                  floating: true,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.info_outline),
                      onPressed: _showInfoDialog,
                      tooltip: '환급 안내',
                    ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 8, 0, 12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _categoryChip(
                                '음식점',
                                SoldierCategory.restaurant,
                                Icons.restaurant,
                              ),
                            ),
                            Expanded(
                              child: _categoryChip(
                                '숙박업',
                                SoldierCategory.lodgingIndustry,
                                Icons.hotel,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _categoryChip(
                                '미용실',
                                SoldierCategory.hair,
                                Icons.content_cut,
                              ),
                            ),
                            Expanded(
                              child: _categoryChip(
                                'PC방',
                                SoldierCategory.pcroom,
                                Icons.computer,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                if (_loading)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final list = _filtered;
                      if (index >= list.length) return null;
                      final s = list[index];
                      return _SoldierTile(
                        soldier: s,
                        distanceKm: _sortByDistance ? _distanceFor(s) : null,
                        onTap: () => _showSoldierBottomSheet(context, s),
                      );
                    }, childCount: _filtered.length),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _loading ? null : _tapNearbySort,
                child: const Text('가까운 순으로 표시'),
              ),
            ),
          ),
          SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _categoryChip(String label, String category, IconData icon) {
    final selected = _selectedCategory == category;
    final iconColor = selected ? tossBlue : Colors.grey.shade600;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: FilterChip(
        showCheckmark: false,
        label: SizedBox(
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: iconColor),
              const SizedBox(width: 6),
              Text(label),
            ],
          ),
        ),
        selected: selected,
        onSelected: (_) => setState(() => _selectedCategory = category),
        selectedColor: tossBlue.withValues(alpha: 0.2),
        side: BorderSide(
          color: selected ? tossBlue : Colors.grey.shade300,
          width: selected ? 2 : 1,
        ),
      ),
    );
  }

  void _showSoldierBottomSheet(BuildContext context, Soldier soldier) {
    final maxHeight = MediaQuery.of(context).size.height * 0.9;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      soldier.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (soldier.photoUrl != null &&
                        soldier.photoUrl!.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: soldier.photoUrl!,
                          width: double.infinity,
                          height: 120,
                          fit: BoxFit.cover,
                          placeholder: (_, _) =>
                              _bottomSheetPhotoPlaceholder(),
                          errorWidget: (_, _, _) =>
                              _bottomSheetPhotoPlaceholder(),
                        ),
                      )
                    else
                      _bottomSheetPhotoPlaceholder(),
                    if (soldier.district.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        soldier.district,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                    if (soldier.address.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        soldier.address,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                    if (soldier.lat != null && soldier.lng != null) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 160,
                        child: PlatformMap(
                          initialCameraPosition: CameraPosition(
                            target: LatLng(soldier.lat!, soldier.lng!),
                            zoom: 16,
                          ),
                          markers: {
                            Marker(
                              markerId: MarkerId('soldier_${soldier.name}'),
                              position: LatLng(
                                  soldier.lat!, soldier.lng!),
                              consumeTapEvents: true,
                              infoWindow: InfoWindow(
                                title: soldier.name,
                                snippet: soldier.address,
                              ),
                            ),
                          },
                          mapType: MapType.normal,
                          compassEnabled: true,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => openNaverMap(
                          soldier.address.isNotEmpty
                              ? '${soldier.name} ${soldier.address}'
                              : soldier.name,
                        ),
                        icon: const Icon(Icons.map_outlined, size: 20),
                        label: const Text('맵 열기'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('닫기'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bottomSheetPhotoPlaceholder() {
    return Container(
      width: double.infinity,
      height: 120,
      color: Colors.grey.shade200,
      child: Icon(Icons.store, color: Colors.grey.shade500, size: 48),
    );
  }

}

class _SoldierTile extends StatelessWidget {
  const _SoldierTile({
    required this.soldier,
    this.distanceKm,
    this.onTap,
  });

  final Soldier soldier;
  final double? distanceKm;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Divider(height: 1),
        InkWell(
          onTap: onTap ??
              () => openNaverMap(
                    soldier.address.isNotEmpty
                        ? '${soldier.name} ${soldier.address}'
                        : soldier.name,
                  ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child:
                      soldier.photoUrl != null && soldier.photoUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: soldier.photoUrl!,
                          width: 72,
                          height: 72,
                          fit: BoxFit.cover,
                          placeholder: (_, _) => _placeholder(),
                          errorWidget: (_, _, _) => _placeholder(),
                        )
                      : _placeholder(),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        soldier.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      if (soldier.address.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          soldier.address,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.map_outlined),
                      onPressed: () => openNaverMap(
                        soldier.address.isNotEmpty
                            ? '${soldier.name} ${soldier.address}'
                            : soldier.name,
                      ),
                      tooltip: '지도에서 보기',
                    ),
                    if (distanceKm != null)
                      Text(
                        '${distanceKm!.toStringAsFixed(1)} km',
                        style: TextStyle(
                          color: tossBlue,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _placeholder() {
    return Container(
      width: 72,
      height: 72,
      color: Colors.grey.shade200,
      child: Icon(Icons.store, color: Colors.grey.shade500, size: 32),
    );
  }
}

enum _LocationAccessResult {
  success,
  denied,
  deniedForever,
  serviceDisabled,
  error,
}
