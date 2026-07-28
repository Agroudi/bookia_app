import 'package:bookia_app/core/theme/colors.dart';
import 'package:bookia_app/core/theme/text_style.dart';
import 'package:bookia_app/core/utils/validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// The 331x56, r8 white input from the design.
///
/// Password visibility is handled internally so no screen has to hold that
/// piece of state, and `maxLength` is enforced at the keyboard rather than
/// only at validation time.
class AppFormField extends StatefulWidget {
  const AppFormField({
    super.key,
    required this.hint,
    this.controller,
    this.validator,
    this.isPassword = false,
    this.keyboardType,
    this.textInputAction,
    this.maxLength,
    this.maxLines = 1,
    this.enabled = true,
    this.readOnly = false,
    this.suffix,
    this.prefix,
    this.onTap,
    this.onChanged,
    this.onSubmitted,
    this.inputFormatters,
    this.autofillHints,
    this.errorText,
  });

  final String hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;

  /// Obscures the text and shows the eye toggle from the design.
  final bool isPassword;

  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final int? maxLength;
  final int maxLines;
  final bool enabled;

  /// Read-only but still tappable — used for the governorate picker, which
  /// opens a sheet instead of a keyboard.
  final bool readOnly;

  final Widget? suffix;
  final Widget? prefix;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final List<String>? autofillHints;

  /// Server-side error for this field, surfaced under the input. Set from a
  /// [ValidationFailure] so a 422 lands on the exact input that caused it.
  final String? errorText;

  @override
  State<AppFormField> createState() => _AppFormFieldState();
}

class _AppFormFieldState extends State<AppFormField> {
  late bool _obscure = widget.isPassword;

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppRadius.input.r),
    borderSide: BorderSide(color: color),
  );

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      validator: widget.validator,
      obscureText: _obscure,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      onTap: widget.onTap,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      maxLines: widget.isPassword ? 1 : widget.maxLines,
      maxLength: widget.maxLength,
      autofillHints: widget.autofillHints,
      inputFormatters: widget.inputFormatters,
      // Autocorrect on a password or an email address fights the user.
      autocorrect: !widget.isPassword,
      enableSuggestions: !widget.isPassword,
      cursorColor: AppColors.primary,
      style: AppTextStyle.input.copyWith(color: AppColors.dark),
      onTapOutside: (_) => FocusScope.of(context).unfocus(),
      decoration: InputDecoration(
        filled: true,
        // The design fills inputs white on the #F7F8F9 page — not the other
        // way round.
        fillColor: widget.enabled ? AppColors.white : AppColors.disabledField,
        hintText: widget.hint,
        hintStyle: AppTextStyle.input.copyWith(color: AppColors.hint),
        errorText: widget.errorText,
        errorStyle: AppTextStyle.description.copyWith(
          color: AppColors.danger,
          height: 1.6,
        ),
        // The character counter would break the fixed 56h box.
        counterText: '',
        contentPadding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 18.h),
        prefixIcon: widget.prefix,
        suffixIcon: _buildSuffix(),
        border: _border(AppColors.border),
        enabledBorder: _border(AppColors.border),
        focusedBorder: _border(AppColors.primary),
        errorBorder: _border(AppColors.danger),
        focusedErrorBorder: _border(AppColors.danger),
        disabledBorder: _border(AppColors.border),
      ),
    );
  }

  Widget? _buildSuffix() {
    if (widget.suffix != null) return widget.suffix;
    if (!widget.isPassword) return null;

    return IconButton(
      onPressed: () => setState(() => _obscure = !_obscure),
      icon: Icon(
        _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        color: AppColors.iconMuted,
        size: 22.sp,
      ),
    );
  }
}

/// Formatters reused across forms.
abstract final class AppInputFormatters {
  /// Digits only, tolerant of Arabic-Indic numerals on an Arabic keyboard.
  static final List<TextInputFormatter> phone = [
    LengthLimitingTextInputFormatter(14),
    TextInputFormatter.withFunction(
      (_, next) => next.copyWith(text: Validators.digitsOnly(next.text)),
    ),
  ];

  /// Blocks whitespace outright — emails and passwords never contain any, and
  /// a trailing space is the single most common cause of a "wrong password".
  static final List<TextInputFormatter> noWhitespace = [
    FilteringTextInputFormatter.deny(RegExp(r'\s')),
  ];
}
