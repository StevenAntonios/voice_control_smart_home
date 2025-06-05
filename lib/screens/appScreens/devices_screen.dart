import 'package:voicecontrolsmarthome/index.dart';
import 'package:voicecontrolsmarthome/shared/cubits/devicesstatus/devices_status_cubit.dart';

class DevicesScreen extends StatelessWidget {
  final int roomId;
  final String roomName;

  const DevicesScreen({
    super.key,
    required this.roomId,
    required this.roomName,
  });

  Map<String, dynamic> _getRoomData() {
    return Constants.rooms.firstWhere(
      (room) => room["id"] == roomId,
      orElse: () => {},
    );
  }

  @override
  Widget build(BuildContext context) {
    final room = _getRoomData();
    final devices = (room["devices"] as List<dynamic>?) ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(roomName),
        centerTitle: true,
      ),
      body: BlocBuilder<DeviceControlCubit, DeviceControlState>(
        builder: (context, state) {
          final cubit = context.read<DeviceControlCubit>();

          if (state is DeviceControlLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              if (roomId == 3) // Kitchen
                _TemperatureWidget(temperature: cubit.temperature),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: devices.length,
                  itemBuilder: (context, index) {
                    final device = devices[index];
                    return _DeviceCard(
                      displayName: device["displayName"],
                      deviceId: device["deviceId"],
                      status: cubit.deviceStatus[device["deviceId"]] ?? 0,
                      onTap: () {
                        //   cubit.updateDeviceStatus(
                        //   device["deviceId"],
                        //   cubit.deviceStatus[device["deviceId"]] == 1 ? 0 : 1,
                        // );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DeviceCard extends StatelessWidget {
  final String displayName;
  final String deviceId;
  final int status;
  final VoidCallback onTap;

  const _DeviceCard({
    required this.displayName,
    required this.deviceId,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isOn = status == 1;
    final deviceType = deviceId.split('_').first;
    final icon = Constants.deviceImages[deviceType] ??
        'assets/icons/lamp-svgrepo-com.svg';

    return Card(
      color: Colors.white,
      shadowColor: Colors.black,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                icon,
                height: 50.h,
                color: isOn ? Colors.amber : Colors.grey,
              ),
              SizedBox(height: 12.h),
              Text(
                displayName,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: isOn ? Colors.black : Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Icon(
                isOn ? Icons.toggle_on : Icons.toggle_off,
                size: 50,
                color: isOn ? Colors.green : Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TemperatureWidget extends StatelessWidget {
  final double temperature;

  const _TemperatureWidget({required this.temperature});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 24.w),
      decoration: BoxDecoration(
        color: Colors.blue[100],
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.thermostat, color: Colors.blue[800]),
          SizedBox(width: 8.w),
          Text(
            '${temperature.toStringAsFixed(1)}°C',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.blue[900],
            ),
          ),
        ],
      ),
    );
  }
}
