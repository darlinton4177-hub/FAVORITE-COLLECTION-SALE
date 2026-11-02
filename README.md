# Favorite Collection Sale

A premium fashion-shopping Android application designed for discovering and buying stylish clothing, jeans, tops, dresses, shirts, trousers, socks, footwear, and fashion accessories.

Inspired by the intuitive product discovery and clear merchandising of modern multi-category shopping marketplaces like Temu and Jumia, **Favorite Collection Sale** delivers an authentic fashion marketplace experience while maintaining its own distinct brand identity.

---

## 🌟 Key Application Features

### Customer-Facing Storefront
- **Welcome & Onboarding:** Introduction walkthrough showcasing collections, marketplace deals, and offline demo capabilities.
- **Home Storefront:** Interactive promotional hero carousel, quick value proposition badges (free delivery, 30-day returns, authentic quality), category discovery shortcuts, flash sale deal countdowns, and curated bestsellers.
- **Shop & Catalog:** Full catalog view with instant text search, horizontal category filters, sorting by featured, price (low/high), or customer rating.
- **Product Details:** Rich image displays, dynamic size selectors (e.g., S, M, L, XL, 32W 32L), color/style swatches, real-time stock levels, customer ratings & review counts, technical specifications, and add-to-cart/buy-now actions.
- **Shopping Cart & Coupons:** Real-time quantity adjustments, promotional coupon codes (`FAVORITE10` for 10% off, `SAVE20` for 20% off >\$50), estimated shipping calculation (free over \$50), tax breakdown, and clear total calculation.
- **Demonstration Checkout:** Delivery address management, delivery speed selection (standard vs express), demo payment methods (Cash on Delivery, simulated card, simulated mobile pay), clearly marked with demonstration badges.
- **Order Confirmation & History:** Full order tracking receipts with itemized pricing, order IDs, timestamps, and persistent order history.
- **Account & Settings:** Profile management, wishlist management, light/dark/system theme modes, and store policy viewers.

---

## 🛠️ Hidden Demonstration Administrator Panel
- **Secure Demo Access:** Access from the Account / Profile screen with demonstration PIN `1234`.
- **Admin Dashboard:** Store overview displaying revenue, placed demo orders, catalog count, and low stock warnings.
- **Product Management:** Add, edit, or delete products with custom pricing, descriptions, stock quantities, sizes, and colors.
- **Android Phone Gallery Photo Selection:** Pick photos directly from the Android System Photo Picker (`image_picker`) or choose from bundled catalog assets. Selected photos are permanently copied to internal app storage so they persist across app launches.
- **Category & Banner Management:** Create and edit storefront categories and promotional banners with custom imagery.
- **Order Tracking:** Update demo order statuses between *Pending*, *Processing*, *Shipped*, *Delivered*, and *Cancelled*.

---

## 📱 Android Application Identity
- **Application Name:** Favorite Collection Sale
- **Application ID:** `com.neducate.favorite_collection_sale`
- **Target Platform:** Android (Material 3 Design)

---

## 🚀 Building & Testing Locally

### Prerequisites
- Flutter SDK (3.41+ recommended)
- Java 17 JDK
- Android SDK (API 34+)

### Commands
```bash
# Install dependencies
flutter pub get

# Static analysis
flutter analyze

# Run unit and widget tests
flutter test

# Build debug APK
flutter build apk --debug
```

---

## 🤖 Automated GitHub Actions & GitHub Releases

An automated CI/CD pipeline is configured in `.github/workflows/build-apk.yml`:
1. Triggers on every push to the `main` branch or via manual `workflow_dispatch`.
2. Sets up Java 17 and the Flutter environment.
3. Runs `flutter analyze` and `flutter test`.
4. Compiles the Android debug APK (`build/app/outputs/flutter-apk/app-debug.apk`).
5. Uploads the compiled APK artifact for workflow runs.
6. Automatically publishes a new GitHub Release with unique tags (`v1.0.0-<run_number>-<commit_sha>`) with the attached APK ready for direct download.

---

## 🔒 Offline & Security Notice
This application is completely self-contained and operates offline by default without requiring third-party cloud services or paid APIs. Demonstration checkouts simulate purchases without collecting or charging real financial credentials.
