/// Every endpoint exposed by the Book Store API, transcribed from the Postman
/// collection. Paths are relative to [baseUrl] and never built by string
/// concatenation at the call site.
abstract final class ApiConstants {
  static const String baseUrl = 'https://codingarabic.online/api';

  // ----------------------------------------------------------- auth
  static const String register = '/register';
  static const String login = '/login';
  static const String logout = '/logout';
  static const String forgetPassword = '/forget-password';
  static const String checkForgetPassword = '/check-forget-password';
  static const String resetPassword = '/reset-password';
  static const String resendVerifyCode = '/resend-verify-code';
  static const String verifyEmail = '/verify-email';

  // ------------------------------------------------------- home data
  static const String sliders = '/sliders';
  static const String settings = '/settings';

  // -------------------------------------------------------- products
  static const String products = '/products';
  static const String bestSeller = '/products-bestseller';
  static const String newArrivals = '/products-new-arrivals';
  static const String searchProducts = '/products-search';
  static const String filterProducts = '/products-filter';
  static String product(int id) => '/products/$id';

  // ------------------------------------------------------ categories
  static const String categories = '/categories';
  static String category(int id) => '/categories/$id';

  // -------------------------------------------------------- wishlist
  static const String wishlist = '/wishlist';
  static const String addToWishlist = '/add-to-wishlist';
  static const String removeFromWishlist = '/remove-from-wishlist';

  // ------------------------------------------------------------ cart
  static const String cart = '/cart';
  static const String addToCart = '/add-to-cart';
  static const String updateCart = '/update-cart';
  static const String removeFromCart = '/remove-from-cart';

  // --------------------------------------------------------- profile
  static const String profile = '/profile';
  static const String updateProfile = '/update-profile';
  static const String updatePassword = '/update-password';
  static const String deleteProfile = '/delete-profile';

  // ----------------------------------------------------------- order
  static const String checkout = '/checkout';
  static const String placeOrder = '/place-order';
  static const String orderHistory = '/order-history';
  static String order(int id) => '/order-history/$id';
  static const String governorates = '/governorates';

  // ----------------------------------------------------------- other
  static const String faqs = '/faqs';
  static const String contactUs = '/contact-us';
}

/// Keys used in request bodies. Centralised so a rename in the API is a
/// one-line change rather than a grep across every service.
abstract final class ApiKeys {
  static const String name = 'name';
  static const String email = 'email';
  static const String password = 'password';
  static const String passwordConfirmation = 'password_confirmation';
  static const String verifyCode = 'verify_code';
  static const String newPassword = 'new_password';
  static const String newPasswordConfirmation = 'new_password_confirmation';
  static const String currentPassword = 'current_password';
  static const String productId = 'product_id';
  static const String cartItemId = 'cart_item_id';
  static const String quantity = 'quantity';
  static const String address = 'address';
  static const String city = 'city';
  static const String phone = 'phone';
  static const String image = 'image';
  static const String governorateId = 'governorate_id';
  static const String subject = 'subject';
  static const String message = 'message';

  // response envelope
  static const String data = 'data';
  static const String errors = 'errors';
  static const String status = 'status';
  static const String token = 'token';
  static const String user = 'user';
}
