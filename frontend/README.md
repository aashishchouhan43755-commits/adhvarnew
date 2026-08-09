# Adhvar Flutter application

The Flutter client for the Adhvar Indoor Navigation System. It includes the
Adhvar Innovation Center demo: three floor maps, room search, shortest-path
navigation, floor switching, and animated route drawing.

## Run

```bash
flutter pub get
flutter run
```

The default is offline demo mode, which is suitable for a faculty presentation
without a backend service.

To use the FastAPI backend instead, start it from `../backend`, then run:

```bash
flutter run --dart-define=ADHVAR_USE_BACKEND=true
```

For Android emulators, update `ApiConstants.baseUrl` from `127.0.0.1` to
`10.0.2.2` before running the backend-enabled application.
