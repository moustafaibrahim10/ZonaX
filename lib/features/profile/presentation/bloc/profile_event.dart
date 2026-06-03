import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

class FetchProfile extends ProfileEvent {}

class UpdateDriverStatusEvent extends ProfileEvent {
  final String newStatus;
  final double lat;
  final double lng;

  const UpdateDriverStatusEvent({
    required this.newStatus,
    required this.lat,
    required this.lng,
  });

  @override
  List<Object> get props => [newStatus, lat, lng];
}
