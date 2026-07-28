import 'package:bookia_app/core/theme/colors.dart';
import 'package:bookia_app/core/widgets/app_network_image.dart';
import 'package:bookia_app/features/home/data/models/slider_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

/// The 350x150 banner carousel with the design's pill-and-dots indicator:
/// the active dot is a 36x7 gold pill, the rest are 7x7 grey circles.
class HomeBanner extends StatefulWidget {
  const HomeBanner({super.key, required this.sliders});

  final List<SliderModel> sliders;

  @override
  State<HomeBanner> createState() => _HomeBannerState();
}

class _HomeBannerState extends State<HomeBanner> {
  final _controller = PageController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 25.h),
        SizedBox(
          height: 150.h,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.sliders.length,
            padEnds: false,
            itemBuilder: (context, index) => Padding(
              padding: EdgeInsets.symmetric(horizontal: 13.w),
              child: AppNetworkImage(
                url: widget.sliders[index].image,
                radius: AppRadius.card.r,
                width: double.infinity,
              ),
            ),
          ),
        ),
        SizedBox(height: 14.h),
        // A single banner needs no indicator.
        if (widget.sliders.length > 1)
          SmoothPageIndicator(
            controller: _controller,
            count: widget.sliders.length,
            effect: ExpandingDotsEffect(
              dotHeight: 7.h,
              dotWidth: 7.w,
              expansionFactor: 36 / 7,
              spacing: 4.w,
              radius: 10.r,
              activeDotColor: AppColors.primary,
              dotColor: AppColors.placeholder,
            ),
          ),
      ],
    );
  }
}
