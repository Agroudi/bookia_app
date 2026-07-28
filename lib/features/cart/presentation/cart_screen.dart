import 'package:bookia_app/core/routing/routes.dart';
import 'package:bookia_app/core/theme/colors.dart';
import 'package:bookia_app/core/theme/text_style.dart';
import 'package:bookia_app/core/utils/price_format.dart';
import 'package:bookia_app/core/widgets/app_button.dart';
import 'package:bookia_app/core/widgets/app_dialog.dart';
import 'package:bookia_app/core/widgets/screen_header.dart';
import 'package:bookia_app/features/book_details/presentation/book_details_screen.dart';
import 'package:bookia_app/features/cart/cubit/cart_cubit.dart';
import 'package:bookia_app/features/cart/data/models/cart_model.dart';
import 'package:bookia_app/features/cart/presentation/widgets/cart_item_tile.dart';
import 'package:bookia_app/gen/locale_keys.g.dart';
import 'package:bookia_app/core/widgets/app_loader.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    context.read<CartCubit>().load();
  }

  Future<void> _confirmRemove(CartItemModel item) async {
    final shouldRemove = await AppDialog.confirm(
      context,
      title: LocaleKeys.remove_from_cart_title.tr(),
      message: LocaleKeys.remove_from_cart_message.tr(args: [item.name]),
      confirmLabel: LocaleKeys.remove.tr(),
      isDestructive: true,
    );
    if (!shouldRemove || !mounted) return;
    context.read<CartCubit>().remove(item.id);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.screen.w,
                12.h,
                AppSpacing.screen.w,
                8.h,
              ),
              child: ScreenHeader(title: LocaleKeys.my_cart.tr()),
            ),
            Expanded(
              // Cart outcomes are toasted once, app-wide, by GlobalFeedback.
              child: BlocBuilder<CartCubit, CartState>(
                builder: (context, state) => _buildBody(context, state),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, CartState state) {
    if (state.status.isInitialLoad && state.isEmpty) {
      return const AppLoader();
    }

    if (state.isEmpty) {
      return RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => context.read<CartCubit>().load(isRefresh: true),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: 100.h),
            EmptyState(
              icon: Icons.shopping_cart_outlined,
              title: LocaleKeys.empty_cart.tr(),
              message: LocaleKeys.empty_cart_hint.tr(),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => context.read<CartCubit>().load(isRefresh: true),
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                AppSpacing.screen.w,
                12.h,
                AppSpacing.screen.w,
                12.h,
              ),
              itemCount: state.cart.items.length,
              separatorBuilder: (_, _) => SizedBox(height: 14.h),
              itemBuilder: (context, index) {
                final item = state.cart.items[index];
                return _CartRow(
                  item: item,
                  onRemove: () => _confirmRemove(item),
                );
              },
            ),
          ),
        ),
        _CheckoutBar(total: state.total),
      ],
    );
  }
}

/// One cart line.
///
/// A separate widget rather than inline in `itemBuilder` because
/// `context.select` is illegal inside a lazy list builder — provider cannot
/// scope the rebuild to a single item there, so it asserts. Its own widget
/// gives the select an element to attach to.
class _CartRow extends StatelessWidget {
  const _CartRow({required this.item, required this.onRemove});

  final CartItemModel item;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return CartItemTile(
      item: item,
      isBusy: context.select<CartCubit, bool>(
        (cubit) => cubit.isItemBusy(item.id),
      ),
      onIncrement: () => context.read<CartCubit>().increment(item.id),
      onDecrement: () => context.read<CartCubit>().decrement(item.id),
      onRemove: onRemove,
      onTap: () => Navigator.of(context).pushNamed(
        Routes.bookDetailsScreen,
        arguments: BookDetailsArgs(id: item.productId),
      ),
    );
  }
}

/// The "Total:" row and the gold Checkout button that sit above the nav bar.
class _CheckoutBar extends StatelessWidget {
  const _CheckoutBar({required this.total});

  final double total;

  /// Height of the floating nav card the shell draws over this screen:
  /// 65 for the bar, 12 for its bottom margin, plus the gesture inset.
  static const double _navClearance = 77;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screen.w,
        12.h,
        AppSpacing.screen.w,
        // The shell uses `extendBody`, so the body runs *under* the nav card.
        // Without this the total and the checkout button hide behind it.
        _navClearance.h + MediaQuery.paddingOf(context).bottom,
      ),
      color: AppColors.background,
      child: Column(
        children: [
          Row(
            children: [
              Text(LocaleKeys.total.tr(), style: AppTextStyle.totalLabel),
              const Spacer(),
              Text(PriceFormat.format(total), style: AppTextStyle.totalValue),
            ],
          ),
          SizedBox(height: 18.h),
          AppButton(
            label: LocaleKeys.checkout.tr(),
            variant: AppButtonVariant.checkout,
            onTap: () =>
                Navigator.of(context).pushNamed(Routes.placeOrderScreen),
          ),
        ],
      ),
    );
  }
}
