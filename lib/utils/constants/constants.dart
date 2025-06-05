import 'package:voicecontrolsmarthome/index.dart';

abstract class Constants {
  static const List<Map<int, String>> roomName = [
    {1: "Living Room"},
    {2: "Room "},
    {3: "Kitchen"},
    {4: "Bathroom"},
  ];
  static List<String> roomNameValues =
      roomName.expand((map) => map.values).toList();
  static const List<Map<String, String>> roomImageUrl = [
    {"Living Room": "assets/icons/living-room-sofa-svgrepo-com.svg"},
    {"Room ": "assets/icons/bedroom-hotel-svgrepo-com.svg"},
    {"Kitchen": "assets/icons/kitchen-pack-cooker-svgrepo-com.svg"},
    {"Bathroom": "assets/icons/sink-svgrepo-com.svg"},
  ];
  static List<String> roomImageUrlValues =
      roomImageUrl.expand((map) => map.values).toList();

  static const List<Map<String, int>> numberOfDevices = [
    {"Living Room": 5},
    {"Room ": 2},
    {"Kitchen": 3},
    {"Bathroom": 1},
  ];
  static List<int> numberOfDevicesValues =
      numberOfDevices.expand((map) => map.values).toList();

  static const List<Map<String, dynamic>> rooms = [
    {
      "id": 1,
      "name": "Living Room",
      "image": "assets/icons/living-room-sofa-svgrepo-com.svg",
      "devices": [
        {"displayName": "Lamp 1", "deviceId": "light1_livingRoom"},
        {"displayName": "Lamp 2", "deviceId": "light2_livingRoom"},
        {"displayName": "Lamp 3", "deviceId": "light3_livingRoom"},
        {"displayName": "Lamp 4", "deviceId": "light4_livingRoom"},
        {"displayName": "Main Door", "deviceId": "main_door_livingRoom"},
      ]
    },
    {
      "id": 2,
      "name": "Bedroom",
      "image": "assets/icons/bedroom-hotel-svgrepo-com.svg",
      "devices": [
        {"displayName": "Lamp", "deviceId": "light_room"},
        {"displayName": "Curtains", "deviceId": "curtains_room"},
      ]
    },
    {
      "id": 3,
      "name": "Kitchen",
      "image": "assets/icons/kitchen-pack-cooker-svgrepo-com.svg",
      "devices": [
        {"displayName": "Lamp", "deviceId": "light_kitchen"},
        {"displayName": "Fan", "deviceId": "fan_kitchen"},
      ]
    },
    {
      "id": 4,
      "name": "Bathroom",
      "image": "assets/icons/sink-svgrepo-com.svg",
      "devices": [
        {"displayName": "Lamp", "deviceId": "light_bathroom"},
      ]
    },
  ];

  static const Map<String, String> deviceImages = {
    "light": "assets/icons/lamp-svgrepo-com.svg",
    "main": "assets/icons/door-svgrepo-com.svg",
    "curtains": "assets/icons/curtains-svgrepo-com.svg",
    "fan": "assets/icons/fan-svgrepo-com.svg",
  };
  static const mainFont = 'Montserrat';
  static const mainColor = Color.fromARGB(255, 0, 0, 0);

  static var hintStyle = TextStyle(
    fontFamily: Constants.mainFont,
    color: const Color.fromARGB(41, 19, 23, 27),
    fontWeight: FontWeight.w400,
    fontSize: 16.sp,
  );
  static var titleColor = TextStyle(
    fontFamily: Constants.mainFont,
    color: const Color.fromARGB(255, 0, 0, 0),
    fontWeight: FontWeight.w500,
    fontSize: 18.sp,
  );
  static var eighteenmid = TextStyle(
    fontFamily: Constants.mainFont,
    color: const Color.fromARGB(255, 255, 255, 255),
    fontWeight: FontWeight.w500,
    fontSize: 18.sp,
  );
  static var twentyfoursmbold = TextStyle(
    fontFamily: Constants.mainFont,
    color: const Color(0xff36454F),
    fontWeight: FontWeight.bold,
    fontSize: 24.sp,
  );
  static var forteensmbold = TextStyle(
    fontFamily: Constants.mainFont,
    color: Constants.mainColor,
    fontWeight: FontWeight.w600,
    fontSize: 14.sp,
  );
  static var forteenmid = TextStyle(
    fontFamily: Constants.mainFont,
    color: const Color(0xff36454F),
    fontWeight: FontWeight.w500,
    fontSize: 14.sp,
  );
}
