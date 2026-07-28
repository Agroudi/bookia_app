import 'package:bookia_app/core/api/api_constants.dart';
import 'package:bookia_app/core/api/failure.dart';
import 'package:bookia_app/core/routing/routes.dart';
import 'package:bookia_app/core/theme/colors.dart';
import 'package:bookia_app/core/theme/text_style.dart';
import 'package:bookia_app/core/utils/price_format.dart';
import 'package:bookia_app/core/utils/state_feedback.dart';
import 'package:bookia_app/core/utils/validators.dart';
import 'package:bookia_app/core/widgets/app_button.dart';
import 'package:bookia_app/core/widgets/app_form_field.dart';
import 'package:bookia_app/core/widgets/back_button.dart';
import 'package:bookia_app/features/cart/cubit/cart_cubit.dart';
import 'package:bookia_app/features/orders/cubit/orders_cubit.dart';
import 'package:bookia_app/features/orders/data/models/order_model.dart';
import 'package:bookia_app/features/orders/presentation/widgets/governorate_sheet.dart';
import 'package:bookia_app/features/profile/cubit/profile_cubit.dart';
import 'package:bookia_app/gen/assets.gen.dart';
import 'package:bookia_app/gen/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PlaceOrderScreen extends StatefulWidget {
  const PlaceOrderScreen({super.key});

  @override
  State<PlaceOrderScreen> createState() => _PlaceOrderScreenState();
}

class _PlaceOrderScreenState extends State<PlaceOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _address;
  final _governorate = TextEditingController();

  GovernorateModel? _selectedGovernorate;
  final _serverErrors = <String, String?>{};

  @override
  void initState() {
    super.initState();
    // Prefill from the profile, then let /checkout override with whatever the
    // server has on file for delivery.
    final user = context.read<ProfileCubit>().state.user;
    _name = TextEditingController(text: user?.name ?? '');
    _email = TextEditingController(text: user?.email ?? '');
    _phone = TextEditingController(text: user?.phone ?? '');
    _address = TextEditingController(text: user?.address ?? '');

    context.read<OrdersCubit>().loadCheckout();
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _address.dispose();
    _governorate.dispose();
    super.dispose();
  }

  Future<void> _pickGovernorate() async {
    final options = context.read<OrdersCubit>().state.governorates;
    if (options.isEmpty) return;

    final selected = await GovernorateSheet.show(context, options: options);
    if (selected == null || !mounted) return;

    setState(() {
      _selectedGovernorate = selected;
      _governorate.text = selected.nameFor(context.locale.languageCode);
      _serverErrors.remove(ApiKeys.governorateId);
    });
  }

  void _submit() {
    setState(_serverErrors.clear);
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final governorate = _selectedGovernorate;
    if (governorate == null) {
      setState(
        () => _serverErrors[ApiKeys.governorateId] = LocaleKeys
            .governorate_required
            .tr(),
      );
      return;
    }

    FocusScope.of(context).unfocus();
    context.read<OrdersCubit>().placeOrder(
      governorateId: governorate.id,
      name: Validators.sanitize(_name.text, maxLength: Validators.maxName),
      phone: Validators.digitsOnly(_phone.text),
      address: Validators.sanitize(
        _address.text,
        maxLength: Validators.maxAddress,
      ),
      email: Validators.sanitize(_email.text, maxLength: Validators.maxEmail),
    );
  }

  void _onState(BuildContext context, OrdersState state) {
    if (state.submitStatus.isLoading) {
      StateFeedback.loading();
      return;
    }

    if (state.placedOrderId != null) {
      StateFeedback.success(
        state.message,
        fallbackKey: LocaleKeys.order_placed,
      );
      // The order consumed the cart, so refresh it before going back to the
      // shell — otherwise the badge would still show the old count.
      context.read<CartCubit>().load(isRefresh: true);
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(Routes.layoutScreen, (route) => false);
      return;
    }

    if (state.failure case final failure?) {
      if (failure is ValidationFailure) {
        setState(() {
          for (final field in failure.fieldErrors.keys) {
            _serverErrors[field] = failure.errorFor(field);
          }
        });
      }
      StateFeedback.failure(failure, silent: _serverErrors.isNotEmpty);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrdersCubit, OrdersState>(
      listenWhen: (previous, current) =>
          previous.submitStatus != current.submitStatus ||
          previous.placedOrderId != current.placedOrderId ||
          previous.failure != current.failure,
      listener: _onState,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(22.w, 12.h, 22.w, 20.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppBackButton(),
                      SizedBox(height: 22.h),
                      Text(
                        LocaleKeys.place_your_order.tr(),
                        style: AppTextStyle.headlineLarge,
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        LocaleKeys.place_order_statement.tr(),
                        style: AppTextStyle.body.copyWith(
                          color: AppColors.hint,
                          height: 24 / 16,
                        ),
                      ),
                      SizedBox(height: 24.h),
                      _buildForm(),
                    ],
                  ),
                ),
              ),
              _SubmitBar(onSubmit: _submit),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppFormField(
            controller: _name,
            hint: LocaleKeys.full_name.tr(),
            textInputAction: TextInputAction.next,
            maxLength: Validators.maxName,
            validator: Validators.name,
            errorText: _serverErrors[ApiKeys.name],
          ),
          SizedBox(height: 12.h),
          AppFormField(
            controller: _email,
            hint: LocaleKeys.email.tr(),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            maxLength: Validators.maxEmail,
            inputFormatters: AppInputFormatters.noWhitespace,
            validator: Validators.email,
            errorText: _serverErrors[ApiKeys.email],
          ),
          SizedBox(height: 12.h),
          AppFormField(
            controller: _address,
            hint: LocaleKeys.address.tr(),
            textInputAction: TextInputAction.next,
            maxLength: Validators.maxAddress,
            validator: Validators.address,
            errorText: _serverErrors[ApiKeys.address],
          ),
          SizedBox(height: 12.h),
          AppFormField(
            controller: _phone,
            hint: LocaleKeys.phone.tr(),
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            inputFormatters: AppInputFormatters.phone,
            validator: Validators.phone,
            errorText: _serverErrors[ApiKeys.phone],
          ),
          SizedBox(height: 12.h),
          BlocBuilder<OrdersCubit, OrdersState>(
            buildWhen: (previous, current) =>
                previous.governorates != current.governorates,
            builder: (context, state) => AppFormField(
              controller: _governorate,
              hint: LocaleKeys.governorate.tr(),
              // Opens the picker sheet instead of a keyboard.
              readOnly: true,
              enabled: state.governorates.isNotEmpty,
              onTap: _pickGovernorate,
              errorText: _serverErrors[ApiKeys.governorateId],
              suffix: Padding(
                padding: EdgeInsets.all(16.w),
                child: SvgPicture.asset(
                  Assets.icons.arrowDown,
                  width: 16.w,
                  height: 10.h,
                  colorFilter: const ColorFilter.mode(
                    AppColors.dropdownArrow,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Total plus the submit button, pinned to the bottom.
class _SubmitBar extends StatelessWidget {
  const _SubmitBar({required this.onSubmit});

  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(22.w, 12.h, 22.w, 20.h),
      color: AppColors.background,
      child: Column(
        children: [
          BlocBuilder<CartCubit, CartState>(
            builder: (context, cartState) => Row(
              children: [
                Text(LocaleKeys.total.tr(), style: AppTextStyle.totalLabel),
                const Spacer(),
                Text(
                  PriceFormat.format(cartState.total),
                  style: AppTextStyle.totalValue,
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          AppButton(
            label: LocaleKeys.submit_order.tr(),
            // Nothing can be submitted until the governorate list arrives,
            // since the API rejects an order without a valid governorate_id.
            isEnabled: context.select<OrdersCubit, bool>(
              (cubit) => cubit.state.canSubmit,
            ),
            onTap: onSubmit,
          ),
        ],
      ),
    );
  }
}
