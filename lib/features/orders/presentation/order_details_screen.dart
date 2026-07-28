import 'package:bookia_app/core/api/load_status.dart';
import 'package:bookia_app/core/theme/colors.dart';
import 'package:bookia_app/core/theme/text_style.dart';
import 'package:bookia_app/core/utils/price_format.dart';
import 'package:bookia_app/core/widgets/screen_header.dart';
import 'package:bookia_app/features/orders/cubit/orders_cubit.dart';
import 'package:bookia_app/features/orders/data/models/order_model.dart';
import 'package:bookia_app/gen/locale_keys.g.dart';
import 'package:bookia_app/core/widgets/app_loader.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// The two Figma "order details" frames use a different design system from
/// the rest of the app (Sora/Poppins on white, pill controls). This screen
/// keeps their *content* — address, line items, payment summary — but renders
/// it in the app's own language so it doesn't look like a different product.
class OrderDetailsScreen extends StatefulWidget {
  const OrderDetailsScreen({super.key, required this.orderId});

  final int orderId;

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<OrdersCubit>().loadOrder(widget.orderId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocBuilder<OrdersCubit, OrdersState>(
          builder: (context, state) {
            final order = state.details;

            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.screenWide.w,
                    12.h,
                    AppSpacing.screenWide.w,
                    12.h,
                  ),
                  child: ScreenHeader(
                    title: order == null
                        ? LocaleKeys.order_details.tr()
                        : '#${order.code}',
                    showBack: true,
                  ),
                ),
                Expanded(
                  child: switch (state.detailsStatus) {
                    LoadStatus.failure => EmptyState(
                      icon: Icons.error_outline_rounded,
                      title: LocaleKeys.error_not_found.tr(),
                      message:
                          state.failure?.message ??
                          LocaleKeys.error_unknown.tr(),
                    ),
                    _ when order == null => const AppLoader(),
                    _ => _OrderBody(order: order),
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _OrderBody extends StatelessWidget {
  const _OrderBody({required this.order});

  final OrderDetails order;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenWide.w,
        0,
        AppSpacing.screenWide.w,
        30.h,
      ),
      children: [
        _Card(
          title: LocaleKeys.order_status.tr(),
          children: [
            _Row(label: LocaleKeys.order_status.tr(), value: order.status),
            _Row(label: LocaleKeys.order_date.tr(), value: order.date),
            if (order.rejectDetails case final reason?)
              _Row(
                label: LocaleKeys.notes.tr(),
                value: reason,
                valueColor: AppColors.danger,
              ),
          ],
        ),
        SizedBox(height: 14.h),
        _Card(
          title: LocaleKeys.address.tr(),
          children: [
            if (order.name case final name?)
              _Row(label: LocaleKeys.full_name.tr(), value: name),
            if (order.phone case final phone?)
              _Row(label: LocaleKeys.phone.tr(), value: phone),
            if (order.governorate case final governorate?)
              _Row(label: LocaleKeys.governorate.tr(), value: governorate),
            if (order.address case final address?)
              _Row(label: LocaleKeys.address.tr(), value: address),
          ],
        ),
        SizedBox(height: 14.h),
        _Card(
          title: LocaleKeys.my_orders.tr(),
          children: [
            for (final product in order.products) _ProductRow(product: product),
          ],
        ),
        SizedBox(height: 14.h),
        _Card(
          title: LocaleKeys.total.tr(),
          children: [
            _Row(
              label: LocaleKeys.sub_total.tr(),
              value: PriceFormat.format(order.subTotal),
            ),
            if (order.discount > 0)
              _Row(
                label: LocaleKeys.discount.tr(),
                value: '${order.discount}%',
              ),
            if (order.tax case final tax? when tax > 0)
              _Row(label: LocaleKeys.tax.tr(), value: PriceFormat.format(tax)),
            Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: Row(
                children: [
                  Text(LocaleKeys.total.tr(), style: AppTextStyle.totalLabel),
                  const Spacer(),
                  Text(
                    PriceFormat.format(order.total),
                    style: AppTextStyle.totalValue,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: EdgeInsets.all(18.w),
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(AppRadius.tile.r),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyle.subtitle),
        SizedBox(height: 10.h),
        ...children,
      ],
    ),
  );
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(vertical: 5.h),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyle.orderMeta.copyWith(
            color: AppColors.secondaryText,
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: AppTextStyle.orderBody.copyWith(
              color: valueColor ?? AppColors.heading,
            ),
          ),
        ),
      ],
    ),
  );
}

class _ProductRow extends StatelessWidget {
  const _ProductRow({required this.product});

  final OrderProduct product;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(vertical: 7.h),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.body.copyWith(color: AppColors.label),
              ),
              Text(
                '${product.quantity} × ${PriceFormat.format(product.unitPrice)}',
                style: AppTextStyle.orderMeta,
              ),
            ],
          ),
        ),
        SizedBox(width: 12.w),
        Text(
          PriceFormat.format(product.lineTotal),
          style: AppTextStyle.orderBody,
        ),
      ],
    ),
  );
}
