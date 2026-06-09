import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_driver_profile_usecase.dart';
import '../../domain/usecases/update_driver_status_usecase.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetDriverProfileUseCase getDriverProfileUseCase;
  final UpdateDriverStatusUseCase updateDriverStatusUseCase;

  ProfileBloc({
    required this.getDriverProfileUseCase,
    required this.updateDriverStatusUseCase,
  }) : super(ProfileInitial()) {
    on<FetchProfile>((event, emit) async {
      emit(ProfileLoading());
      
      final result = await getDriverProfileUseCase();
      
      result.fold(
        (failure) => emit(ProfileError(failure.message)),
        (profile) => emit(ProfileLoaded(profile)),
      );
    });

    on<UpdateDriverStatusEvent>((event, emit) async {
      emit(ProfileLoading());
      
      final result = await updateDriverStatusUseCase(event.newStatus, event.lat, event.lng);
      
      result.fold(
        (failure) => emit(ProfileError(failure.message)),
        (success) {
          // If successful, re-fetch profile data to refresh UI with correct status from server
          add(FetchProfile());
        },
      );
    });
  }
}
