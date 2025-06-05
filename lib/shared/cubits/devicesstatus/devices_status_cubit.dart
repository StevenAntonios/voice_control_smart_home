import 'dart:convert';
import 'dart:developer';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:voicecontrolsmarthome/index.dart';

part 'devices_status_state.dart';

class DeviceControlCubit extends Cubit<DeviceControlState> {
  final Dio _dio = Dio();
  final WebSocketChannel _channel;
  static String serverUrl = 'http://192.168.195.86:5000';
  Map<String, int> deviceStatus = {};
  double temperature = 0.0;
  static String websocketUrl = 'ws://192.168.195.79/ws';
  DeviceControlCubit()
      : _channel = WebSocketChannel.connect(Uri.parse(websocketUrl)),
        super(DeviceControlInitial()) {
    _listenToWebSocket();
  }

  void _listenToWebSocket() {
    _channel.stream.listen((message) {
      try {
        final data = jsonDecode(message);
        log("WebSocket Update: $data");

        _updateDeviceStatus(data);
        _updateTemperature(data);
      } catch (e) {
        emit(const DeviceControlError("WebSocket data error"));
      }
    }, onError: (error) => emit(DeviceControlError("WebSocket: $error")));
  }

  void _updateDeviceStatus(Map<String, dynamic> data) {
    final statusUpdates = <String, int>{};

    if (data.containsKey("light_kitchen")) {
      statusUpdates["light_kitchen"] = data["light_kitchen"] as int;
    }
    if (data.containsKey("fan_kitchen")) {
      statusUpdates["fan_kitchen"] = data["fan_kitchen"] as int;
    }
    if (data.containsKey("light_room")) {
      statusUpdates["light_room"] = data["light_room"] as int;
    }
    if (data.containsKey("curtains_room")) {
      statusUpdates["curtains_room"] = data["curtains_room"] as int;
    }
    if (data.containsKey("light1_livingRoom")) {
      statusUpdates["light1_livingRoom"] = data["light1_livingRoom"] as int;
    }
    if (data.containsKey("light2_livingRoom")) {
      statusUpdates["light2_livingRoom"] = data["light2_livingRoom"] as int;
    }
    if (data.containsKey("light3_livingRoom")) {
      statusUpdates["light3_livingRoom"] = data["light3_livingRoom"] as int;
    }
    if (data.containsKey("light4_livingRoom")) {
      statusUpdates["light4_livingRoom"] = data["light4_livingRoom"] as int;
    }
    if (data.containsKey("main_door_livingRoom")) {
      statusUpdates["main_door_livingRoom"] =
          data["main_door_livingRoom"] as int;
    }
    if (data.containsKey("light_bathroom")) {
      statusUpdates["light_bathroom"] = data["light_bathroom"] as int;
    }

    deviceStatus.addAll(statusUpdates);
    if (statusUpdates.isNotEmpty) {
      emit(DeviceStatusUpdated(Map.from(deviceStatus)));
    }
  }

  void _updateTemperature(Map<String, dynamic> data) {
    if (data.containsKey("temperature")) {
      temperature = (data["temperature"] as num).toDouble();
      emit(TemperatureUpdated(temperature));
    }
  }

  Future<void> fetchRoomStatus(int roomId) async {
    try {
      emit(DeviceControlLoading());

      final endpoints = {
        1: "/get-living-room-status",
        2: "/get-room-status",
        3: "/get-kitchen-status",
        4: "/get-bathroom-status",
      };

      final response = await _dio.get("$serverUrl${endpoints[roomId]}");
      final roomData = response.data as Map<String, dynamic>;

      deviceStatus.addAll(roomData.map((k, v) => MapEntry(k, v as int)));
      emit(DeviceStatusUpdated(Map.from(deviceStatus)));
    } catch (e) {
      emit(const DeviceControlError("Failed to fetch room status"));
    }
  }

  Future<void> updateDeviceStatus(String deviceId, int status) async {
    try {
      deviceStatus[deviceId] = status;
      emit(DeviceStatusUpdated(Map.from(deviceStatus)));

      await _dio.post("$serverUrl/update-status",
          data: {"device": deviceId, "status": status.toString()});
    } catch (e) {
      emit(DeviceControlError("Update failed: ${e.toString()}"));
    }
  }

  @override
  Future<void> close() {
    _channel.sink.close();
    return super.close();
  }
}
