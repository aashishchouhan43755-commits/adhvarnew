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

## Netlify deployment

The repository-root `netlify.toml` sets the base directory to `frontend`, runs
`bash scripts/netlify-build.sh`, and publishes `build/web` relative to that base.
The script downloads the official stable Linux x64 Flutter SDK archive, verifies
its SHA-256 checksum, and extracts it in a temporary directory without cloning
a Git repository. After bootstrapping Flutter, it restores the release version
metadata from the official manifest so dependency resolution works even when
Git version detection is restricted. It enables web
support, fetches dependencies, and creates a release web build. Netlify therefore
publishes `frontend/build/web` from the repository root.

The deployed app uses the default offline demo mode and does not require the
FastAPI backend.
