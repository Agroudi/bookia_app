import 'package:bookia_app/core/models/product_model.dart';
import 'package:bookia_app/core/routing/routes.dart';
import 'package:bookia_app/core/theme/colors.dart';
import 'package:bookia_app/core/theme/text_style.dart';
import 'package:bookia_app/core/widgets/app_button.dart';
import 'package:bookia_app/core/widgets/app_loader.dart';
import 'package:bookia_app/core/widgets/book_card.dart';
import 'package:bookia_app/core/widgets/screen_header.dart';
import 'package:bookia_app/features/book_details/presentation/book_details_screen.dart';
import 'package:bookia_app/features/cart/cubit/cart_cubit.dart';
import 'package:bookia_app/features/home/cubit/home_cubit.dart';
import 'package:bookia_app/features/home/presentation/widgets/home_banner.dart';
import 'package:bookia_app/gen/assets.gen.dart';
import 'package:bookia_app/gen/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  // Keeps scroll position and loaded data when switching tabs.
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    context.read<HomeCubit>().load();
  }

  void _openBook(ProductModel product) => Navigator.of(context).pushNamed(
    Routes.bookDetailsScreen,
    arguments: BookDetailsArgs(id: product.id, preview: product),
  );

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => context.read<HomeCubit>().load(isRefresh: true),
          child: BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              if (state.status.isInitialLoad && !state.hasContent) {
                return const AppLoader();
              }

              if (state.status.isFailure && !state.hasContent) {
                return _HomeError(
                  message:
                      state.failure?.message ?? LocaleKeys.error_unknown.tr(),
                  onRetry: () => context.read<HomeCubit>().load(),
                );
              }

              return CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  const SliverToBoxAdapter(child: _HomeHeader()),
                  if (state.sliders.isNotEmpty)
                    SliverToBoxAdapter(
                      child: HomeBanner(sliders: state.sliders),
                    ),
                  if (state.bestSellers.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: _SectionTitle(LocaleKeys.best_seller.tr()),
                    ),
                    _BookSliver(products: state.bestSellers, onTap: _openBook),
                  ],
                  if (state.newArrivals.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: _SectionTitle(LocaleKeys.new_arrivals.tr()),
                    ),
                    _BookSliver(products: state.newArrivals, onTap: _openBook),
                  ],
                  // Clears the floating nav bar.
                  SliverToBoxAdapter(child: SizedBox(height: 100.h)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// The "Bookia" wordmark and the search entry point.
class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(13.w, 10.h, 13.w, 0),
      child: Row(
        children: [
          SvgPicture.asset(Assets.icons.bookLogo, width: 24.w, height: 24.w),
          SizedBox(width: 7.w),
          // Brand name — deliberately not translated.
          Text('Bookia', style: AppTextStyle.wordmark),
          const Spacer(),
          HeaderAction(
            tooltip: LocaleKeys.search.tr(),
            onTap: () => Navigator.of(context).pushNamed(Routes.searchScreen),
            child: SvgPicture.asset(
              Assets.icons.search,
              width: 24.w,
              height: 24.w,
              colorFilter: const ColorFilter.mode(
                AppColors.dark,
                BlendMode.srcIn,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(19.w, 24.h, 19.w, 16.h),
    child: Text(title, style: AppTextStyle.headline),
  );
}

class _BookSliver extends StatelessWidget {
  const _BookSliver({required this.products, required this.onTap});

  final List<ProductModel> products;
  final ValueChanged<ProductModel> onTap;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 19.w),
      sliver: SliverGrid.builder(
        gridDelegate: BookGrid.delegate,
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return BlocBuilder<CartCubit, CartState>(
            buildWhen: (previous, current) =>
                previous.status != current.status ||
                previous.mutation != current.mutation,
            builder: (context, _) => BookCard(
              product: product,
              onTap: () => onTap(product),
              isBusy: context.read<CartCubit>().isProductBusy(product.id),
              onBuy: () => context.read<CartCubit>().add(product.id),
            ),
          );
        },
      ),
    );
  }
}

class _HomeError extends StatelessWidget {
  const _HomeError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: 120.h),
        EmptyState(
          icon: Icons.wifi_off_rounded,
          title: LocaleKeys.error_unknown.tr(),
          message: message,
          action: SizedBox(
            width: 180.w,
            child: AppButton(label: LocaleKeys.retry.tr(), onTap: onRetry),
          ),
        ),
      ],
    );
  }
}
