📱 Bookia App

A modern and scalable Book Store mobile application built with Flutter, designed to provide a seamless experience for browsing, searching, and purchasing books with a clean UI and robust architecture.

🚀 Project Setup & Installation Guide
🔧 Prerequisites
Flutter (latest stable version)
Dart SDK
Android Studio / VS Code
Emulator or physical device
📥 Installation Steps

Clone the repository:

git clone https://github.com/your-username/bookia_app.git

Navigate to project directory:

cd bookia_app

Install dependencies:

flutter pub get

Run the app:

flutter run
🏗️ Architectural Overview
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
⚙️ Features

🔐 Authentication System:

Login (Email & Password)
Register new account
Forgot password flow
OTP verification (Email / SMS)

🌍 Multi-language Support:

Arabic 🇪🇬 (RTL)
English 🇺🇸 (LTR)
Powered by EasyLocalization

📚 Book Store Functionality:

Browse books
View book details
Search functionality (ready to extend)

💾 Token Management:

Secure token storage using SharedPreferences
Persistent login support

🎯 Clean Architecture:

Separation of concerns (Cubit / Repo / Services)
Scalable and maintainable structure

⚡ Smooth UI & UX:

Responsive design using ScreenUtil
Clean and modern UI
🧠 State & Data Management
🔄 State Management
Flutter Bloc (Cubit)
Handles authentication states:
Loading
Success
Error
🌐 API Handling
Dio
REST API integration
Error handling with status codes
💾 Local Storage
SharedPreferences
Stores authentication token for persistent sessions
🧩 Key Widgets Used
TextFormField → User input (email/password)
BlocListener → Handle navigation & states
BlocBuilder → UI updates
AppButton → Custom reusable button
ListView → Display book lists
Navigator / AppRouter → Navigation handling
SVG Icons → Clean scalable UI assets
📦 Dependencies
dependencies:
  flutter:
    sdk: flutter
  flutter_bloc:
  dio:
  shared_preferences:
  easy_localization:
  flutter_screenutil:
  flutter_svg:
🎨 UI/UX
Clean and modern design
Responsive across multiple screen sizes
RTL/LTR fully supported
Consistent typography and spacing
Smooth transitions and user flow
📌 Notes
Authentication is fully functional with API integration
Token is stored locally for auto-login capability
Architecture is designed for scalability (ready for adding cart, payments, etc.)
Code follows clean structure and SOLID principles
