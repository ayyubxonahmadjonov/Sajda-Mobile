import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sajda_app/models/namoz_time_model.dart';

part 'namoz_vaqtlari_event.dart';
part 'namoz_vaqtlari_state.dart';

class NamozVaqtlariBloc
    extends Bloc<NamozVaqtlariEvent, NamozVaqtlariState> {
  NamozVaqtlariBloc() : super(NamozVaqtlariInitial()) {
    on<GetNamozVaqtiEvent>(_getTime);
  }

  // Koordinatlar: har bir shahar/viloyat uchun aniq lat/lon
  static const Map<String, _Coords> _coords = {
    'Toshkent':    _Coords(41.2995, 69.2401),
    'Andijon':     _Coords(40.7821, 72.3442),
    'Buxoro':      _Coords(39.7675, 64.4231),
    "Farg'ona":    _Coords(40.3834, 71.7849),
    'Jizzax':      _Coords(40.1158, 67.8422),
    'Xiva':        _Coords(41.3786, 60.3600),
    'Namangan':    _Coords(40.9983, 71.6726),
    'Navoiy':      _Coords(40.0844, 65.3792),
    'Qashqadaryo': _Coords(38.8574, 65.7927), // Qarshi koordinati
    'Samarqand':   _Coords(39.6547, 66.9758),
    'Sirdaryo':    _Coords(40.4898, 68.7837),  // Guliston koordinati
    'Surxandaryo': _Coords(37.2242, 67.2783),  // Termez koordinati
  };

  Future<void> _getTime(
    GetNamozVaqtiEvent event,
    Emitter<NamozVaqtlariState> emit,
  ) async {
    emit(ProccesNamozVaqtlariState());

    final coords = _coords[event.location] ?? _coords['Toshkent']!;
    // Unix timestamp (soniyalarda)
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    try {
      final dio = Dio();
      dio.options.connectTimeout = const Duration(seconds: 10);
      dio.options.receiveTimeout = const Duration(seconds: 10);

      final response = await dio.get(
        'https://api.aladhan.com/v1/timings/$timestamp',
        queryParameters: {
          'latitude': coords.lat,
          'longitude': coords.lon,
          'method': 3,   // Muslim World League — Markaziy Osiyo uchun
          'school': 1,   // Hanafiy mazhabiga mos Asr vaqti
          'timezonestring': 'Asia/Tashkent', // Butun O'zbekiston UTC+5
        },
      );

      if (response.statusCode == 200 &&
          response.data != null &&
          response.data['code'] == 200) {
        final time = NamozTime.fromAlAdhan(
          response.data,
          regionName: event.location,
        );
        emit(SuccesNamozVaqtlariState(time));
      } else {
        emit(FailureNamozVaqtlariState("Ma'lumot topilmadi"));
      }
    } catch (e) {
      emit(FailureNamozVaqtlariState('Internet aloqasini tekshiring'));
    }
  }
}

class _Coords {
  final double lat;
  final double lon;
  const _Coords(this.lat, this.lon);
}
