import 'package:bookia_app/core/theme/colors.dart';
import 'package:bookia_app/core/widgets/exit_confirmation_scope.dart';
import 'package:bookia_app/features/cart/cubit/cart_cubit.dart';
import 'package:bookia_app/features/cart/presentation/cart_screen.dart';
import 'package:bookia_app/features/home/presentation/home_screen.dart';
import 'package:bookia_app/features/layout/widgets/app_bottom_nav.dart';
import 'package:bookia_app/features/profile/presentation/profile_screen.dart';
import 'package:bookia_app/features/wishlist/cubit/wishlist_cubit.dart';
import 'package:bookia_app/features/wishlist/presentation/wishlist_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The app shell: four tabs behind a floating navigation card.
class LayoutScreen extends StatefulWidget {
  const LayoutScreen({super.key, this.initialTab = AppTab.home});

  final AppTab initialTab;

  @override
  State<LayoutScreen> createState() => _LayoutScreenState();
}

class _LayoutScreenState extends State<LayoutScreen> {
  late AppTab _current = widget.initialTab;
  late final PageController _pageController = PageController(
    initialPage: widget.initialTab.index,
  );

  @override
  void initState() {
    super.initState();
    // Warm the cart and wishlist here rather than in their own tabs: the
    // PageView builds pages lazily, so waiting for those screens would leave
    // the nav badge empty — and the Book Details bookmark wrong — until the
    // user happened to open each tab.
    context.read<CartCubit>().load();
    context.read<WishlistCubit>().load();
  }

  /// A [PageView] rather than an `IndexedStack` so the switch actually
  /// animates, and rather than an `AnimatedSwitcher` so the tabs stay alive —
  /// each tab screen mixes in `AutomaticKeepAliveClientMixin`, which preserves
  /// its scroll position and loaded data across switches.
  void _select(AppTab tab) {
    if (tab == _current) return;
    setState(() => _current = tab);
    _pageController.animateToPage(
      tab.index,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The shell is the root route, so back from here means leaving the app —
    // unless the user is on a secondary tab, where back returns to Home first.
    return ExitConfirmationScope(
      onBack: () {
        if (_current == AppTab.home) return false;
        _select(AppTab.home);
        return true;
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        // Lets content scroll under the floating nav card.
        extendBody: true,
        body: PageView(
          controller: _pageController,
          // Tabs are switched by the nav bar only; a stray horizontal swipe
          // on a book grid should not change tab.
          physics: const NeverScrollableScrollPhysics(),
          children: const [
            HomeScreen(),
            WishlistScreen(),
            CartScreen(),
            ProfileScreen(),
          ],
        ),
        bottomNavigationBar: BlocBuilder<CartCubit, CartState>(
          buildWhen: (previous, current) =>
              previous.itemCount != current.itemCount,
          builder: (context, state) => AppBottomNav(
            current: _current,
            cartCount: state.itemCount,
            onSelected: _select,
          ),
        ),
      ),
    );
  }
}
