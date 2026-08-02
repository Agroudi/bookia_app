<h1>🎥 App Demo</h1>

https://github.com/user-attachments/assets/672f1709-f737-4c78-b93c-1d7484e36731

<p align="center">
Watch the latest application demo showcasing the full shopping flow, authentication with OTP, cart & wishlist, order placement, Arabic/English localization, and the Lottie-driven loading experience.
</p>

<h1>📚 Bookia Store App</h1>

A complete, production-minded bookstore e-commerce application built with Flutter, implemented pixel-by-pixel from a Figma design and wired end-to-end against a live REST API.
The app ships the full commerce loop — browse, search, wishlist, cart, checkout, orders — behind a clean, layered architecture with a zero-warning codebase.

<h1>🚀 Project Setup & Installation Guide</h1>

🔧 Prerequisites

Flutter 3.41+ (latest stable)
Dart SDK 3.11+
Android Studio / VS Code
Emulator or physical device

<h1>📥 Installation Steps</h1>

Clone the repository:
git clone https://github.com/your-username/bookia_app.git
Navigate to project directory:
cd bookia_app
Install dependencies:
flutter pub get
Generate assets & localization keys:
dart run build_runner build --delete-conflicting-outputs
dart run easy_localization:generate -S assets/translations -O lib/gen -o locale_keys.g.dart -f keys
Run the app:

<h1>📱 Bookia App</h1>

A modern and scalable Book Store mobile application built with Flutter, designed to provide a seamless experience for browsing, searching, and purchasing books with a clean UI and robust architecture.

<h1>🚀 Project Setup & Installation Guide</h1>
🔧 Prerequisites
Flutter (latest stable version)
Dart SDK
Android Studio / VS Code
Emulator or physical device
<h1>📥 Installation Steps</h1>

Clone the repository:

git clone https://github.com/Agroudi/bookia_app.git

Navigate to project directory:

cd bookia_app

Install dependencies:

flutter pub get

Run the app:

flutter run

<h1>🏗️ Architectural Overview</h1>

```text
project_root/
│
├── assets/
│   ├── animations/                         # Lottie (book_loader)
│   ├── fonts/                              # DM Serif Display, Nunito Sans, Cairo (Arabic)
│   ├── icons/                              # SVG icons exported from Figma
│   ├── images/                             # App images
│   └── translations/                       # Localization files (AR / EN)
│
├── lib/
│   ├── core/
│   │   ├── api/                            # ApiClient, ApiResult, Failure, error handler
│   │   │   └── interceptors/               # Bearer token, Accept-Language, 401 teardown
│   │   ├── models/                         # Product, User, Paginated, JSON readers
│   │   ├── routing/                        # AppRouter, Routes, page transitions
│   │   ├── services/                       # Loading overlay, toast service
│   │   ├── storage/                        # SessionStorage abstraction + implementation
│   │   ├── theme/                          # Colors, radii, spacing, text scale, AppTheme
│   │   ├── utils/                          # Validators, bidi, HTML strip, price format
│   │   └── widgets/                        # Global reusable widgets
│   ├── di/                                 # get_it service locator (object graph)
│   ├── features/
│   │   ├── auth/                           # Login, register, forgot password, OTP, reset
│   │   │   ├── cubit/                      # AuthCubit + sealed AuthState
│   │   │   ├── data/
│   │   │   │   ├── repo/                   # AuthRepository interface + AuthRepo
│   │   │   │   └── services/               # Auth API service
│   │   │   ├── presentaion/                # Auth screens
│   │   │   └── widgets/                    # AuthScaffold, OtpCodeField, SignButton
│   │   ├── boarding/                       # Onboarding
│   │   │   └── presentation/
│   │   ├── book_details/                   # Product detail
│   │   │   ├── cubit/
│   │   │   └── presentation/
│   │   ├── cart/                           # Cart system
│   │   │   ├── cubit/
│   │   │   ├── data/                       # CartService + CartRepository
│   │   │   │   └── models/
│   │   │   └── presentation/
│   │   │       └── widgets/                # CartItemTile, QuantityStepper
│   │   ├── home/                           # Home + shared catalogue data layer
│   │   │   ├── cubit/
│   │   │   ├── data/
│   │   │   │   ├── models/
│   │   │   │   ├── repo/                   # CatalogRepository interface + CatalogRepo
│   │   │   │   └── services/               # CatalogService (home / search / details)
│   │   │   └── presentation/
│   │   │       └── widgets/                # HomeBanner
│   │   ├── layout/                         # App shell & bottom navigation
│   │   │   ├── presentation/
│   │   │   └── widgets/                    # AppBottomNav
│   │   ├── orders/                         # Checkout, place order, history, details
│   │   │   ├── cubit/
│   │   │   ├── data/                       # OrdersService + OrdersRepository
│   │   │   │   └── models/
│   │   │   └── presentation/
│   │   │       └── widgets/                # GovernorateSheet
│   │   ├── profile/                        # Profile, edit, password, FAQ, contact us
│   │   │   ├── cubit/
│   │   │   ├── data/                       # ProfileService + ProfileRepository
│   │   │   └── presentation/
│   │   │       └── widgets/                # ProfileMenuTile
│   │   ├── search/                         # Debounced product search
│   │   │   ├── cubit/
│   │   │   └── presentation/
│   │   ├── splash/                         # Splash gate & session routing
│   │   └── wishlist/                       # Saved books
│   │       ├── cubit/
│   │       ├── data/                       # WishlistService + WishlistRepository
│   │       └── presentation/
│   ├── gen/                                # Generated code (assets, locale keys)
│   │
│   ├── bookia_app.dart                     # Root widget (MaterialApp, providers, theme)
│   └── main.dart                           # Entry point (DI & bootstrapping)
│
├── test/                                   # Model & parsing tests
└── pubspec.yaml                            # Dependencies, assets, fonts
```

<h1>⚙️ Features</h1>

<h2>🔐 Authentication System</h2>

Login (Email + Password)
Register new account
Forgot password flow
OTP Verification — reset code + post-registration account activation
Reset password
Resend code with a 60-second cooldown
Logout & delete account

<h2>🌍 Multi-language Support</h2>

Arabic 🇪🇬 (RTL)
English 🇺🇸 (LTR)
Powered by EasyLocalization
Full RTL mirroring — directional padding, flipped arrows, mirrored navigation
Content-aware bidi: API prose keeps its own direction inside a mirrored UI
Cairo bundled as a per-glyph Arabic fallback for the Latin display fonts

<h2>📚 E-commerce Functionality (Books)</h2>

Home with banner carousel, Best Sellers and New Arrivals
Book details with description, discount pricing and stock state
Debounced search with pagination
Wishlist (add / remove / browse)
Shopping cart with quantity stepper clamped to available stock
Checkout with governorate picker and order placement
Order history & full order details
FAQ and Contact Us

<h2>💾 Token Management</h2>

Session storage behind a SessionStorage interface (SharedPreferences)
Persistent login with a splash gate
Bearer token attached by a Dio interceptor
Automatic session teardown and redirect on 401

<h2>🎯 Clean Architecture</h2>

Separation of concerns (Cubit / Repository / API Service)
SOLID principles applied — cubits depend on repository interfaces, never implementations
Dependency injection with get_it
No DioException or HTTP status code ever escapes the data layer
Scalable & maintainable structure

<h2>⚡ UI/UX Excellence</h2>

Pixel-perfect implementation based on Figma (375×812 canvas)
Fully responsive using ScreenUtil
Directional page transitions (slide / fade / rise) that respect locale
Animated tab switching that preserves each tab's scroll position and data
One loading identity — the book_loader Lottie for every loading state, blocking and inline
Designed empty and error states for every list
Zero analyzer warnings

<h2>🛡️ Input Validation & Abuse Prevention</h2>

Strict client-side validation on every field, localized in both languages
Server-side 422 errors mapped onto the exact input that caused them
Length caps and whitespace stripping before anything reaches the API
Debounced search with cancellation of superseded requests
Per-item concurrency guards on cart and wishlist mutations
Quantity clamped to available stock

<h1>🧠 State & Data Management</h1>

<h2>🔄 State Management</h2>

Flutter Bloc (Cubit)
Sealed states per operation — a login listener can never be woken by a password-reset response
Handles all states: Loading / Success / Error

<h2>🌐 API Handling</h2>

Dio for REST API integration
Single ApiClient that unwraps the {data, message, errors, status} envelope once
Sealed ApiResult&lt;T&gt; returned by every repository
Typed AppFailure hierarchy (network, validation, unauthorized, not found, server)
Defensive JSON readers for fields whose types vary between endpoints

<h2>💾 Local Storage</h2>

SharedPreferences
Stores authentication token and cached user for instant cold starts
Remembers onboarding completion

<h1>🧩 Key Widgets Used</h1>

TextFormField → User input handling
BlocListener → Navigation & side effects
BlocBuilder → UI state updates
AppButton → Custom reusable button with five design variants
BookCard → Shared product card with Buy / Remove variants
CartItemTile & QuantityStepper → Cart line editing
GridView / ListView → Product & list rendering
Navigator / AppRouter → Clean navigation with typed arguments
PopScope → Double-back exit confirmation
AppLoader → The book_loader Lottie, in page / pagination / inline sizes
LoadingOverlay → Full-screen, non-dismissible blocking loader
SVG Icons → Scalable UI assets

<h1>⚙️ Features</h1>
<h2>🔐 Authentication System</h2>
Login (Email & Password)
Register new account
Forgot password flow
OTP verification (Email / SMS)
<h2>🌍 Multi-language Support</h2>
Arabic 🇪🇬 (RTL)
English 🇺🇸 (LTR)
Powered by EasyLocalization
<h2>📚 Book Store Functionality</h2>
Browse books
View book details
Search functionality (ready to extend)
<h2>💾 Token Management</h2>
Secure token storage using SharedPreferences
Persistent login support
<h2>🎯 Clean Architecture</h2>
Separation of concerns (Cubit / Repo / Services)
Scalable and maintainable structure
<h2>⚡ Smooth UI & UX</h2>
Responsive design using ScreenUtil
Clean and modern UI
<h1>🧠 State & Data Management</h1>
<h2>🔄 State Management</h2>
Flutter Bloc (Cubit)
Handles authentication states:
Loading
Success
Error
<h2>🌐 API Handling</h2>
Dio
REST API integration
Error handling with status codes
<h2>💾 Local Storage</h2>
SharedPreferences
Stores authentication token for persistent sessions
<h1>🧩 Key Widgets Used</h1>
TextFormField → User input (email/password)
BlocListener → Handle navigation & states
BlocBuilder → UI updates
AppButton → Custom reusable button
ListView → Display book lists
Navigator / AppRouter → Navigation handling
SVG Icons → Clean scalable UI assets
<h1>📦 Dependencies</h1>
```text
dependencies:
  flutter:
    sdk: flutter
  flutter_bloc:
  dio:
  shared_preferences:
  easy_localization:
  flutter_screenutil:
  flutter_svg:
  lottie:
  toastification:
  cached_network_image:
  image_picker:
  smooth_page_indicator:
  shimmer:
  intl:
  flutter_native_splash:
  flutter_gen_runner:
  build_runner:
  ```

<h1>🎨 UI/UX</h1>

Pixel-perfect implementation translated from the Figma design (375×812 canvas)
Fully responsive across devices using ScreenUtil scaling
Complete RTL / LTR support — directional padding, flipped back arrows, mirrored navigation bar
Consistent spacing and typography driven by centralized design tokens (AppColors, AppRadius, AppSpacing)
Locale-aware page transitions: slides enter from the trailing edge, reversing direction under Arabic
Animated tab switching via PageView with preserved scroll position and loaded data across every tab
Glassmorphic ("glacier") toasts for success, error, info, and warning — frosted backdrop blur with a colour-coded accent rail
Book-themed Lottie loader (book_loader) used as the single, non-dismissible loading identity — both full-screen blocking overlay and inline variants
Designed empty states and error states for every list surface
Custom fonts: DM Serif Display and Nunito Sans for Latin, Cairo as an Arabic fallback
Floating bottom navigation card with a live cart-item count badge

<h1>📌 Notes</h1>

Full commerce flow — browse, search, wishlist, cart, checkout, order history — is functional and integrated with the live REST API
OTP verification powers both password reset and post-registration email activation, with a 60-second resend cooldown
Bearer token is securely stored via SharedPreferences and attached by a Dio interceptor; cleared automatically with a redirect on 401
Exiting the app is guarded: first back press shows a toast, second within 3 seconds opens a cancellable confirmation dialog
Product descriptions arrive as HTML from the API and are stripped / sanitized before rendering
Server-side 422 validation errors are mapped back onto the exact input field that caused them
Per-item concurrency guards prevent double-toggling a wishlist item or cart mutation while a request is in flight
Cart quantity stepper is clamped to available stock, preventing over-ordering
The codebase compiles with zero analyzer warnings
Built with strict adherence to the Figma design and SOLID architecture principles
Authentication is fully functional with API integration
Token is stored locally for auto-login capability
Architecture is scalable and ready for future features (cart, payments, etc.)

