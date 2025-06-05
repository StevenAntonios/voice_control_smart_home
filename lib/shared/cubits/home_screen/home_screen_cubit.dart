import 'package:bloc/bloc.dart';


import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';

part 'home_screen_state.dart';

class HomeScreenCubit extends Cubit<HomeScreenState> {
  final Dio _dio = Dio();
  Map<String, int> roomsData = {}; // Stores room names and device count

  HomeScreenCubit() : super(HomeScreenInitial()) {
    fetchRooms();
  }

  Future<void> fetchRooms() async {
    try {
      emit(HomeScreenLoading());
      final response =
          await _dio.get("http://192.168.174.79:5000/get-devices-status");

      // Convert response to Map<String, int> (room name -> device count)
      final Map<String, Map<String, int>> rooms =
          Map<String, Map<String, int>>.from(response.data);
      roomsData = {for (var entry in rooms.entries) entry.key: entry.value.length};

      emit(HomeScreenLoaded(roomsData));
    } catch (e) {
      emit(HomeScreenError("Failed to load rooms"));
    }
  }
}