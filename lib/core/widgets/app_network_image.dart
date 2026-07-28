import 'package:bookia_app/core/theme/colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Every remote image in the app.
///
/// The API's seed data points at `127.0.0.1`, so broken URLs are the norm in
/// development — the error state has to be a designed placeholder, not a grey
/// exception box.
class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.radius = 0,
  });

  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(radius);
    final source = url?.trim() ?? '';

    if (source.isEmpty || Uri.tryParse(source)?.hasAuthority != true) {
      return ClipRRect(
        borderRadius: borderRadius,
        child: _Fallback(width: width, height: height),
      );
    }

    return ClipRRect(
      borderRadius: borderRadius,
      child: CachedNetworkImage(
        imageUrl: source,
        width: width,
        height: height,
        fit: fit,
        fadeInDuration: const Duration(milliseconds: 250),
        placeholder: (_, _) => _Skeleton(width: width, height: height),
        errorWidget: (_, _, _) => _Fallback(width: width, height: height),
      ),
    );
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton({this.width, this.height});

  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
    baseColor: AppColors.placeholder,
    highlightColor: AppColors.disabledField,
    child: Container(
      width: width,
      height: height,
      color: AppColors.placeholder,
    ),
  );
}

class _Fallback extends StatelessWidget {
  const _Fallback({this.width, this.height});

  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    color: AppColors.placeholder,
    child: Center(
      child: Icon(
        Icons.menu_book_rounded,
        color: AppColors.placeholderDark,
        size: (width ?? 60) * 0.35,
      ),
    ),
  );
}
