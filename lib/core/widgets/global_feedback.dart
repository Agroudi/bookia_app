import 'package:bookia_app/core/utils/state_feedback.dart';
import 'package:bookia_app/features/cart/cubit/cart_cubit.dart';
import 'package:bookia_app/features/wishlist/cubit/wishlist_cubit.dart';
import 'package:bookia_app/gen/locale_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Reports cart and wishlist outcomes exactly once, app-wide.
///
/// Both cubits live above the navigator, and the tab screens stay mounted
/// underneath any pushed route — so a per-screen listener would fire on the
/// Cart tab *and* on Book Details for the same "Added to cart", toasting
/// twice. Listening once, here, is the only way to guarantee one message per
/// event.
class GlobalFeedback extends StatelessWidget {
  const GlobalFeedback({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<CartCubit, CartState>(
          listenWhen: (previous, current) =>
              _isReportableCartMutation(current.mutation) ||
              (current.failure != null && previous.failure != current.failure),
          listener: (context, state) {
            switch (state.mutation) {
              case CartMutation.added:
                StateFeedback.success(
                  state.message,
                  fallbackKey: LocaleKeys.added_to_cart,
                );
              case CartMutation.updated:
                StateFeedback.success(
                  state.message,
                  fallbackKey: LocaleKeys.cart_updated,
                );
              case CartMutation.removed:
                StateFeedback.success(
                  state.message,
                  fallbackKey: LocaleKeys.removed_from_cart,
                );
              // In-flight states are shown inline by the stepper and the
              // buttons; an overlay would be more disruptive than helpful.
              case CartMutation.adding:
              case CartMutation.updating:
              case CartMutation.removing:
                break;
              case CartMutation.none:
                if (state.failure != null) {
                  StateFeedback.failure(state.failure!);
                }
            }
          },
        ),
        BlocListener<WishlistCubit, WishlistState>(
          listenWhen: (previous, current) =>
              current.mutation != WishlistMutation.none ||
              (current.failure != null && previous.failure != current.failure),
          listener: (context, state) {
            switch (state.mutation) {
              case WishlistMutation.added:
                StateFeedback.success(
                  state.message,
                  fallbackKey: LocaleKeys.added_to_wishlist,
                );
              case WishlistMutation.removed:
                StateFeedback.success(
                  state.message,
                  fallbackKey: LocaleKeys.removed_from_wishlist,
                );
              case WishlistMutation.none:
                if (state.failure != null) {
                  StateFeedback.failure(state.failure!);
                }
            }
          },
        ),
      ],
      child: child,
    );
  }

  static bool _isReportableCartMutation(CartMutation mutation) =>
      mutation == CartMutation.added ||
      mutation == CartMutation.updated ||
      mutation == CartMutation.removed;
}
