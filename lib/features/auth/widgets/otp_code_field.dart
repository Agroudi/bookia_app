import 'package:bookia_app/core/theme/colors.dart';
import 'package:bookia_app/core/theme/text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// The six 48x60 verification-code boxes from the design.
///
/// Written directly rather than pulled from a package: it is a single hidden
/// [EditableText] behind six painted boxes, which is both less code than
/// configuring a third-party field and an exact match for the Figma spec
/// (r8, white fill, 1.2px `#BFA054` border when filled).
class OtpCodeField extends FormField<String> {
  OtpCodeField({
    super.key,
    required TextEditingController controller,
    required this.length,
    super.validator,
    ValueChanged<String>? onCompleted,
    bool autofocus = true,
  }) : super(
         initialValue: controller.text,
         builder: (field) => _OtpCodeFieldBody(
           controller: controller,
           length: length,
           autofocus: autofocus,
           errorText: field.errorText,
           onChanged: (value) {
             field.didChange(value);
             if (value.length == length) onCompleted?.call(value);
           },
         ),
       );

  final int length;
}

class _OtpCodeFieldBody extends StatefulWidget {
  const _OtpCodeFieldBody({
    required this.controller,
    required this.length,
    required this.autofocus,
    required this.onChanged,
    this.errorText,
  });

  final TextEditingController controller;
  final int length;
  final bool autofocus;
  final ValueChanged<String> onChanged;
  final String? errorText;

  @override
  State<_OtpCodeFieldBody> createState() => _OtpCodeFieldBodyState();
}

class _OtpCodeFieldBodyState extends State<_OtpCodeFieldBody> {
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    _focusNode.dispose();
    super.dispose();
  }

  /// Repaints the boxes whenever the text changes — including when the parent
  /// clears the controller after a rejected code.
  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            // The real input, invisible but focusable and pasteable.
            Positioned.fill(
              child: Opacity(
                opacity: 0,
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  autofocus: widget.autofocus,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  enableSuggestions: false,
                  autocorrect: false,
                  autofillHints: const [AutofillHints.oneTimeCode],
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(widget.length),
                  ],
                  onChanged: widget.onChanged,
                  decoration: const InputDecoration(border: InputBorder.none),
                ),
              ),
            ),
            GestureDetector(
              onTap: () => _focusNode.requestFocus(),
              // Codes read left-to-right in both languages; without this the
              // boxes would fill backwards under an Arabic locale.
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (var index = 0; index < widget.length; index++)
                      _CodeBox(
                        digit: index < widget.controller.text.length
                            ? widget.controller.text[index]
                            : null,
                        isActive:
                            _focusNode.hasFocus &&
                            index == widget.controller.text.length,
                        hasError: widget.errorText != null,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (widget.errorText != null)
          Padding(
            padding: EdgeInsets.only(top: 8.h, left: 4.w),
            child: Text(
              widget.errorText!,
              style: AppTextStyle.description.copyWith(color: AppColors.danger),
            ),
          ),
      ],
    );
  }
}

class _CodeBox extends StatelessWidget {
  const _CodeBox({
    required this.digit,
    required this.isActive,
    required this.hasError,
  });

  final String? digit;
  final bool isActive;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final isFilled = digit != null;
    // Empty boxes take the neutral border; filled and focused ones take gold,
    // exactly as the Figma "blank" vs numbered boxes differ.
    final borderColor = switch ((hasError, isFilled || isActive)) {
      (true, _) => AppColors.danger,
      (false, true) => AppColors.primary,
      (false, false) => AppColors.border,
    };

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 48.w,
      height: 60.h,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.input.r),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: Text(
        digit ?? '',
        style: AppTextStyle.title.copyWith(
          fontSize: 22.sp,
          color: AppColors.dark,
        ),
      ),
    );
  }
}
