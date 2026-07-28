part of 'profile_cubit.dart';

/// The write that just completed, so each screen can react only to its own.
enum ProfileAction {
  none,
  profileUpdated,
  passwordUpdated,
  accountDeleted,
  messageSent,
}

class ProfileState {
  const ProfileState({
    this.status = LoadStatus.initial,
    this.user,
    this.action = ProfileAction.none,
    this.message,
    this.failure,
  });

  final LoadStatus status;
  final UserModel? user;
  final ProfileAction action;
  final String? message;
  final AppFailure? failure;

  ProfileState copyWith({
    LoadStatus? status,
    UserModel? user,
    ProfileAction? action,
    String? message,
    AppFailure? failure,
    bool clearFailure = false,
  }) => ProfileState(
    status: status ?? this.status,
    user: user ?? this.user,
    // Actions are one-shot: they must not survive into the next emit, or a
    // listener would fire again on an unrelated rebuild.
    action: action ?? ProfileAction.none,
    message: message,
    failure: clearFailure ? null : (failure ?? this.failure),
  );
}
