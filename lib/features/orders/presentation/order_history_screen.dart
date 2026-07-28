import 'package:bookia_app/core/routing/routes.dart';
import 'package:bookia_app/core/theme/colors.dart';
import 'package:bookia_app/core/theme/text_style.dart';
import 'package:bookia_app/core/utils/price_format.dart';
import 'package:bookia_app/core/widgets/screen_header.dart';
import 'package:bookia_app/features/orders/cubit/orders_cubit.dart';
import 'package:bookia_app/features/orders/data/models/order_model.dart';
import 'package:bookia_app/gen/locale_keys.g.dart';
import 'package:bookia_app/core/widgets/app_loader.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<OrdersCubit>().loadHistory();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 300) {
      context.read<OrdersCubit>().loadMoreHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.screenWide.w,
                12.h,
                AppSpacing.screenWide.w,
                12.h,
              ),
              child: ScreenHeader(
                title: LocaleKeys.my_orders.tr(),
                showBack: true,
              ),
            ),
            Expanded(
              child: BlocBuilder<OrdersCubit, OrdersState>(
                builder: (context, state) {
                  if (state.status.isInitialLoad && state.isEmpty) {
                    return const AppLoader();
                  }

                  if (state.status.isFailure && state.isEmpty) {
                    return EmptyState(
                      icon: Icons.error_outline_rounded,
                      title: LocaleKeys.error_unknown.tr(),
                      message:
                          state.failure?.message ??
                          LocaleKeys.error_unknown.tr(),
                    );
                  }

                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () => context.read<OrdersCubit>().loadHistory(
                      isRefresh: true,
                    ),
                    child: state.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(height: 100.h),
                              EmptyState(
                                icon: Icons.receipt_long_outlined,
                                title: LocaleKeys.empty_orders.tr(),
                                message: LocaleKeys.empty_orders_hint.tr(),
                              ),
                            ],
                          )
                        : ListView.separated(
                            controller: _scrollController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: EdgeInsets.fromLTRB(
                              AppSpacing.screenWide.w,
                              0,
                              AppSpacing.screenWide.w,
                              30.h,
                            ),
                            itemCount:
                                state.orders.items.length +
                                (state.isLoadingMore ? 1 : 0),
                            separatorBuilder: (_, _) => SizedBox(height: 14.h),
                            itemBuilder: (context, index) {
                              if (index >= state.orders.items.length) {
                                return const AppLoader.pagination();
                              }
                              return OrderCard(
                                order: state.orders.items[index],
                              );
                            },
                          ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The 335x163, r6 order card, with the "Detail" button flush to the leading
/// edge as the design draws it.
class OrderCard extends StatelessWidget {
  const OrderCard({super.key, required this.order});

  final OrderSummary order;

  /// The API's status strings ("New", "Delivered", "Rejected") map onto the
  /// design's green; anything unrecognised falls back to the neutral grey.
  Color get _statusColor => switch (order.status.toLowerCase()) {
    'delivered' || 'completed' || 'accepted' => AppColors.success,
    'rejected' || 'cancelled' || 'canceled' => AppColors.danger,
    _ => AppColors.primary,
  };

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.tile.r);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: radius,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(21.w, 14.h, 21.w, 10.h),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    LocaleKeys.order_no.tr(args: [order.code]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.orderBody.copyWith(color: Colors.black),
                  ),
                ),
                Text(order.date, style: AppTextStyle.orderMeta),
              ],
            ),
          ),
          Container(height: 2.h, color: AppColors.divider),
          Padding(
            padding: EdgeInsets.fromLTRB(21.w, 14.h, 21.w, 14.h),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    LocaleKeys.total_amount.tr(
                      args: [PriceFormat.format(order.total)],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.orderBody.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              _DetailButton(orderId: order.id),
              const Spacer(),
              Padding(
                // Directional: the status sits on the trailing edge, which is
                // the left under an Arabic locale.
                padding: EdgeInsetsDirectional.fromSTEB(0, 0, 21.w, 14.h),
                child: Text(
                  order.status,
                  style: AppTextStyle.orderBody.copyWith(color: _statusColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailButton extends StatelessWidget {
  const _DetailButton({required this.orderId});

  final int orderId;

  @override
  Widget build(BuildContext context) {
    // Square on the outer edge, rounded on the inner one — mirrored for RTL.
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final radius = BorderRadius.horizontal(
      left: Radius.circular(isRtl ? AppRadius.pill.r : 0),
      right: Radius.circular(isRtl ? 0 : AppRadius.pill.r),
    );

    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Material(
        color: Colors.black,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: () => Navigator.of(
            context,
          ).pushNamed(Routes.orderDetailsScreen, arguments: orderId),
          child: Container(
            width: 100.w,
            height: 34.h,
            alignment: Alignment.center,
            child: Text(
              LocaleKeys.detail.tr(),
              style: AppTextStyle.orderBody.copyWith(color: AppColors.white),
            ),
          ),
        ),
      ),
    );
  }
}
