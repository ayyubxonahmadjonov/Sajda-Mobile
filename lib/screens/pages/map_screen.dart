import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

class MosqueMapPage extends StatefulWidget {
  const MosqueMapPage({super.key});

  @override
  State<MosqueMapPage> createState() => _MosqueMapPageState();
}

class _MosqueMapPageState extends State<MosqueMapPage> {
  final mapControllerCompleter = Completer<YandexMapController>();
  final List<MapObject> mapObjects = [];

  Position? currentPosition;
  bool isLoading = true;
  String? selectedMosqueName;

  // Yandex API kalitlari
  static const String yandexSearchApiKey =
      'e0100647-eb65-43b3-93e3-9b9acf335042';
  // static const String yandexRoutingApiKey = 'YOUR_ROUTING_API_KEY'; // https://developer.tech.yandex.ru/services/ dan oling

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    await _checkAndRequestPermissions();
  }

  Future<void> _checkAndRequestPermissions() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      await _getCurrentLocation();
    } else {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        _showSnackBar('Joylashuv ruxsati berilmadi');
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
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
            zoom: 13,
          ),
        ),
        animation: const MapAnimation(
          type: MapAnimationType.smooth,
          duration: 1.0,
        ),
      );

      // Foydalanuvchi belgisini qo'shish
      _addUserPlacemark(position);

      // Yaqin masjidlarni qidirish
      await _searchNearbyMosques(position);
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        _showSnackBar('Joylashuv topishda xatolik: $e');
      }
    }
  }

  void _addUserPlacemark(Position pos) {
    final userPlacemark = PlacemarkMapObject(
      mapId: const MapObjectId('user_location'),
      point: Point(latitude: pos.latitude, longitude: pos.longitude),
      icon: PlacemarkIcon.single(
        PlacemarkIconStyle(
          image: BitmapDescriptor.fromAssetImage('assets/user_location.png'),
          scale: 2.5,
        ),
      ),
      opacity: 1.0,
    );

    setState(() {
      mapObjects.add(userPlacemark);
    });
  }

  Future<void> _searchNearbyMosques(Position pos) async {
    // 5000 metr = 5 km
    // spn parametri: taxminan 0.05 gradus = ~5.5 km
    final url = Uri.parse(
      'https://search-maps.yandex.ru/v1/'
      '?text=masjid'
      '&type=biz'
      '&lang=uz_UZ'
      '&ll=${pos.longitude},${pos.latitude}'
      '&spn=0.09,0.09' // 5 km radiusga yaqin
      '&results=50' // ko'proq natija olish
      '&apikey=$yandexSearchApiKey',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final features = data['features'] as List<dynamic>? ?? [];

        final List<PlacemarkMapObject> mosques = [];

        for (int i = 0; i < features.length; i++) {
          final feature = features[i];
          final coords = feature['geometry']['coordinates'] as List<dynamic>;
          final lon = coords[0] as double;
          final lat = coords[1] as double;

          // Masofani hisoblash (metrda)
          double distance = Geolocator.distanceBetween(
            pos.latitude,
            pos.longitude,
            lat,
            lon,
          );

          // Faqat 5000 metr ichidagilarni qo'shish
          if (distance <= 5000) {
            final name = feature['properties']['name'] as String? ?? 'Masjid';
            final desc = feature['properties']['description'] as String? ?? '';

            final placemark = PlacemarkMapObject(
              mapId: MapObjectId('mosque_$i'),
              point: Point(latitude: lat, longitude: lon),
              icon: PlacemarkIcon.single(
                PlacemarkIconStyle(
                  image: BitmapDescriptor.fromAssetImage('assets/mosque.png'),
                  scale: 2.0,
                ),
              ),
              opacity: 0.95,
              onTap: (self, point) {
                _onMosqueTap(name, desc, lat, lon, distance);
              },
            );

            mosques.add(placemark);
          }
        }

        setState(() {
          // Oldingi masjid belgilarini o'chirish
          mapObjects.removeWhere(
            (obj) => obj.mapId.value.toString().startsWith('mosque_'),
          );
          mapObjects.addAll(mosques);
        });

        if (mosques.isEmpty && mounted) {
          _showSnackBar('5 km radiusda masjidlar topilmadi');
        } else {
          _showSnackBar('${mosques.length} ta masjid topildi');
        }
      } else {
        throw Exception('Search API xatosi: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Qidiruv xatosi: $e');
      }
    }
  }

  void _onMosqueTap(
    String name,
    String desc,
    double lat,
    double lon,
    double distance,
  ) {
    setState(() {
      selectedMosqueName = name;
    });

    // Masofani km yoki metrda ko'rsatish
    String distanceText;
    if (distance >= 1000) {
      distanceText = '${(distance / 1000).toStringAsFixed(1)} km';
    } else {
      distanceText = '${distance.toInt()} m';
    }

    // Yo'l chizish
    // _drawRoute(lat, lon);

    // Ma'lumot ko'rsatish
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (desc.isNotEmpty)
                Text(
                  desc,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 18, color: Colors.blue),
                  const SizedBox(width: 6),
                  Text(
                    'Masofa: $distanceText',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    // _drawRoute(lat, lon);
                  },
                  icon: const Icon(Icons.directions),
                  label: const Text('Yo\'lni ko\'rsatish'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Future<void> _drawRoute(double destLat, double destLon) async {
  //   if (currentPosition == null) {
  //     _showSnackBar('Sizning joylashuvingiz topilmadi');
  //     return;
  //   }

  //   try {
  //     // Oldingi yo'lni o'chirish
  //     setState(() {
  //       mapObjects.removeWhere((obj) => obj.mapId.value == 'route_polyline');
  //     });

  //     // Yandex Routing API orqali yo'l olish
  //     final url = Uri.parse(
  //       'https://api.routing.yandex.net/v2/route'
  //       '?apikey=$yandexRoutingApiKey'
  //       '&waypoints=${currentPosition!.longitude},${currentPosition!.latitude}|$destLon,$destLat'
  //       '&mode=walking', // piyoda yo'l
  //     );

  //     final response = await http.get(url);

  //     if (response.statusCode == 200) {
  //       final data = json.decode(response.body);

  //       // Yo'l koordinatalarini olish
  //       final route = data['route'];
  //       final legs = route['legs'] as List<dynamic>;

  //       List<Point> routePoints = [];

  //       for (var leg in legs) {
  //         final steps = leg['steps'] as List<dynamic>;
  //         for (var step in steps) {
  //           final polyline = step['polyline'];
  //           final points = polyline['points'] as List<dynamic>;

  //           for (var point in points) {
  //             final coords = point as List<dynamic>;
  //             routePoints.add(Point(
  //               latitude: coords[1] as double,
  //               longitude: coords[0] as double,
  //             ));
  //           }
  //         }
  //       }

  //       // Yo'lni xaritaga chizish
  //       final routePolyline = PolylineMapObject(
  //         mapId: const MapObjectId('route_polyline'),
  //         polyline: Polyline(points: routePoints),
  //         strokeColor: Colors.blue,
  //         strokeWidth: 4.0,
  //       );

  //       setState(() {
  //         mapObjects.add(routePolyline);
  //       });

  //       // Xaritani yo'lga moslashtirish
  //       final controller = await mapControllerCompleter.future;
  //       await controller.moveCamera(
  //         CameraUpdate.newCameraPosition(
  //           CameraPosition(
  //             target: Point(
  //               latitude: (currentPosition!.latitude + destLat) / 2,
  //               longitude: (currentPosition!.longitude + destLon) / 2,
  //             ),
  //             zoom: 13,
  //           ),
  //         ),
  //         animation: const MapAnimation(
  //           type: MapAnimationType.smooth,
  //           duration: 1.0,
  //         ),
  //       );

  //       _showSnackBar('Yo\'l chizildi');
  //     } else {
  //       // Agar Routing API ishlamasa, to'g'ri chiziq chizish
  //       _drawStraightLine(destLat, destLon);
  //     }
  //   } catch (e) {
  //     // Xatolik bo'lsa, to'g'ri chiziq chizish
  //     _drawStraightLine(destLat, destLon);
  //   }
  // }

  void _drawStraightLine(double destLat, double destLon) {
    if (currentPosition == null) return;

    // Oldingi yo'lni o'chirish
    setState(() {
      mapObjects.removeWhere((obj) => obj.mapId.value == 'route_polyline');
    });

    final routePolyline = PolylineMapObject(
      mapId: const MapObjectId('route_polyline'),
      polyline: Polyline(
        points: [
          Point(
            latitude: currentPosition!.latitude,
            longitude: currentPosition!.longitude,
          ),
          Point(latitude: destLat, longitude: destLon),
        ],
      ),
      strokeColor: Colors.blue,
      strokeWidth: 4.0,
      dashLength: 10,
      gapLength: 5,
    );

    setState(() {
      mapObjects.add(routePolyline);
    });

    _showSnackBar('To\'g\'ri yo\'l chizildi');
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
      );
    }
  }

  void _clearRoute() {
    setState(() {
      mapObjects.removeWhere((obj) => obj.mapId.value == 'route_polyline');
      selectedMosqueName = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yaqin masjidlar'),
        actions: [
          if (selectedMosqueName != null)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _clearRoute,
              tooltip: 'Yo\'lni tozalash',
            ),
        ],
      ),
      body:
          isLoading
              ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Joylashuv aniqlanmoqda...'),
                  ],
                ),
              )
              : currentPosition == null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.location_off,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Joylashuv topilmadi',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _getCurrentLocation,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Qayta urinish'),
                    ),
                  ],
                ),
              )
              : YandexMap(
                onMapCreated: (controller) {
                  mapControllerCompleter.complete(controller);
                },
                mapObjects: mapObjects,
                mapType: MapType.map,
              ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'refresh',
            onPressed: () {
              if (currentPosition != null) {
                _searchNearbyMosques(currentPosition!);
              }
            },
            child: const Icon(Icons.refresh),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'my_location',
            onPressed: () async {
              if (currentPosition != null) {
                final controller = await mapControllerCompleter.future;
                await controller.moveCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(
                      target: Point(
                        latitude: currentPosition!.latitude,
                        longitude: currentPosition!.longitude,
                      ),
                      zoom: 15,
                    ),
                  ),
                  animation: const MapAnimation(
                    type: MapAnimationType.smooth,
                    duration: 1.0,
                  ),
                );
              }
            },
            child: const Icon(Icons.my_location),
          ),
        ],
      ),
    );
  }
}
