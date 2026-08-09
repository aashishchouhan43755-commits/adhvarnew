/// Compile-time application configuration.
///
/// The standalone demo intentionally defaults to local data so it can be
/// presented without a running API. Enable the FastAPI integration with:
/// `flutter run --dart-define=ADHVAR_USE_BACKEND=true`.
class AppEnvironment {
  AppEnvironment._();

  static const bool useBackend = bool.fromEnvironment(
    'ADHVAR_USE_BACKEND',
    defaultValue: true,
  );
}
