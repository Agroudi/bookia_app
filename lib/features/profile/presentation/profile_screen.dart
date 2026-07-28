import 'package:bookia_app/core/routing/routes.dart';
import 'package:bookia_app/core/theme/colors.dart';
import 'package:bookia_app/core/theme/text_style.dart';
import 'package:bookia_app/core/utils/state_feedback.dart';
import 'package:bookia_app/core/widgets/app_dialog.dart';
import 'package:bookia_app/core/widgets/app_network_image.dart';
import 'package:bookia_app/core/widgets/screen_header.dart';
import 'package:bookia_app/features/auth/cubit/auth_cubit.dart';
import 'package:bookia_app/features/cart/cubit/cart_cubit.dart';
import 'package:bookia_app/features/profile/cubit/profile_cubit.dart';
import 'package:bookia_app/features/profile/presentation/widgets/profile_menu_tile.dart';
import 'package:bookia_app/features/wishlist/cubit/wishlist_cubit.dart';
import 'package:bookia_app/gen/assets.gen.dart';
import 'package:bookia_app/gen/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    context.read<ProfileCubit>().load();
  }

  Future<void> _confirmLogout() async {
    final shouldLogout = await AppDialog.confirm(
      context,
      title: LocaleKeys.logout_title.tr(),
      message: LocaleKeys.logout_message.tr(),
      confirmLabel: LocaleKeys.logout.tr(),
      isDestructive: true,
    );
    if (!shouldLogout || !mounted) return;

    // Drop the cached cart and wishlist before the request so the next user
    // can never see the previous one's data, even briefly.
    context.read<CartCubit>().clear();
    context.read<WishlistCubit>().clear();
    context.read<AuthCubit>().logout();
  }

  void _onAuthState(BuildContext context, AuthState state) {
    switch (state) {
      case AuthLoading():
        StateFeedback.loading();
      case LoggedOut():
        StateFeedback.done();
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(Routes.loginScreen, (route) => false);
      case AuthFailed(:final failure):
        StateFeedback.failure(failure);
      default:
        break;
    }
  }

  void _onProfileState(BuildContext context, ProfileState state) {
    if (state.action == ProfileAction.accountDeleted) {
      StateFeedback.success(state.message);
      context.read<CartCubit>().clear();
      context.read<WishlistCubit>().clear();
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(Routes.loginScreen, (route) => false);
      return;
    }
    if (state.failure != null) StateFeedback.failure(state.failure!);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return MultiBlocListener(
      listeners: [
        BlocListener<AuthCubit, AuthState>(listener: _onAuthState),
        BlocListener<ProfileCubit, ProfileState>(
          listenWhen: (previous, current) =>
              current.action != ProfileAction.none ||
              (current.failure != null && previous.failure != current.failure),
          listener: _onProfileState,
        ),
      ],
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          bottom: false,
          child: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => context.read<ProfileCubit>().load(isRefresh: true),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                AppSpacing.screenTight.w,
                12.h,
                AppSpacing.screenTight.w,
                110.h,
              ),
              children: [
                ScreenHeader(
                  title: LocaleKeys.profile.tr(),
                  trailing: HeaderAction(
                    tooltip: LocaleKeys.logout.tr(),
                    onTap: _confirmLogout,
                    // The glyph is an arrow leaving a door; "out" is the
                    // trailing direction, so it mirrors under Arabic.
                    child: Transform.flip(
                      flipX: Directionality.of(context) == TextDirection.rtl,
                      child: SvgPicture.asset(
                        Assets.icons.logout,
                        width: 20.w,
                        height: 20.w,
                        colorFilter: const ColorFilter.mode(
                          AppColors.dark,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                const _ProfileHeader(),
                SizedBox(height: 34.h),
                ..._menuItems(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _menuItems(BuildContext context) {
    final entries = <(String, VoidCallback)>[
      (
        LocaleKeys.my_orders.tr(),
        () => Navigator.of(context).pushNamed(Routes.orderHistoryScreen),
      ),
      (
        LocaleKeys.edit_profile.tr(),
        () => Navigator.of(context).pushNamed(Routes.editProfileScreen),
      ),
      (
        LocaleKeys.reset_password.tr(),
        () => Navigator.of(context).pushNamed(Routes.updatePasswordScreen),
      ),
      (
        LocaleKeys.faq.tr(),
        () => Navigator.of(context).pushNamed(Routes.faqScreen),
      ),
      (
        LocaleKeys.contact_us.tr(),
        () => Navigator.of(context).pushNamed(Routes.contactUsScreen),
      ),
    ];

    return [
      for (final (label, onTap) in entries) ...[
        ProfileMenuTile(label: label, onTap: onTap),
        SizedBox(height: 10.h),
      ],
      const _LanguageTile(),
      SizedBox(height: 10.h),
      ProfileMenuTile(
        label: LocaleKeys.delete_account.tr(),
        isDestructive: true,
        onTap: () => _DeleteAccountSheet.show(context),
      ),
    ];
  }
}

/// Avatar, name and email.
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        final user = state.user;

        return Row(
          children: [
            ClipOval(
              child: SizedBox(
                width: 80.w,
                height: 80.w,
                child: user?.image == null
                    ? Container(color: AppColors.placeholder)
                    : AppNetworkImage(url: user!.image, width: 80.w),
              ),
            ),
            SizedBox(width: 13.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    user?.name ?? '—',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.title.copyWith(
                      color: AppColors.heading,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    user?.email ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.caption.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Language switch, styled as a menu row so it sits naturally in the list.
class _LanguageTile extends StatelessWidget {
  const _LanguageTile();

  @override
  Widget build(BuildContext context) {
    final isArabic = context.locale.languageCode == 'ar';

    return ProfileMenuTile(
      label:
          '${LocaleKeys.language.tr()}  ·  '
          '${isArabic ? LocaleKeys.arabic.tr() : LocaleKeys.english.tr()}',
      onTap: () =>
          context.setLocale(isArabic ? const Locale('en') : const Locale('ar')),
    );
  }
}

/// Account deletion needs the current password, so it asks for it in a sheet
/// rather than deleting straight from a confirmation dialog.
class _DeleteAccountSheet extends StatefulWidget {
  const _DeleteAccountSheet();

  static Future<void> show(BuildContext context) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => BlocProvider.value(
      value: context.read<ProfileCubit>(),
      child: const _DeleteAccountSheet(),
    ),
  );

  @override
  State<_DeleteAccountSheet> createState() => _DeleteAccountSheetState();
}

class _DeleteAccountSheetState extends State<_DeleteAccountSheet> {
  final _password = TextEditingController();

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.sheet.r),
          ),
        ),
        padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 30.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              LocaleKeys.delete_account_title.tr(),
              textAlign: TextAlign.center,
              style: AppTextStyle.title,
            ),
            SizedBox(height: 10.h),
            Text(
              LocaleKeys.delete_account_message.tr(),
              textAlign: TextAlign.center,
              style: AppTextStyle.body.copyWith(color: AppColors.secondaryText),
            ),
            SizedBox(height: 20.h),
            _PasswordField(controller: _password),
            SizedBox(height: 20.h),
            _DeleteButton(password: _password),
          ],
        ),
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    obscureText: true,
    cursorColor: AppColors.primary,
    style: AppTextStyle.input.copyWith(color: AppColors.dark),
    decoration: InputDecoration(
      filled: true,
      fillColor: AppColors.background,
      hintText: LocaleKeys.current_password.tr(),
      hintStyle: AppTextStyle.input.copyWith(color: AppColors.hint),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input.r),
        borderSide: const BorderSide(color: AppColors.border),
      ),
    ),
  );
}

class _DeleteButton extends StatelessWidget {
  const _DeleteButton({required this.password});

  final TextEditingController password;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: password,
      builder: (context, value, _) => FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.danger,
          minimumSize: Size(double.infinity, 56.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.input.r),
          ),
        ),
        // Disabled until something is typed, so an empty request never leaves
        // the device.
        onPressed: value.text.isEmpty
            ? null
            : () {
                Navigator.of(context).pop();
                context.read<ProfileCubit>().deleteAccount(value.text);
              },
        child: Text(
          LocaleKeys.delete_account.tr(),
          style: AppTextStyle.title.copyWith(color: AppColors.white),
        ),
      ),
    );
  }
}
