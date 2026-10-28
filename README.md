# Pavan Putra Garbi Mandal — Flutter Web Starter

Premium heritage-focused Flutter web foundation for Pavan Putra Garbi Mandal, Rajkot.

## Current phase

- Public responsive shell
- Heritage theme + dark mode
- Custom 3-second logo loader widget
- Home / About / History / Archive / Gallery / Videos / Blog / Contact routes
- Admin Login / Dashboard shell
- Firebase-ready dependency setup
- GoRouter URL structure for deep links

## Firebase setup

Run from the project root:

```bash
flutter pub get
flutterfire configure
```

Select the required platforms, then initialize Firebase in `main.dart` using the generated `firebase_options.dart` before wiring repositories.

## Important

The attached real logo is included at:

`assets/images/pavan_putra_logo.jpg`

The Figma design is the visual reference. Replace the placeholder media blocks with admin-managed Firebase content; do not put production photos/videos into source code.

## Recommended next implementation phase

1. Add Firebase initialization + Firestore/Storage repositories.
2. Add Admin Auth + Security Rules + custom claims.
3. Add real CRUD for Years → Albums → Photos.
4. Add YouTube/custom video/live models and player integration.
5. Add blog editor + published/draft flow.
6. Add production SEO/prerender strategy for public content.

## Verified package baselines

The foundation currently pins these current stable package baselines (verified 2026-10-08):

- `flutter_bloc: ^9.1.1`
- `go_router: ^18.0.2`
- `google_fonts: ^9.0.0`
- `firebase_core: ^4.15.0`
- `firebase_auth: ^6.7.0`
- `cloud_firestore: ^6.10.0`
- `firebase_storage: ^13.6.0`

The development container used for this build does not have the Flutter SDK installed, so a local `flutter analyze` / `flutter build web` run could not be executed here. The source was checked for YAML validity and local-import resolution. Run `flutter create .`, `flutter pub get`, then `flutter analyze` in your Flutter environment before the next feature phase.
