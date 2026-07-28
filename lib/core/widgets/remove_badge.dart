import 'package:bookia_app/core/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// The circular remove control that sits on a wishlist card and a cart row.
///
/// Drawn rather than imported: Figma flattened the layered shape into a single
/// black path on export, dropping the white disc and the red glyph, so the SVG
/// could not be recoloured. Twelve lines here beats an asset that lies about
/// its own colours.
class RemoveBadge extends StatelessWidget {
  const RemoveBadge({super.key, required this.onTap, this.size = 24});

  final VoidCallback? onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: size.r,
      child: Container(
        width: size.w,
        height: size.w,
        decoration: BoxDecoration(
          color: AppColors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.dark.withValues(alpha: 0.18),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          Icons.close_rounded,
          size: (size * 0.6).sp,
          color: AppColors.danger,
        ),
      ),
    );
  }
}
