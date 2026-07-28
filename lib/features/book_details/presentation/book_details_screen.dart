import 'package:bookia_app/core/models/product_model.dart';
import 'package:bookia_app/core/theme/colors.dart';
import 'package:bookia_app/core/utils/app_bidi.dart';
import 'package:bookia_app/core/theme/text_style.dart';
import 'package:bookia_app/core/utils/price_format.dart';
import 'package:bookia_app/core/widgets/app_button.dart';
import 'package:bookia_app/core/widgets/app_network_image.dart';
import 'package:bookia_app/core/widgets/back_button.dart';
import 'package:bookia_app/core/widgets/screen_header.dart';
import 'package:bookia_app/features/book_details/cubit/book_details_cubit.dart';
import 'package:bookia_app/features/cart/cubit/cart_cubit.dart';
import 'package:bookia_app/features/wishlist/cubit/wishlist_cubit.dart';
import 'package:bookia_app/gen/assets.gen.dart';
import 'package:bookia_app/gen/locale_keys.g.dart';
import 'package:bookia_app/core/widgets/app_loader.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BookDetailsArgs {
  const BookDetailsArgs({required this.id, this.preview});

  final int id;

  /// What the list screen already knew, so the page can paint instantly.
  final ProductModel? preview;
}

class BookDetailsScreen extends StatefulWidget {
  const BookDetailsScreen({super.key, required this.args});

  final BookDetailsArgs args;

  @override
  State<BookDetailsScreen> createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends State<BookDetailsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<BookDetailsCubit>().load(
      widget.args.id,
      preview: widget.args.preview,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocBuilder<BookDetailsCubit, BookDetailsState>(
          builder: (context, state) {
            final product = state.product;

            if (product == null) {
              return state.status.isFailure
                  ? _DetailsError(
                      message:
                          state.failure?.message ??
                          LocaleKeys.error_unknown.tr(),
                      onRetry: () =>
                          context.read<BookDetailsCubit>().load(widget.args.id),
                    )
                  : const AppLoader();
            }

            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.screenWide.w,
                    12.h,
                    AppSpacing.screenWide.w,
                    0,
                  ),
                  child: Row(
                    children: [
                      const AppBackButton(),
                      const Spacer(),
                      _BookmarkButton(productId: product.id),
                    ],
                  ),
                ),
                Expanded(child: _DetailsBody(product: product)),
                _BuyBar(product: product),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DetailsBody extends StatelessWidget {
  const _DetailsBody({required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenWide.w,
        18.h,
        AppSpacing.screenWide.w,
        20.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Hero(
              tag: 'book-${product.id}',
              child: AppNetworkImage(
                url: product.image,
                width: 183.w,
                height: 271.h,
                radius: 7.r,
              ),
            ),
          ),
          SizedBox(height: 22.h),
          Text(
            product.name,
            textAlign: TextAlign.center,
            style: AppTextStyle.headlineLarge.copyWith(
              color: Colors.black,
              letterSpacing: 0,
            ),
          ),
          // The design's gold subline. The API has no "format" field, so the
          // author (when the endpoint provides one) or the category stands in.
          if (product.author != null || product.category != null) ...[
            SizedBox(height: 4.h),
            Text(
              product.author ?? product.category!,
              textAlign: TextAlign.center,
              style: AppTextStyle.input.copyWith(color: AppColors.primary),
            ),
          ],
          if (product.totalPages != null) ...[
            SizedBox(height: 10.h),
            Center(child: _PagesChip(pages: product.totalPages!)),
          ],
          SizedBox(height: 20.h),
          if (product.description != null)
            Text(
              product.description!,
              textAlign: TextAlign.justify,
              // Catalogue prose is authored in its own language, independent
              // of the app locale; taking the direction from the content stops
              // an English paragraph rendering right-to-left under Arabic.
              textDirection: AppBidi.directionOf(product.description),
              style: AppTextStyle.description.copyWith(color: Colors.black),
            ),
          if (!product.isInStock) ...[
            SizedBox(height: 16.h),
            Text(
              LocaleKeys.out_of_stock.tr(args: ['0']),
              style: AppTextStyle.body.copyWith(color: AppColors.danger),
            ),
          ],
        ],
      ),
    );
  }
}

class _PagesChip extends StatelessWidget {
  const _PagesChip({required this.pages});

  final int pages;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(AppRadius.pill.r),
      border: Border.all(color: AppColors.border),
    ),
    child: Text(
      '$pages',
      style: AppTextStyle.orderMeta.copyWith(color: AppColors.secondaryText),
    ),
  );
}

/// The bookmark in the top-right corner, driven by the app-level wishlist.
class _BookmarkButton extends StatelessWidget {
  const _BookmarkButton({required this.productId});

  final int productId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WishlistCubit, WishlistState>(
      builder: (context, state) {
        final cubit = context.read<WishlistCubit>();
        final isSaved = cubit.contains(productId);
        final isBusy = cubit.isBusy(productId);

        return HeaderAction(
          tooltip: LocaleKeys.wishlist.tr(),
          onTap: isBusy ? () {} : () => cubit.toggle(productId),
          child: isBusy
              ? const AppLoader.inline()
              : AnimatedScale(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutBack,
                  scale: isSaved ? 1.15 : 1,
                  child: SvgPicture.asset(
                    Assets.icons.bookmark,
                    width: 20.w,
                    height: 22.h,
                    colorFilter: ColorFilter.mode(
                      isSaved ? AppColors.primary : AppColors.dark,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
        );
      },
    );
  }
}

/// Price on the leading edge, "Add To Cart" on the trailing one.
class _BuyBar extends StatelessWidget {
  const _BuyBar({required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenWide.w,
        12.h,
        AppSpacing.screenWide.w,
        20.h,
      ),
      color: AppColors.background,
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                PriceFormat.format(product.effectivePrice),
                style: AppTextStyle.headline.copyWith(letterSpacing: 0),
              ),
              if (product.hasDiscount)
                Text(
                  PriceFormat.format(product.price),
                  style: AppTextStyle.caption.copyWith(
                    color: AppColors.secondaryText,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
            ],
          ),
          SizedBox(width: 20.w),
          Expanded(
            // Feedback is handled once, app-wide, by GlobalFeedback.
            child: BlocBuilder<CartCubit, CartState>(
              builder: (context, state) {
                final isBusy = context.read<CartCubit>().isProductBusy(
                  product.id,
                );
                return AppButton(
                  label: LocaleKeys.add_to_cart.tr(),
                  variant: AppButtonVariant.dark,
                  isEnabled: product.isInStock && !isBusy,
                  onTap: () => context.read<CartCubit>().add(product.id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailsError extends StatelessWidget {
  const _DetailsError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Padding(
        padding: EdgeInsets.all(AppSpacing.screenWide.w),
        child: const Align(
          alignment: AlignmentDirectional.centerStart,
          child: AppBackButton(),
        ),
      ),
      Expanded(
        child: EmptyState(
          icon: Icons.error_outline_rounded,
          title: LocaleKeys.error_not_found.tr(),
          message: message,
          action: SizedBox(
            width: 180.w,
            child: AppButton(label: LocaleKeys.retry.tr(), onTap: onRetry),
          ),
        ),
      ),
    ],
  );
}
