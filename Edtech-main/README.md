# 📚 EdTech — Student Learning App

> A modern EdTech mobile application built with Flutter, designed to help students learn subjects and languages in one place.

---

## 🗂 Project Overview

**EdTech** is a cross-platform student learning app built using Flutter. It provides a clean and intuitive interface for students to select their board, class, and preferred language, and then access study materials, notes, and video content — all from a single portal.

The app is designed to work seamlessly on both **mobile** and **tablet** devices with responsive layouts.

---

## ⚙️ Tech Stack

| Technology | Details |
|---|---|
| **Framework** | Flutter (Dart) |
| **Language** | Dart 3.x |
| **UI** | Material Design 3 |
| **State Management** | Flutter `setState` (local) |
| **Min SDK** | Android 5.0+ / iOS 12+ |
| **Target Platforms** | Android, iOS, Web |

---

## 🚀 Installation & Setup

### Prerequisites
Make sure you have the following installed:
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (v3.x or above)
- [Dart SDK](https://dart.dev/get-dart) (comes with Flutter)
- [Android Studio](https://developer.android.com/studio) or [VS Code](https://code.visualstudio.com/)
- A connected device or emulator

### Steps

**1. Clone the repository**
```bash
git clone https://github.com/Sanika-Blip/edtech.git
cd edtech
```

**2. Install dependencies**
```bash
flutter pub get
```

**3. Add assets**

Make sure the following folder and file exist in your project root:
```
assets/
└── Images/
    └── login_img.png
```

Verify `pubspec.yaml` has assets registered:
```yaml
flutter:
  assets:
    - assets/Images/login_img.png
```

**4. Run the app**
```bash
# Run on connected device or emulator
flutter run

# Run on Chrome (web)
flutter run -d chrome

# Build APK
flutter build apk
```

---

## 📁 Project Structure

```
edtech/
├── lib/
│   ├── main.dart          # App entry point
│   ├── login.dart         # Login screen
│   ├── selection1.dart    # Board & Class selection
│   ├── selection2.dart    # Language selection
│   └── home1.dart         # Home screen (Study & Language toggle)
├── assets/
│   └── Images/
│       └── login_img.png  # Login page illustration
├── pubspec.yaml
└── README.md
```

---

## 🛠 Status

> ⚠️ **This project is currently a work in progress.**

| Screen | Status |
|---|---|
| Login Page | ✅ Done |
| Board & Class Selection | ✅ Done |
| Language Selection | ✅ Done |
| Home Page (Study) | ✅ Done |
| Home Page (Language) | 🔄 In Progress |
| Subject Detail Page | 🔄 In Progress |
| Video Player Page | 🔄 In Progress |
| Profile Page | ⏳ Pending |
| Settings Page | ⏳ Pending |

---

## 👩‍💻 Developer

Made with ❤️ using Flutter
