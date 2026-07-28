import 'package:bookia_app/core/models/product_model.dart';
import 'package:bookia_app/core/routing/routes.dart';
import 'package:bookia_app/core/theme/colors.dart';
import 'package:bookia_app/core/widgets/book_card.dart';
import 'package:bookia_app/core/widgets/screen_header.dart';
import 'package:bookia_app/features/book_details/presentation/book_details_screen.dart';
import 'package:bookia_app/features/wishlist/cubit/wishlist_cubit.dart';
import 'package:bookia_app/gen/locale_keys.g.dart';
import 'package:bookia_app/core/widgets/app_loader.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    context.read<WishlistCubit>().load();
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
                AppSpacing.screenWide.w,
                12.h,
                AppSpacing.screenWide.w,
                8.h,
              ),
              child: ScreenHeader(title: LocaleKeys.wishlist.tr()),
            ),
            Expanded(
              // Wishlist outcomes are toasted once, app-wide, by GlobalFeedback.
              child: BlocBuilder<WishlistCubit, WishlistState>(
                builder: (context, state) => _buildBody(context, state),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WishlistState state) {
    if (state.status.isInitialLoad && state.isEmpty) {
      return const AppLoader();
    }

    if (state.isEmpty) {
      return RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => context.read<WishlistCubit>().load(isRefresh: true),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: 120.h),
            EmptyState(
              icon: Icons.bookmark_border_rounded,
              title: LocaleKeys.empty_wishlist.tr(),
              message: LocaleKeys.empty_wishlist_hint.tr(),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => context.read<WishlistCubit>().load(isRefresh: true),
      child: GridView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(18.w, 12.h, 18.w, 100.h),
        gridDelegate: BookGrid.delegate,
        itemCount: state.items.length,
        itemBuilder: (context, index) {
          return _WishlistCard(product: state.items[index]);
        },
      ),
    );
  }
}

/// One saved book.
///
/// Its own widget because `context.select` cannot be called inside a lazy
/// grid's `itemBuilder` — provider asserts, since it has no element there to
/// scope the rebuild to.
class _WishlistCard extends StatelessWidget {
  const _WishlistCard({required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    return BookCard(
      product: product,
      variant: BookCardVariant.withRemoveBadge,
      isBusy: context.select<WishlistCubit, bool>(
        (cubit) => cubit.isBusy(product.id),
      ),
      onTap: () => Navigator.of(context).pushNamed(
        Routes.bookDetailsScreen,
        arguments: BookDetailsArgs(id: product.id, preview: product),
      ),
      onRemove: () => context.read<WishlistCubit>().toggle(product.id),
    );
  }
}
