import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sajda_app/models/namoz_time_model.dart';

part 'namoz_vaqtlari_event.dart';
part 'namoz_vaqtlari_state.dart';

class NamozVaqtlariBloc
    extends Bloc<NamozVaqtlariEvent, NamozVaqtlariState> {
  NamozVaqtlariBloc() : super(NamozVaqtlariInitial()) {
    on<GetNamozVaqtiEvent>(_getTime);
  }

  Future<void> _getTime(
    GetNamozVaqtiEvent event,
    Emitter<NamozVaqtlariState> emit,
  ) async {
    emit(ProccesNamozVaqtlariState());

    final date = DateFormat('yyyy-MM-dd').format(DateTime.now());

    try {
      final dio = Dio();
      final response = await dio.get(
        'https://namoz-vaqtlari.more-info.uz:444/api/GetDailyPrayTimes/${event.location}/$date',
      );

      print('🔹 STATUS: ${response.statusCode}');
      print('🔹 RAW DATA: ${response.data}');

      if (response.statusCode == 200 &&
          response.data != null &&
          response.data['response'] != null) {
        
        final NamozTime time = NamozTime.fromJson(
          response.data,
          regionName: event.location,
          date: date,
        );

        print('✅ PARSED MODEL: ${time.toJson()}');

        emit(SuccesNamozVaqtlariState(time));
      } else {
        emit(FailureNamozVaqtlariState('Maʼlumot topilmadi'));
      }
    } catch (e) {
      print('❌ ERROR: $e');
      emit(FailureNamozVaqtlariState('Server xatosi'));
    }
  }
}
