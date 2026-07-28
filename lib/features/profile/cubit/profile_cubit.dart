import 'package:bookia_app/core/api/api_result.dart';
import 'package:bookia_app/core/api/failure.dart';
import 'package:bookia_app/core/api/load_status.dart';
import 'package:bookia_app/core/models/user_model.dart';
import 'package:bookia_app/features/profile/data/profile_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  /// Seeds itself from the cached user so the Profile screen renders a name
  /// and avatar on the first frame rather than a spinner.
  ProfileCubit(this._repo) : super(ProfileState(user: _repo.cachedUser));

  final ProfileRepository _repo;

  bool _isBusy = false;

  Future<void> load({bool isRefresh = false}) async {
    if (isClosed || _isBusy) return;
    _isBusy = true;

    emit(
      state.copyWith(
        status: state.user == null || !isRefresh
            ? LoadStatus.loading
            : LoadStatus.refreshing,
        clearFailure: true,
      ),
    );

    try {
      switch (await _repo.profile()) {
        case ApiSuccess(:final data):
          emit(state.copyWith(status: LoadStatus.success, user: data));
        case ApiFailure(:final failure):
          emit(
            state.copyWith(
              status: state.user == null
                  ? LoadStatus.failure
                  : LoadStatus.success,
              failure: failure,
            ),
          );
      }
    } finally {
      _isBusy = false;
    }
  }

  Future<void> updateProfile({
    required String name,
    String? phone,
    String? address,
    String? city,
    String? imagePath,
  }) => _mutate(
    () => _repo.updateProfile(
      name: name,
      phone: phone,
      address: address,
      city: city,
      imagePath: imagePath,
    ),
    onSuccess: (user, message) => state.copyWith(
      status: LoadStatus.success,
      user: user,
      action: ProfileAction.profileUpdated,
      message: message,
      clearFailure: true,
    ),
  );

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) => _mutate(
    () => _repo.updatePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
      newPasswordConfirmation: newPasswordConfirmation,
    ),
    onSuccess: (_, message) => state.copyWith(
      status: LoadStatus.success,
      action: ProfileAction.passwordUpdated,
      message: message,
      clearFailure: true,
    ),
  );

  Future<void> deleteAccount(String currentPassword) => _mutate(
    () => _repo.deleteAccount(currentPassword),
    onSuccess: (_, message) => state.copyWith(
      status: LoadStatus.success,
      action: ProfileAction.accountDeleted,
      message: message,
      clearFailure: true,
    ),
  );

  Future<void> contactUs({
    required String name,
    required String email,
    required String subject,
    required String message,
  }) => _mutate(
    () => _repo.contactUs(
      name: name,
      email: email,
      subject: subject,
      message: message,
    ),
    onSuccess: (_, serverMessage) => state.copyWith(
      status: LoadStatus.success,
      action: ProfileAction.messageSent,
      message: serverMessage,
      clearFailure: true,
    ),
  );

  /// Shared plumbing for the four write operations: busy guard, loading state,
  /// and uniform failure handling.
  Future<void> _mutate<T>(
    Future<ApiResult<T>> Function() action, {
    required ProfileState Function(T? data, String? message) onSuccess,
  }) async {
    if (isClosed || _isBusy) return;
    _isBusy = true;
    emit(state.copyWith(status: LoadStatus.loading, clearFailure: true));

    try {
      switch (await action()) {
        case ApiSuccess(:final data, :final message):
          if (!isClosed) emit(onSuccess(data, message));
        case ApiFailure(:final failure):
          if (!isClosed) {
            emit(state.copyWith(status: LoadStatus.success, failure: failure));
          }
      }
    } finally {
      _isBusy = false;
    }
  }
}
