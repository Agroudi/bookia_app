import 'package:bookia_app/core/models/product_model.dart';
import 'package:bookia_app/core/routing/routes.dart';
import 'package:bookia_app/core/theme/colors.dart';
import 'package:bookia_app/core/theme/text_style.dart';
import 'package:bookia_app/core/utils/validators.dart';
import 'package:bookia_app/core/widgets/back_button.dart';
import 'package:bookia_app/core/widgets/book_card.dart';
import 'package:bookia_app/core/widgets/screen_header.dart';
import 'package:bookia_app/features/book_details/presentation/book_details_screen.dart';
import 'package:bookia_app/features/cart/cubit/cart_cubit.dart';
import 'package:bookia_app/features/search/cubit/search_cubit.dart';
import 'package:bookia_app/gen/assets.gen.dart';
import 'package:bookia_app/gen/locale_keys.g.dart';
import 'package:bookia_app/core/widgets/app_loader.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  /// Pages in the next results once the user is within a screen of the end.
  void _onScroll() {
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 400) {
      context.read<SearchCubit>().loadMore();
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
                0,
              ),
              child: Row(
                children: [
                  const AppBackButton(),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _SearchField(
                      controller: _controller,
                      onChanged: (value) =>
                          context.read<SearchCubit>().onQueryChanged(value),
                      onClear: () {
                        _controller.clear();
                        context.read<SearchCubit>().clear();
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<SearchCubit, SearchState>(
                builder: (context, state) => _buildResults(context, state),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults(BuildContext context, SearchState state) {
    if (state.isIdle) {
      return EmptyState(
        icon: Icons.search_rounded,
        title: LocaleKeys.search_store.tr(),
        message: LocaleKeys.empty_search_hint.tr(),
      );
    }

    if (state.status.isLoading && state.items.isEmpty) {
      return const AppLoader();
    }

    if (state.status.isFailure && state.items.isEmpty) {
      return EmptyState(
        icon: Icons.error_outline_rounded,
        title: LocaleKeys.error_unknown.tr(),
        message: state.failure?.message ?? LocaleKeys.error_unknown.tr(),
      );
    }

    if (state.isEmptyResult) {
      return EmptyState(
        icon: Icons.menu_book_rounded,
        title: LocaleKeys.empty_search.tr(),
        message: LocaleKeys.empty_search_hint.tr(),
      );
    }

    return GridView.builder(
      controller: _scrollController,
      padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 30.h),
      gridDelegate: BookGrid.delegate,
      // One extra cell carries the "loading next page" spinner.
      itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= state.items.length) {
          return const AppLoader.pagination();
        }

        return _ResultCard(product: state.items[index]);
      },
    );
  }
}

/// One search result.
///
/// Its own widget because `context.select` is illegal inside a lazy grid's
/// `itemBuilder`.
class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    return BookCard(
      product: product,
      isBusy: context.select<CartCubit, bool>(
        (cubit) => cubit.isProductBusy(product.id),
      ),
      onTap: () => Navigator.of(context).pushNamed(
        Routes.bookDetailsScreen,
        arguments: BookDetailsArgs(id: product.id, preview: product),
      ),
      onBuy: () => context.read<CartCubit>().add(product.id),
    );
  }
}

/// The 333x52, r15 search field from the design.
class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52.h,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        autofocus: true,
        textInputAction: TextInputAction.search,
        maxLength: Validators.maxSearch,
        cursorColor: AppColors.primary,
        style: AppTextStyle.input.copyWith(color: AppColors.dark),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: AppColors.white,
          hintText: LocaleKeys.search_store.tr(),
          hintStyle: AppTextStyle.input.copyWith(
            color: const Color(0xFF7C7C7C),
          ),
          prefixIcon: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            child: SvgPicture.asset(
              Assets.icons.search,
              width: 19.w,
              height: 18.h,
              colorFilter: const ColorFilter.mode(
                Color(0xFF181B19),
                BlendMode.srcIn,
              ),
            ),
          ),
          prefixIconConstraints: BoxConstraints(minWidth: 47.w),
          suffixIcon: ValueListenableBuilder(
            valueListenable: controller,
            builder: (context, value, _) => value.text.isEmpty
                ? const SizedBox.shrink()
                : IconButton(
                    onPressed: onClear,
                    icon: Icon(
                      Icons.close_rounded,
                      size: 20.sp,
                      color: AppColors.secondaryText,
                    ),
                  ),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 14.h),
          border: _border,
          enabledBorder: _border,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.searchField.r),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
        ),
      ),
    );
  }

  OutlineInputBorder get _border => OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppRadius.searchField.r),
    borderSide: const BorderSide(color: AppColors.border),
  );
}
