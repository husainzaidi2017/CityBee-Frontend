# CityBee — Flutter Frontend

<div align="center">

**CityBee** — a hyperlocal city & business discovery app.
Find doctors, restaurants, hotels, salons, shops, offers, heritage places and more — anywhere in the world.

**Flutter · Material 3 · Riverpod · GoRouter · Supabase Auth · NestJS API**

</div>

---

## Overview

CityBee lets users discover local businesses around **any selected location** (powered by Google Places). Users browse as guests or sign in with **Google** or **email + password**. All data comes from the CityBee backend:

- **Backend repo:** [husainzaidi2017/CityBee-Backend](https://github.com/husainzaidi2017/CityBee-Backend) (NestJS + TypeScript, deployed on Google Cloud Run)
- **Database:** Supabase PostgreSQL + PostGIS
- **Image storage:** Cloudinary

## Features

| Area | What it does |
|---|---|
| 🗺️ **Location** | Search any city/area worldwide (Google Places). Selected location persists across restarts. No hardcoded city list. |
| 📍 **Nearby discovery** | Businesses, offers and places searched by coordinates with **category-wise progressive radius expansion** (5→10→25→50→100 km) — decided by the backend, not the app. |
| 🏥 **Categories** | Food & Dining, Doctors, Hotels, Salons, Fashion, Grocery, Heritage, Malls, Cinemas… loaded from the API. |
| 🔐 **Authentication** | Google Sign-In (native account picker) · Email + Password (sign-in / sign-up with email verification) · Guest browsing always available. |
| 👤 **Profile** | Name/avatar/phone editing, email read-only (account identity), instant load via warm-start cache. |
| ❤️ **Favorites** | Local for guests, synced to the backend when signed in. |
| 🔔 **Notifications** | Deep linking to offer/business/place detail screens. |
| 📞 **Quick actions** | One-tap Call / WhatsApp / Google Maps directions / Share on every listing. |
| 🖼️ **Images** | Optimized Cloudinary delivery (≤1200px, WebP) with cached loading and graceful fallbacks. |

## Screens

```
Splash → Login
  └─ 5-tab shell: Home · Offers · Services · Explore · More
       ├─ Home: categories grid, popular nearby, offers rail
       ├─ Offers: tag-filtered deals list
       ├─ Explore: places, food highlights, city guide
       └─ More: profile, favorites, settings, about, legal
  └─ Detail screens: Business / Doctor / Restaurant / Hotel / Offer / Place
  └─ Search, All Categories, Edit Profile, notifications sheet
```

Navigation: **GoRouter** with a stateful 5-tab shell; detail routes push above it.

## Architecture

```
lib/
├── main.dart                    # Supabase.init + profile warm-start cache
├── app.dart                     # MaterialApp.router + auth session listener
├── core/
│   ├── constants/app_config.dart    # API base URL, Supabase keys, client IDs
│   ├── network/api_client.dart      # HTTP envelope client (Bearer auth)
│   ├── errors/app_exception.dart    # user-friendly error hierarchy
│   ├── services/                    # location, share, notification navigator
│   ├── theme/                       # CityBee orange design system
│   └── widgets/                     # AppImage, cards, sheets, states
├── data/
│   ├── mock/                        # offline/mock data (fallback & tests)
│   └── repositories/                # contracts + API implementations
│       └── api/                     # ApiCity/Business/Offer/Place/Profile…
├── domain/models/                   # Business, Offer, Place, CityBeeLocation…
├── features/                        # auth, home, offers, services, explore,
│                                    # businesses, search, profile, shell
├── providers/app_providers.dart     # Riverpod providers & controllers
└── routing/app_router.dart          # GoRouter graph
```

**State management:** Riverpod (`Notifier` controllers + `FutureProvider.autoDispose` for content). All content providers re-scope automatically when the selected location changes.

**Repository pattern:** every data source is behind an abstract contract (`BusinessRepository`, `AuthRepository`, …) with an API implementation and a mock implementation — swap or test either without UI changes.

### Location architecture (important)

- The user's selected location is a **`CityBeeLocation`** (Google Places data: display name, coordinates, place id) — **never** a `cities` table row.
- `cities` in Supabase is CityBee reference data only (businesses/places anchor to `city_id`).
- Selecting a location stores it in `SharedPreferences` (guests) and on the user profile (signed-in) — and does **not** create any database city record.
- Discovery sends **coordinates** to the backend, which runs PostGIS nearby queries with per-category radius expansion.

### Authentication

| Flow | Path |
|---|---|
| Google | Native picker → Google ID token → Supabase `signInWithIdToken` → session |
| Email sign-in | Email + password → Supabase `signInWithPassword` → session |
| Email sign-up | Name/email/password → account created (no session) → email verification (link or 6-digit code) → session |
| Session restore | Supabase persists sessions; profile warm-starts from cache |

After any successful sign-in the app **awaits** the profile load (`/users/me` upserts `public.users` from auth metadata) before navigating — so Edit Profile shows name/email immediately.

Deep link: `citybee://auth-callback` (registered in the Android manifest and allow-listed in Supabase URL Configuration) completes email-link activations in-app.

## Getting started

### Prerequisites

- Flutter 3.47+ (stable)
- A running [CityBee backend](https://github.com/husainzaidi2017/CityBee-Backend) (or the deployed Cloud Run URL)

### Run

```bash
flutter pub get
flutter run \
  --dart-define=API_BASE_URL=https://citybee-918786981660.asia-south2.run.app/api \
  --dart-define=GOOGLE_SERVER_CLIENT_ID=<your-web-oauth-client-id>
```

Defaults (see `lib/core/constants/app_config.dart`) point at the production Cloud Run API; override per environment with `--dart-define`:

| Define | Purpose |
|---|---|
| `API_BASE_URL` | NestJS API base (dev: `http://localhost:3000/api` or `http://10.0.2.2:3000/api` on the Android emulator) |
| `GOOGLE_SERVER_CLIENT_ID` | Google OAuth **web** client ID (same one configured on the Supabase Google provider) — public identifier, not a secret |
| `SUPABASE_URL` / `SUPABASE_ANON_KEY` | Defaults baked in; override for another project |

### Build

```bash
# Release APK (production API)
flutter build apk --release \
  --dart-define=API_BASE_URL=https://citybee-918786981660.asia-south2.run.app/api \
  --dart-define=GOOGLE_SERVER_CLIENT_ID=<web-client-id>

# Web
flutter build web --release --dart-define=API_BASE_URL=<url>
```

## Configuration notes

- **No secrets in this app.** Only publishable values live here (Supabase URL + anon key, Google web client ID). The service-role key, Cloudinary API secret and Google Maps server key exist **only** in the backend.
- **Google Sign-In** requires: the Google provider enabled in Supabase (web client ID + secret), an Android OAuth client (package `com.localgo.localgo` + your keystore SHA-1) and consent-screen branding completed.
- **Email verification emails** need custom SMTP in Supabase to be customizable (6-digit code via `{{ .Token }}` template); without SMTP the built-in sender (2/hour) sends a magic link — which the app handles via deep link.

## Testing

```bash
flutter analyze   # 0 issues expected
flutter test      # widget + API-mapper unit tests
```

## Related repositories

| Repo | Contents |
|---|---|
| [CityBee-Backend](https://github.com/husainzaidi2017/CityBee-Backend) | NestJS API, Supabase migrations (schema + RLS + constraints), Cloudinary upload pipeline, discovery/radius-expansion engine |
