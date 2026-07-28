import 'package:bookia_app/core/api/api_client.dart';
import 'package:bookia_app/core/api/dio_factory.dart';
import 'package:bookia_app/core/routing/routes.dart';
import 'package:bookia_app/core/services/app_toast.dart';
import 'package:bookia_app/core/services/loading_overlay.dart';
import 'package:bookia_app/core/storage/app_storage.dart';
import 'package:bookia_app/core/utils/app_keys.dart';
import 'package:bookia_app/features/auth/data/repo/auth_repo.dart';
import 'package:bookia_app/features/auth/data/services/auth_service.dart';
import 'package:bookia_app/features/cart/data/cart_repo.dart';
import 'package:bookia_app/features/home/data/repo/catalog_repo.dart';
import 'package:bookia_app/features/home/data/services/catalog_service.dart';
import 'package:bookia_app/features/orders/data/orders_repo.dart';
import 'package:bookia_app/features/profile/data/profile_repo.dart';
import 'package:bookia_app/features/wishlist/data/wishlist_repo.dart';
import 'package:bookia_app/gen/locale_keys.g.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

/// Wires the object graph once, at startup.
///
/// Registration is by *interface* wherever one exists, so a cubit resolving
/// `CatalogRepository` has no way to reach into the concrete implementation
/// or the Dio instance behind it.
abstract final class ServiceLocator {
  static Future<void> init() async {
    // ---------------------------------------------------------- storage
    final storage = await AppStorage.create();
    getIt.registerSingleton<SessionStorage>(storage);

    // ------------------------------------------------------------- http
    getIt.registerLazySingleton<Dio>(
      () => DioFactory.create(
        storage: getIt<SessionStorage>(),
        // Read at request time, not now — the user can switch language later.
        localeCode: () => AppKeys.context?.locale.languageCode ?? 'en',
        onUnauthorized: _onUnauthorized,
      ),
    );
    getIt.registerLazySingleton<ApiClient>(() => ApiClient(getIt<Dio>()));

    // --------------------------------------------------------- services
    getIt.registerLazySingleton(() => AuthService(getIt<ApiClient>()));
    getIt.registerLazySingleton(() => CatalogService(getIt<ApiClient>()));
    getIt.registerLazySingleton(() => WishlistService(getIt<ApiClient>()));
    getIt.registerLazySingleton(() => CartService(getIt<ApiClient>()));
    getIt.registerLazySingleton(() => ProfileService(getIt<ApiClient>()));
    getIt.registerLazySingleton(() => OrdersService(getIt<ApiClient>()));

    // ----------------------------------------------------- repositories
    getIt.registerLazySingleton<AuthRepository>(
      () => AuthRepo(
        service: getIt<AuthService>(),
        storage: getIt<SessionStorage>(),
      ),
    );
    getIt.registerLazySingleton<CatalogRepository>(
      () => CatalogRepo(getIt<CatalogService>()),
    );
    getIt.registerLazySingleton<WishlistRepository>(
      () => WishlistRepo(getIt<WishlistService>()),
    );
    getIt.registerLazySingleton<CartRepository>(
      () => CartRepo(getIt<CartService>()),
    );
    getIt.registerLazySingleton<ProfileRepository>(
      () => ProfileRepo(
        service: getIt<ProfileService>(),
        storage: getIt<SessionStorage>(),
      ),
    );
    getIt.registerLazySingleton<OrdersRepository>(
      () => OrdersRepo(getIt<OrdersService>()),
    );
  }

  /// Fired by the auth interceptor when a stored token stops working.
  ///
  /// The session has already been cleared by that point; all that is left is
  /// to tell the user and get them back to a screen that makes sense.
  static void _onUnauthorized() {
    LoadingOverlay.hide();
    AppToast.warning(LocaleKeys.session_expired.tr());
    AppKeys.navigator.currentState?.pushNamedAndRemoveUntil(
      Routes.loginScreen,
      (route) => false,
    );
  }
}
