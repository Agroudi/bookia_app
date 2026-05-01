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
│   ├── images/              # App images & icons
│   ├── fonts/               # Custom fonts
│   └── translations/        # Localization files (AR / EN)
│
├── lib/
│   ├── core/
│   │   ├── routing/         # App routing (AppRouter)
│   │   ├── theme/           # Colors & text styles
│   │   ├── widgets/         # Global reusable widgets
│   │   └── services/        # Dio setup & helpers
│   │
│   ├── features/
│   │   ├── auth/
│   │   │   ├── cubit/       # State management (AuthCubit)
│   │   │   ├── data/
│   │   │   │   ├── repo/    # Auth repository
│   │   │   │   ├── services/# API services
│   │   │   │   └── local/   # Local storage (token)
│   │   │   └── presentation/# UI screens
│   │   │
│   │   ├── home/
│   │   ├── boarding/
│   │   └── ...
│   │
│   └── main.dart            # Entry point
```

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
dependencies:
  flutter:
    sdk: flutter
  flutter_bloc:
  dio:
  shared_preferences:
  easy_localization:
  flutter_screenutil:
  flutter_svg:
<h1>🎨 UI/UX</h1>
Clean and modern design
Responsive across multiple screen sizes
RTL/LTR fully supported
Consistent typography and spacing
Smooth transitions and user flow
<h1>📌 Notes</h1>
Authentication is fully functional with API integration
Token is stored locally for auto-login capability
Architecture is scalable and ready for future features (cart, payments, etc.)
