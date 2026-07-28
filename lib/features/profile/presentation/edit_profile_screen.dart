import 'dart:io';

import 'package:bookia_app/core/api/api_constants.dart';
import 'package:bookia_app/core/api/failure.dart';
import 'package:bookia_app/core/theme/colors.dart';
import 'package:bookia_app/core/utils/state_feedback.dart';
import 'package:bookia_app/core/utils/validators.dart';
import 'package:bookia_app/core/widgets/app_button.dart';
import 'package:bookia_app/core/widgets/app_form_field.dart';
import 'package:bookia_app/core/widgets/app_network_image.dart';
import 'package:bookia_app/core/widgets/screen_header.dart';
import 'package:bookia_app/features/profile/cubit/profile_cubit.dart';
import 'package:bookia_app/gen/assets.gen.dart';
import 'package:bookia_app/gen/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _city;
  late final TextEditingController _address;

  /// Local path of a newly picked avatar, before it is uploaded.
  String? _pickedImagePath;

  final _serverErrors = <String, String?>{};

  @override
  void initState() {
    super.initState();
    // Prefill from whatever the profile cubit already holds.
    final user = context.read<ProfileCubit>().state.user;
    _name = TextEditingController(text: user?.name ?? '');
    _phone = TextEditingController(text: user?.phone ?? '');
    _city = TextEditingController(text: user?.city ?? '');
    _address = TextEditingController(text: user?.address ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _city.dispose();
    _address.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      // Resize on device: a 12MP camera shot is a slow upload and the server
      // only ever renders it at 121px.
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (picked == null || !mounted) return;
    setState(() => _pickedImagePath = picked.path);
  }

  void _submit() {
    setState(_serverErrors.clear);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();

    context.read<ProfileCubit>().updateProfile(
      name: _name.text,
      phone: Validators.digitsOnly(_phone.text),
      city: _city.text.trim(),
      address: _address.text.trim(),
      imagePath: _pickedImagePath,
    );
  }

  void _onState(BuildContext context, ProfileState state) {
    if (state.status.isLoading) {
      StateFeedback.loading();
      return;
    }
    if (state.action == ProfileAction.profileUpdated) {
      StateFeedback.success(
        state.message,
        fallbackKey: LocaleKeys.profile_updated,
      );
      Navigator.of(context).pop();
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
    return BlocListener<ProfileCubit, ProfileState>(
      listener: _onState,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.screen.w,
              12.h,
              AppSpacing.screen.w,
              30.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ScreenHeader(
                  title: LocaleKeys.edit_profile.tr(),
                  showBack: true,
                ),
                SizedBox(height: 30.h),
                Center(
                  child: _AvatarPicker(
                    localPath: _pickedImagePath,
                    onTap: _pickImage,
                  ),
                ),
                SizedBox(height: 34.h),
                Form(
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
                        controller: _phone,
                        hint: LocaleKeys.phone.tr(),
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        inputFormatters: AppInputFormatters.phone,
                        validator: Validators.phone,
                        errorText: _serverErrors[ApiKeys.phone],
                      ),
                      SizedBox(height: 12.h),
                      AppFormField(
                        controller: _city,
                        hint: LocaleKeys.city.tr(),
                        textInputAction: TextInputAction.next,
                        maxLength: Validators.maxName,
                        validator: Validators.city,
                        errorText: _serverErrors[ApiKeys.city],
                      ),
                      SizedBox(height: 12.h),
                      AppFormField(
                        controller: _address,
                        hint: LocaleKeys.address.tr(),
                        textInputAction: TextInputAction.done,
                        maxLength: Validators.maxAddress,
                        validator: Validators.address,
                        errorText: _serverErrors[ApiKeys.address],
                        onSubmitted: (_) => _submit(),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40.h),
                AppButton(
                  label: LocaleKeys.update_profile.tr(),
                  onTap: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The 121px avatar with the gold camera badge from the design.
class _AvatarPicker extends StatelessWidget {
  const _AvatarPicker({required this.localPath, required this.onTap});

  final String? localPath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final remoteUrl = context.select<ProfileCubit, String?>(
      (cubit) => cubit.state.user?.image,
    );

    return SizedBox(
      width: 121.w,
      height: 121.w,
      child: Stack(
        children: [
          ClipOval(
            child: SizedBox(
              width: 121.w,
              height: 121.w,
              // Shows the picked file immediately, before it is uploaded.
              child: switch ((localPath, remoteUrl)) {
                (final String path, _) => Image.file(
                  File(path),
                  fit: BoxFit.cover,
                ),
                (_, final String url) => AppNetworkImage(
                  url: url,
                  width: 121.w,
                ),
                _ => Container(color: AppColors.placeholder),
              },
            ),
          ),
          PositionedDirectional(
            bottom: 0,
            end: 0,
            child: InkResponse(
              onTap: onTap,
              radius: 24.r,
              child: Container(
                width: 32.w,
                height: 32.w,
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: SvgPicture.asset(
                    Assets.icons.camera,
                    width: 21.w,
                    height: 21.w,
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
