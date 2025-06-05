
class HomeStatus {
  final double temperature;
  final double humidity;
  final int ldr;
  final int door;
  final int curtain;
  final Map<String, RoomStatus> rooms;

  HomeStatus({
    required this.temperature,
    required this.humidity,
    required this.ldr,
    required this.door,
    required this.curtain,
    required this.rooms,
  });

  factory HomeStatus.fromJson(Map<String, dynamic> json) {
    return HomeStatus(
      temperature: json['temperature'].toDouble(),
      humidity: json['humidity'].toDouble(),
      ldr: json['ldr'],
      door: json['door'],
      curtain: json['curtain'],
      rooms: Map<String, RoomStatus>.from(json.map((key, value) =>
          MapEntry(key, RoomStatus.fromJson(value)))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'humidity': humidity,
      'ldr': ldr,
      'door': door,
      'curtain': curtain,
      'rooms': rooms.map((key, value) => MapEntry(key, value.toJson())),
    };
  }
}

class RoomStatus {
  final Map<String, int> devices;

  RoomStatus({required this.devices});

  factory RoomStatus.fromJson(Map<String, dynamic> json) {
    return RoomStatus(
      devices: Map<String, int>.from(json),
    );
  }

  Map<String, dynamic> toJson() {
    return devices;
  }
}
