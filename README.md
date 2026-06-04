# Computer Shop App

Flutter computer shop UI using the imported Nexus design flow.

## Requirements

- Flutter SDK with Dart `3.11.5` or newer compatible with the SDK constraint in `pubspec.yaml`
- Android Studio or Xcode for mobile builds
- Chrome or another supported browser for web preview

## Fresh Clone Setup

Run these commands from the project root:

```sh
flutter pub get
flutter analyze
flutter test
```

Start the app on an attached device, emulator, simulator, or browser:

```sh
flutter run
```

Useful build checks:

```sh
flutter build web
flutter build apk --debug
```

On macOS, iOS builds require Xcode and CocoaPods:

```sh
cd ios
pod install
cd ..
flutter run -d ios
```

## Active App Flow

The active app entry is:

```text
lib/main.dart
lib/app_shell.dart
lib/screens/
lib/state/nexus_controller.dart
lib/models/
lib/theme/nexus_*.dart
lib/widgets/
```

The older `lib/features/` flow is still present, but `lib/main.dart` launches the Nexus app shell.

## Before Pushing

Make sure all imported source files and image assets are committed, especially:

- `lib/app_shell.dart`
- `lib/data/mock_data.dart`
- `lib/models/models.dart`
- `lib/models/view_state.dart`
- `lib/screens/`
- `lib/state/nexus_controller.dart`
- `lib/theme/nexus_*.dart`
- `lib/widgets/brand_*`, `lib/widgets/nexus_scroll_behavior.dart`, `lib/widgets/product_card.dart`, `lib/widgets/ui_kit.dart`
- `assets/images/`
- `pubspec.yaml` and `pubspec.lock`
