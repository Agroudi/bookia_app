part of 'orders_cubit.dart';

/// One state object covers history, details and checkout because they belong
/// to the same flow and share a failure channel; each has its own status field
/// so a details load never blanks the history list behind it.
class OrdersState {
  const OrdersState({
    this.status = LoadStatus.initial,
    this.orders = const Paginated<OrderSummary>.empty(),
    this.isLoadingMore = false,
    this.detailsStatus = LoadStatus.initial,
    this.details,
    this.checkoutStatus = LoadStatus.initial,
    this.checkout,
    this.governorates = const [],
    this.submitStatus = LoadStatus.initial,
    this.placedOrderId,
    this.message,
    this.failure,
  });

  final LoadStatus status;
  final Paginated<OrderSummary> orders;
  final bool isLoadingMore;

  final LoadStatus detailsStatus;
  final OrderDetails? details;

  final LoadStatus checkoutStatus;
  final CheckoutModel? checkout;
  final List<GovernorateModel> governorates;

  final LoadStatus submitStatus;

  /// Set once the server accepts the order, so the screen can navigate on.
  final int? placedOrderId;

  final String? message;
  final AppFailure? failure;

  bool get isEmpty => orders.isEmpty;
  bool get canSubmit => governorates.isNotEmpty;

  OrdersState copyWith({
    LoadStatus? status,
    Paginated<OrderSummary>? orders,
    bool? isLoadingMore,
    LoadStatus? detailsStatus,
    OrderDetails? details,
    LoadStatus? checkoutStatus,
    CheckoutModel? checkout,
    List<GovernorateModel>? governorates,
    LoadStatus? submitStatus,
    int? placedOrderId,
    String? message,
    AppFailure? failure,
    bool clearFailure = false,
    bool clearDetails = false,
  }) => OrdersState(
    status: status ?? this.status,
    orders: orders ?? this.orders,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    detailsStatus: detailsStatus ?? this.detailsStatus,
    details: clearDetails ? null : (details ?? this.details),
    checkoutStatus: checkoutStatus ?? this.checkoutStatus,
    checkout: checkout ?? this.checkout,
    governorates: governorates ?? this.governorates,
    submitStatus: submitStatus ?? this.submitStatus,
    // One-shot: cleared on the next emit so the success listener fires once.
    placedOrderId: placedOrderId,
    message: message,
    failure: clearFailure ? null : (failure ?? this.failure),
  );
}
