part of 'home_screen_cubit.dart';



abstract class HomeScreenState {
  const HomeScreenState();
}

class HomeScreenInitial extends HomeScreenState {}

class HomeScreenLoading extends HomeScreenState {}

class HomeScreenLoaded extends HomeScreenState {
  final Map<String, int> rooms; // Stores room names and number of devices
  const HomeScreenLoaded(this.rooms);
}

class HomeScreenError extends HomeScreenState {
  final String message;
  const HomeScreenError(this.message);
}