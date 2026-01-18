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
   final date = DateFormat('dd-MM-yyyy').format(DateTime.now());
      print(date);
    try {
      final dio = Dio();
   print(event.location);
      final response = await dio.get(
        'https://api.aladhan.com/v1/timingsByCity/$date?city=${event.location}&country=Uzbekistan&method=2',
      );
        if (response.statusCode == 200) {
          print(response.data);
  final data = response.data; 
  final NamozTime time = NamozTime.fromJson(data, regionName: event.location);

  emit(SuccesNamozVaqtlariState(time));
      
      } else {
        emit(FailureNamozVaqtlariState('Server xatosi'));
      }
    } catch (e) {
      emit(FailureNamozVaqtlariState('Server xatosi'));
    }
  }
}
