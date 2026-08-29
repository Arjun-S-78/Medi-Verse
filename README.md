# mediverse

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Configuration & Environment Setup

MediVerse uses environment variable injection for sensitive keys (such as Google Maps API Key).

### Running locally with Google Maps API Key

Pass your Google Maps API key via `--dart-define` when launching the application:

```bash
flutter run -d chrome --dart-define=GOOGLE_MAPS_API_KEY=YOUR_ACTUAL_API_KEY
```

Or for building Flutter Web:

```bash
flutter build web --dart-define=GOOGLE_MAPS_API_KEY=YOUR_ACTUAL_API_KEY
```

Refer to `.env.example` for environment variable templates.

