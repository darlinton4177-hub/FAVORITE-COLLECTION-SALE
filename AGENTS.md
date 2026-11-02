# AGENTS.md — Development and Customization Guidelines

This repository contains the Flutter Android application **Favorite Collection Sale** based on the customized N-Educate Premium Flutter Ecommerce Template (v1.1).

## Architecture Principles
1. **Centralized Configuration:**
   - App branding, tagline, currency, contact details, policies, and demo PIN are centralized in `lib/config/store_config.dart`.
   - Asset catalog mapping is maintained in `lib/config/asset_catalog.dart`.
   - Initial demo categories, banners, coupons, and products are maintained in `lib/data/demo_store_data.dart`.
2. **Offline-First & Local Storage:**
   - SharedPreferences and application documents directory (`path_provider`) provide persistent local state for products, categories, banners, orders, wishlist, profile, and theme.
   - All shopping checkout flows are simulated demonstrations; no real payment credentials are ever accepted or charged.
3. **Image Management (v1.1 Enhanced):**
   - Customer-facing screens use `StoreImageWidget`, which gracefully displays bundled asset paths, imported local file paths, and high-quality Flutter placeholder fallbacks.
   - Administrators can select bundled asset imagery or import custom photos directly using the Android system Photo Picker (`image_picker`). Imported photos are copied into the permanent local app documents directory (`/imported_images`).
4. **Hidden Demonstration Admin Console:**
   - Accessed from the Account screen via the demo tile or by tapping 3 times on the admin button.
   - Default demonstration PIN: `1234`.

## Testing & CI/CD
- Run `flutter analyze` for static analysis.
- Run `flutter test` for widget and unit tests.
- Automated Android APK builds and GitHub Releases creation are configured in `.github/workflows/build-apk.yml`.
