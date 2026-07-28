import 'package:bookia_app/core/theme/colors.dart';
import 'package:bookia_app/core/theme/text_style.dart';
import 'package:bookia_app/core/utils/price_format.dart';
import 'package:bookia_app/core/widgets/app_network_image.dart';
import 'package:bookia_app/core/widgets/remove_badge.dart';
import 'package:bookia_app/features/cart/data/models/cart_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// The 332x118 cart row.
///
/// Note these rows are drawn as canvas siblings of the Cart frame in Figma,
/// not as its children — the measurements here come from `Frame 26`.
class CartItemTile extends StatelessWidget {
  const CartItemTile({
    super.key,
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
    required this.onTap,
    this.isBusy = false,
  });

  final CartItemModel item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;
  final VoidCallback onTap;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.card.r);

    return Material(
      color: AppColors.white,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Container(
          height: 118.h,
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppNetworkImage(
                url: item.image,
                width: 94.w,
                height: 98.h,
                radius: AppRadius.card.r,
              ),
              SizedBox(width: 19.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyle.subtitle.copyWith(
                              color: AppColors.label,
                            ),
                          ),
                        ),
                        RemoveBadge(onTap: isBusy ? null : onRemove, size: 23),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      PriceFormat.format(item.unitPrice),
                      style: AppTextStyle.body.copyWith(
                        color: AppColors.heading,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        QuantityStepper(
                          quantity: item.quantity,
                          canDecrement: item.quantity > 1 && !isBusy,
                          canIncrement: !item.isAtMaxQuantity && !isBusy,
                          onIncrement: onIncrement,
                          onDecrement: onDecrement,
                        ),
                        const Spacer(),
                        Text(
                          PriceFormat.format(item.lineTotal),
                          style: AppTextStyle.body.copyWith(
                            color: AppColors.heading,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The 113x30 quantity control: two 30x30 r6 buttons around the count.
class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    super.key,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
    this.canIncrement = true,
    this.canDecrement = true,
  });

  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final bool canIncrement;
  final bool canDecrement;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StepperButton(
          icon: Icons.remove_rounded,
          onTap: canDecrement ? onDecrement : null,
        ),
        SizedBox(
          width: 44.w,
          child: Text(
            // Zero-padded, as in the design ("01").
            quantity.toString().padLeft(2, '0'),
            textAlign: TextAlign.center,
            style: AppTextStyle.quantity,
          ),
        ),
        _StepperButton(
          icon: Icons.add_rounded,
          onTap: canIncrement ? onIncrement : null,
        ),
      ],
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.tile.r);
    final isEnabled = onTap != null;

    return Material(
      color: AppColors.border,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Opacity(
          opacity: isEnabled ? 1 : 0.45,
          child: SizedBox(
            width: 30.w,
            height: 30.w,
            child: Icon(icon, size: 16.sp, color: AppColors.dark),
          ),
        ),
      ),
    );
  }
}
