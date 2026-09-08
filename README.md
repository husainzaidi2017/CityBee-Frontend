# LocalGo — City & Local Discovery App

A Flutter application for discovering local offers, businesses (restaurants, doctors, hotels, salons, shops, malls), city services and places — built city-first around Moradabad (Peetal Nagri) but architected for any city.

## Tech stack

| Concern | Choice |
|---|---|
| UI | Flutter · Material 3 |
| State management | Riverpod (`flutter_riverpod`) |
| Navigation | GoRouter (stateful 5-tab shell) |
| Backend (planned) | Supabase PostgreSQL + PostGIS |
| Auth (planned) | Supabase Auth |
| Storage (planned) | Supabase Storage |
| Location | Geolocator |
| Images | `cached_network_image` |
| External actions | `url_launcher` (call / WhatsApp / Google Maps) |

## Architecture

```
lib/
  app.dart                     # MaterialApp.router
  main.dart                    # ProviderScope entry point
  core/
    constants/                 # (reserved)
    theme/                     # AppColors · AppTypography · AppSpacing · AppRadius · AppShadows · AppTheme
    utils/                     # AppLauncher (call/WhatsApp/maps) · Formatters
    services/                  # LocationService (Geolocator wrapper)
    widgets/                   # AppImage · chips · buttons · badges · search bar ·
                               # SectionHeader · StatesView · MapPreview · LocationAppBar
    errors/                    # AppException hierarchy (user-friendly messages)
  routing/app_router.dart      # GoRouter graph
  providers/app_providers.dart # Repositories + city/favorites/content providers
  domain/models/               # City · AppCategory · Business · Offer · Place · Review ·
                               # MenuItem · ServiceItem · Helpline · UserProfile
  data/
    mock/                      # Realistic mock content (screenshot-accurate)
    repositories/              # Abstract contracts + Mock implementations
  features/
    shell/                     # Bottom-nav shell (Home · Offers · Services · Explore · More)
    home/ offers/ services/ explore/ businesses/ search/ profile/
      presentation/            # Screens + feature-local widgets
```

**Data flow:** `UI → Riverpod provider → Repository (abstract) → Mock/Supabase implementation`.
No widget queries mock data or Supabase directly.

## Key design decisions

- **One Business model** for every category. Doctor/hotel specifics ride in optional fields (`consultationFee`, `amenities`, `timings`…); the detail screen renders category-specific sections from the same model — no duplicated architectures.
- **City-aware everything.** `selectedCityProvider` is watched by every content provider, so switching cities (city picker sheet) re-scopes all screens. Adding a city = adding one `City` record.
- **MapPreview is the single map surface** (CustomPaint placeholder today). Replace its internals with `GoogleMap` when the API key is configured — screens don't change.
- **Mock-first strategy.** Mock repositories simulate network latency so loading/empty/error states are exercised. Swap to Supabase by changing the five provider assignments in `app_providers.dart`.
- **Errors never surface raw.** Repositories/services throw `AppException` subtypes; the UI shows `userMessage` text.

## Screens

| Route | Screen |
|---|---|
| `/` | Home — search, quick chips, hero banner, category grid, offers rail, popular businesses, city places, owner CTA |
| `/offers` | Offers — filter chips, featured coupon hero, verified deals list, savings banner |
| `/offer/:id` | Offer detail — coupon copy, validity, business block, call/WhatsApp |
| `/services` | Services Hub — helplines, Brass Shield banner, specialist sections, events, legal aid |
| `/explore` | Explore — city guide hero, spotlights, food rail, explorer tips |
| `/place/:id` | Place detail |
| `/category/:id` | Business listing — filters, sort, list ↔ map toggle |
| `/business/:id` | Business detail — carousel, actions, deal banner, highlights, menu, map, reviews, sticky booking bar |
| `/search` | Live search with trending terms |
| `/more`, `/favorites` | Profile/stats/city tools/support · bookmarks |

## Next steps (backend wiring)

1. Create the Supabase schema (`cities`, `categories`, `businesses`, `offers`, `places`, `reviews`, `favorites`, …) with PostGIS and RLS per the implementation plan.
2. Implement `Supabase*Repository` classes next to the mocks; flip the five providers.
3. Supabase Auth for the profile; Firebase (FCM/Analytics/Crashlytics) via `flutterfire configure`.
4. Google Maps key in `android/app/src/main/AndroidManifest.xml`, then swap the `MapPreview` painter for a real `GoogleMap`.

## Running

```bash
flutter pub get
flutter run             # on a connected Android device/emulator
flutter analyze         # clean
flutter test            # widget smoke test
flutter build apk --debug
```
