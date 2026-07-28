/// Where a screen's data currently stands.
///
/// Shared by every list/detail cubit so the UI can branch the same way
/// everywhere. [refreshing] is distinct from [loading] because a pull-to-
/// refresh must keep showing the existing content rather than blanking it.
enum LoadStatus {
  initial,
  loading,
  refreshing,
  success,
  failure;

  bool get isLoading => this == LoadStatus.loading;
  bool get isRefreshing => this == LoadStatus.refreshing;
  bool get isSuccess => this == LoadStatus.success;
  bool get isFailure => this == LoadStatus.failure;

  /// True on the very first load, when there is nothing on screen yet.
  bool get isInitialLoad =>
      this == LoadStatus.initial || this == LoadStatus.loading;
}
