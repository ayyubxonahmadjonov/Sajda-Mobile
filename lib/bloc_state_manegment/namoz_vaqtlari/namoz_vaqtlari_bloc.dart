import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sajda_app/models/namoz_time_model.dart';
import 'package:sajda_app/services/notification_service/notification_service.dart';

part 'namoz_vaqtlari_event.dart';
part 'namoz_vaqtlari_state.dart';

class NamozVaqtlariBloc
    extends Bloc<NamozVaqtlariEvent, NamozVaqtlariState> {
  NamozVaqtlariBloc() : super(NamozVaqtlariInitial()) {
    on<GetNamozVaqtiEvent>(_getTime);
  }

  // App'dagi viloyat nomi → islomapi.uz qabul qiladigan region nomi
  static const Map<String, String> _regionMap = {
    'Qashqadaryo': 'Qarshi',
    'Sirdaryo': 'Guliston',
    'Surxandaryo': 'Termiz',
    'Xorazm': 'Xiva',
  };

  Future<void> _getTime(
    GetNamozVaqtiEvent event,
    Emitter<NamozVaqtlariState> emit,
  ) async {
    emit(ProccesNamozVaqtlariState());

    final region = _regionMap[event.location] ?? event.location;
    final now = DateTime.now();

    try {
      final dio = Dio();
      dio.options.connectTimeout = const Duration(seconds: 10);
      dio.options.receiveTimeout = const Duration(seconds: 10);

      final response = await dio.get(
        'https://islomapi.uz/api/daily',
        queryParameters: {
          'region': region,
          'month': now.month,
          'day': now.day,
        },
      );

      final data = response.data;
      if (response.statusCode == 200 &&
          data is Map<String, dynamic> &&
          data['times'] != null) {
        final time = NamozTime.fromIslomApi(
          data,
          regionName: event.location,
        );
        emit(SuccesNamozVaqtlariState(time));
        // Namoz vaqtlariga qarab bildirishnomalarni qayta rejalashtiramiz.
        unawaited(NotificationService().schedulePrayerNotifications(time));
      } else {
        emit(FailureNamozVaqtlariState("Ma'lumot topilmadi"));
      }
    } catch (e) {
      emit(FailureNamozVaqtlariState('Internet aloqasini tekshiring'));
    }
  }
}
