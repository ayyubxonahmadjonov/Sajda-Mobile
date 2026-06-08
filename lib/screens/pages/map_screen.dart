import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:sajda_app/app/constants/globals.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

/// Bir masjid haqida ma'lumot.
class _Mosque {
  final String name;
  final String description;
  final double lat;
  final double lon;
  final double distance; // metrda

  const _Mosque({
    required this.name,
    required this.description,
    required this.lat,
    required this.lon,
    required this.distance,
  });
}

class MosqueMapPage extends StatefulWidget {
  const MosqueMapPage({super.key});

  @override
  State<MosqueMapPage> createState() => _MosqueMapPageState();
}

class _MosqueMapPageState extends State<MosqueMapPage> {
  final mapControllerCompleter = Completer<YandexMapController>();
  final List<MapObject> mapObjects = [];
  final List<_Mosque> mosques = [];

  Position? currentPosition;
  bool isLoading = true;
  bool isSearching = false;
  bool hasRoute = false;
  String? selectedMosqueName;
  String? routeInfo;

  // Xaritada ishlatiladigan ikonkalar (runtime'da chiziladi).
  BitmapDescriptor? _userIcon;
  BitmapDescriptor? _mosqueIcon;

  // 30 km radius.
  static const double _radiusMeters = 30000;

  static const String _yandexSearchApiKey =
      'e0100647-eb65-43b3-93e3-9b9acf335042';

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    _userIcon = BitmapDescriptor.fromBytes(
      await _buildMarkerBytes(
        icon: Icons.person_pin_circle_rounded,
        bgColor: const Color(0xFF2196F3),
      ),
    );
    _mosqueIcon = BitmapDescriptor.fromBytes(
      await _buildMarkerBytes(
        icon: Icons.mosque_rounded,
        bgColor: primary,
      ),
    );
    await _checkAndRequestPermissions();
  }

  /// Material ikonkadan dumaloq marker rasmini chizadi (PNG asset shart emas).
  Future<Uint8List> _buildMarkerBytes({
    required IconData icon,
    required Color bgColor,
    double size = 120,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final radius = size / 2;
    final center = Offset(radius, radius);

    // Soya.
    canvas.drawCircle(
      center.translate(0, 2),
      radius - 4,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    // Oq halqa.
    canvas.drawCircle(center, radius - 4, Paint()..color = Colors.white);
    // Rangli doira.
    canvas.drawCircle(center, radius - 10, Paint()..color = bgColor);

    // Ikonka.
    final tp = TextPainter(textDirection: TextDirection.ltr);
    tp.text = TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(
        fontSize: size * 0.5,
        fontFamily: icon.fontFamily,
        package: icon.fontPackage,
        color: Colors.white,
      ),
    );
    tp.layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return data!.buffer.asUint8List();
  }

  Future<void> _checkAndRequestPermissions() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      await _getCurrentLocation();
    } else {
      setState(() => isLoading = false);
      if (mounted) _showSnackBar('Joylashuv ruxsati berilmadi');
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      setState(() {
        currentPosition = position;
        isLoading = false;
      });

      final controller = await mapControllerCompleter.future;
      await controller.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: Point(
              latitude: position.latitude,
              longitude: position.longitude,
            ),
            zoom: 12,
          ),
        ),
        animation: const MapAnimation(
          type: MapAnimationType.smooth,
          duration: 1.0,
        ),
      );

      _addUserPlacemark(position);
      await _searchNearbyMosques(position);
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) _showSnackBar('Joylashuv topishda xatolik: $e');
    }
  }

  void _addUserPlacemark(Position pos) {
    final userPlacemark = PlacemarkMapObject(
      mapId: const MapObjectId('user_location'),
      point: Point(latitude: pos.latitude, longitude: pos.longitude),
      icon: PlacemarkIcon.single(
        PlacemarkIconStyle(
          image: _userIcon!,
          scale: 0.6,
        ),
      ),
      opacity: 1.0,
      zIndex: 100,
    );

    setState(() {
      mapObjects
        ..removeWhere((o) => o.mapId.value == 'user_location')
        ..add(userPlacemark);
    });
  }

  Future<void> _searchNearbyMosques(Position pos) async {
    setState(() => isSearching = true);

    // 30 km radius uchun spn ~ 0.55 gradus.
    final url = Uri.parse(
      'https://search-maps.yandex.ru/v1/'
      '?text=masjid'
      '&type=biz'
      '&lang=uz_UZ'
      '&ll=${pos.longitude},${pos.latitude}'
      '&spn=0.55,0.55'
      '&results=50'
      '&apikey=$_yandexSearchApiKey',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode != 200) {
        throw Exception('Search API xatosi: ${response.statusCode}');
      }

      final data = json.decode(response.body);
      final features = data['features'] as List<dynamic>? ?? [];

      final found = <_Mosque>[];
      for (final feature in features) {
        final coords = feature['geometry']['coordinates'] as List<dynamic>;
        final lon = (coords[0] as num).toDouble();
        final lat = (coords[1] as num).toDouble();

        final distance = Geolocator.distanceBetween(
          pos.latitude,
          pos.longitude,
          lat,
          lon,
        );
        if (distance > _radiusMeters) continue;

        final props = feature['properties'] as Map<String, dynamic>;
        found.add(
          _Mosque(
            name: props['name'] as String? ?? 'Masjid',
            description: props['description'] as String? ?? '',
            lat: lat,
            lon: lon,
            distance: distance,
          ),
        );
      }

      found.sort((a, b) => a.distance.compareTo(b.distance));

      final placemarks = <PlacemarkMapObject>[];
      for (var i = 0; i < found.length; i++) {
        final m = found[i];
        placemarks.add(
          PlacemarkMapObject(
            mapId: MapObjectId('mosque_$i'),
            point: Point(latitude: m.lat, longitude: m.lon),
            icon: PlacemarkIcon.single(
              PlacemarkIconStyle(
                image: _mosqueIcon!,
                scale: 0.5,
              ),
            ),
            text: PlacemarkText(
              text: _shortName(m.name),
              style: PlacemarkTextStyle(
                size: 8,
                color: primary,
                outlineColor: Colors.white,
                placement: TextStylePlacement.bottom,
                textOptional: true,
              ),
            ),
            opacity: 1.0,
            onTap: (_, __) => _onMosqueTap(m),
          ),
        );
      }

      setState(() {
        mosques
          ..clear()
          ..addAll(found);
        mapObjects.removeWhere(
          (o) => o.mapId.value.toString().startsWith('mosque_'),
        );
        mapObjects.addAll(placemarks);
        isSearching = false;
      });

      _showSnackBar(
        found.isEmpty
            ? '30 km radiusda masjid topilmadi'
            : '${found.length} ta masjid topildi',
      );
    } catch (e) {
      setState(() => isSearching = false);
      if (mounted) _showSnackBar('Qidiruv xatosi: $e');
    }
  }

  String _shortName(String name) {
    final cleaned = name.replaceAll(RegExp(r'\s+'), ' ').trim();
    return cleaned.length > 22 ? '${cleaned.substring(0, 22)}…' : cleaned;
  }

  String _formatDistance(double meters) => meters >= 1000
      ? '${(meters / 1000).toStringAsFixed(1)} km'
      : '${meters.toInt()} m';

  void _onMosqueTap(_Mosque m) {
    setState(() => selectedMosqueName = m.name);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF0D1B4B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          16,
          20,
          MediaQuery.of(ctx).padding.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.mosque_rounded, color: primary, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    m.name,
                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            if (m.description.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                m.description,
                style: GoogleFonts.poppins(fontSize: 13, color: text),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.near_me_rounded, size: 16, color: primary),
                const SizedBox(width: 6),
                Text(
                  'Masofa: ${_formatDistance(m.distance)}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  _drawRoute(m);
                },
                icon: const Icon(Icons.directions_rounded),
                label: Text(
                  "Yo'lni ko'rsatish",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _drawRoute(_Mosque m) async {
    if (currentPosition == null) {
      _showSnackBar('Sizning joylashuvingiz topilmadi');
      return;
    }
    _showSnackBar("Yo'l hisoblanmoqda...");

    try {
      final (session, result) = await YandexDriving.requestRoutes(
        points: [
          RequestPoint(
            point: Point(
              latitude: currentPosition!.latitude,
              longitude: currentPosition!.longitude,
            ),
            requestPointType: RequestPointType.wayPoint,
          ),
          RequestPoint(
            point: Point(latitude: m.lat, longitude: m.lon),
            requestPointType: RequestPointType.wayPoint,
          ),
        ],
        drivingOptions: const DrivingOptions(routesCount: 1),
      );

      final res = await result;
      await session.close();

      if (res.routes != null && res.routes!.isNotEmpty) {
        final route = res.routes!.first;
        final polyline = PolylineMapObject(
          mapId: const MapObjectId('route_polyline'),
          polyline: route.geometry,
          strokeColor: primary,
          strokeWidth: 5,
          outlineColor: Colors.white,
          outlineWidth: 1,
        );

        setState(() {
          mapObjects.removeWhere((o) => o.mapId.value == 'route_polyline');
          mapObjects.add(polyline);
          hasRoute = true;
          routeInfo =
              '${route.metadata.weight.distance.text} • '
              '${route.metadata.weight.timeWithTraffic.text}';
        });

        final controller = await mapControllerCompleter.future;
        await controller.moveCamera(
          CameraUpdate.newGeometry(Geometry.fromPolyline(route.geometry)),
          animation: const MapAnimation(
            type: MapAnimationType.smooth,
            duration: 1.0,
          ),
        );
      } else {
        _drawStraightLine(m);
      }
    } catch (_) {
      _drawStraightLine(m);
    }
  }

  /// Routing ishlamasa to'g'ri chiziq chizadi.
  void _drawStraightLine(_Mosque m) {
    if (currentPosition == null) return;

    final polyline = PolylineMapObject(
      mapId: const MapObjectId('route_polyline'),
      polyline: Polyline(
        points: [
          Point(
            latitude: currentPosition!.latitude,
            longitude: currentPosition!.longitude,
          ),
          Point(latitude: m.lat, longitude: m.lon),
        ],
      ),
      strokeColor: primary,
      strokeWidth: 4,
      dashLength: 10,
      gapLength: 6,
    );

    setState(() {
      mapObjects.removeWhere((o) => o.mapId.value == 'route_polyline');
      mapObjects.add(polyline);
      hasRoute = true;
      routeInfo = "To'g'ri masofa: ${_formatDistance(m.distance)}";
    });
    _showSnackBar("Yo'l chizildi");
  }

  void _clearRoute() {
    setState(() {
      mapObjects.removeWhere((o) => o.mapId.value == 'route_polyline');
      selectedMosqueName = null;
      hasRoute = false;
      routeInfo = null;
    });
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message, style: GoogleFonts.poppins(fontSize: 13)),
          backgroundColor: primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  Future<void> _recenter() async {
    if (currentPosition == null) return;
    final controller = await mapControllerCompleter.future;
    await controller.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: Point(
            latitude: currentPosition!.latitude,
            longitude: currentPosition!.longitude,
          ),
          zoom: 14,
        ),
      ),
      animation: const MapAnimation(
        type: MapAnimationType.smooth,
        duration: 1.0,
      ),
    );
  }

  void _showMosqueList() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF0D1B4B) : Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                Icon(Icons.mosque_rounded, color: primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Yaqin masjidlar (${mosques.length})',
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: isDark ? Colors.white12 : Colors.black12),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: mosques.length,
              itemBuilder: (ctx, i) {
                final m = mosques[i];
                return ListTile(
                  leading: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.mosque_rounded, color: primary, size: 18),
                  ),
                  title: Text(
                    m.name,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    _formatDistance(m.distance),
                    style: GoogleFonts.poppins(fontSize: 12, color: text),
                  ),
                  trailing: Icon(Icons.directions_rounded, color: primary),
                  onTap: () {
                    Navigator.pop(ctx);
                    _drawRoute(m);
                  },
                );
              },
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 12),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Yaqin masjidlar',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        actions: [
          if (hasRoute)
            IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: _clearRoute,
              tooltip: "Yo'lni tozalash",
            ),
          if (mosques.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.list_rounded),
              onPressed: _showMosqueList,
              tooltip: 'Masjidlar ro\'yxati',
            ),
        ],
      ),
      body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Joylashuv aniqlanmoqda...',
                    style: GoogleFonts.poppins(color: text),
                  ),
                ],
              ),
            )
          : currentPosition == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_off_rounded,
                          size: 64, color: text),
                      const SizedBox(height: 16),
                      Text(
                        'Joylashuv topilmadi',
                        style: GoogleFonts.poppins(fontSize: 17),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() => isLoading = true);
                          _checkAndRequestPermissions();
                        },
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Qayta urinish'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                )
              : Stack(
                  children: [
                    YandexMap(
                      onMapCreated: (controller) =>
                          mapControllerCompleter.complete(controller),
                      mapObjects: mapObjects,
                      mapType: MapType.map,
                      nightModeEnabled: isDark,
                    ),
                    if (isSearching)
                      Positioned(
                        top: 12,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: primary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Masjidlar qidirilmoqda...',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    if (routeInfo != null)
                      Positioned(
                        bottom: 20,
                        left: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF0D1B4B)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.directions_rounded, color: primary),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    if (selectedMosqueName != null)
                                      Text(
                                        selectedMosqueName!,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black87,
                                        ),
                                      ),
                                    Text(
                                      routeInfo!,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: text,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
      floatingActionButton: currentPosition == null
          ? null
          : Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  heroTag: 'refresh',
                  mini: true,
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  onPressed: () => _searchNearbyMosques(currentPosition!),
                  child: const Icon(Icons.refresh_rounded),
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  heroTag: 'my_location',
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  onPressed: _recenter,
                  child: const Icon(Icons.my_location_rounded),
                ),
              ],
            ),
    );
  }
}
