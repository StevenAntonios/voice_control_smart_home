part of 'devices_status_cubit.dart';

abstract class DeviceControlState  {
  const DeviceControlState();
  List<Object> get props => [];
}

class DeviceControlInitial extends DeviceControlState {}

class DeviceControlLoading extends DeviceControlState {}

class DeviceStatusUpdated extends DeviceControlState {
  final Map<String, int> status;
  const DeviceStatusUpdated(this.status);
  @override
  List<Object> get props => [status];
}

class TemperatureUpdated extends DeviceControlState {
  final double temperature;
  const TemperatureUpdated(this.temperature);
  @override
  List<Object> get props => [temperature];
}

class DeviceControlError extends DeviceControlState {
  final String message;
  const DeviceControlError(this.message);
  @override
  List<Object> get props => [message];
}