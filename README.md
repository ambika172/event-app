# EventHub – Combined Smart Event Management Platform

This project merges three separate Flutter apps into one:

- **event_app** ("EventHub") — animated splash screen, full-featured home
  screen (carousel, categories, featured events), event listing with
  search/filter, and a rich event details screen. Dark theme.
- **smart_event_app** ("Smart Events") — email/password **Login** and
  **Register** screens with form validation.
- **event_booking** ("Booking Module") — a full booking flow (event picker,
  tickets, payment method, price summary) with locally-persisted booking
  history (add / view / cancel), using `shared_preferences`.

## Combined app flow

```
SplashScreen → LoginScreen ⇄ RegisterScreen → HomeScreen → EventListingScreen → EventDetailsScreen
                                                    ↑  |                                  |
                                                    |  └──────── My Bookings ─────────┐   |
                                                    |                                 ↓   ↓
                                                    └──────────── Logout ──── BookingManagementScreen
                                                                              (New Booking / My Bookings)
```

1. **Splash screen** (from event_app) plays a short animation, then goes to
   **Login**.
2. **Login / Register** (from smart_event_app) — validates email & password;
   "Register" creates an account (mock) and returns to Login; a successful
   login moves to **Home**.
3. **Home screen** (from event_app) — hero carousel, featured events,
   category filters, a **My Bookings icon** (new, opens the booking module),
   and a **logout icon** that signs out back to Login.
4. **Event Listing** and **Event Details** (from event_app) — search,
   filter, and full event details. The **"Book Now"** button now opens the
   booking module (from event_booking) with that event pre-selected.
5. **Booking Management** (from event_booking, new) — a 2-tab screen:
   - **New Booking**: pick an event, enter attendee/ticket details, choose a
     payment method, see a live price summary, and confirm.
   - **My Bookings**: view booking history persisted on-device and cancel
     any booking.

## Project structure

```
lib/
├── main.dart                        # App entry point (EventHubApp)
├── models/
│   ├── event.dart                   # Event model + mock data (event_app)
│   ├── app_theme.dart                # Colors, dark theme, gradients (event_app)
│   ├── remote_event.dart             # Alternate JSON-driven Event model
│   │                                  # (from smart_event_app), unused by
│   │                                  # default — kept for a future switch
│   │                                  # to remote/JSON-backed event data.
│   └── booking.dart                  # Booking model + EventInfo catalog
│                                      # (from event_booking)
├── services/
│   └── local_storage_service.dart    # shared_preferences-backed session +
│                                      # booking history storage (event_booking)
└── screens/
    ├── splash_screen.dart            # Animated splash → Login
    ├── login_screen.dart             # Email/password login → Home
    ├── register_screen.dart          # Registration → Login
    ├── home_screen.dart              # Home feed + My Bookings + logout
    ├── event_listing_screen.dart     # All events + search + filter
    ├── event_details_screen.dart     # Full event details + Book Now
    ├── booking_management_screen.dart # New Booking / My Bookings tabs
    │                                   # (from event_booking's UserPage)
    ├── booking_screen.dart            # New booking form (event_booking)
    └── my_bookings_screen.dart        # Booking history + cancel (event_booking)

assets/
└── events.json                       # Sample JSON dataset (smart_event_app),
                                       # pairs with models/remote_event.dart
```

## What was merged / reconciled

- Two `main.dart` entry points → one `EventHubApp` using event_app's dark
  `AppTheme` and starting at `SplashScreen`.
- Two different `Event` models (event_app's simple model with hardcoded
  sample data vs. smart_event_app's JSON-parsed model) → kept event_app's
  model as the one actually used by the UI, and preserved the JSON model as
  `RemoteEvent`/`RemoteScheduleItem` in `remote_event.dart` plus
  `assets/events.json`, renamed to avoid a class-name clash.
- Two separate `event_listing_screen.dart` / `event_detail_screen.dart`
  pairs (one per project) → kept only event_app's versions since they're
  more feature-complete (search, filters, hero animations, gallery).
- `pubspec.yaml` → merged dependency lists (`carousel_slider`,
  `smooth_page_indicator`, `cached_network_image`, `url_launcher`,
  `cupertino_icons`) and asset declarations.
- Navigation wiring updated so Login → Home (was → Event Listing) and
  Splash → Login (was → Home), so authentication now gates the rest of the
  app.
- **event_booking**'s standalone `SmartEventApp`/`UserPage` entry point was
  dropped in favor of one `EventHubApp`. Its `UserPage` was split into a
  reusable `BookingManagementScreen` (2 tabs: New Booking / My Bookings),
  wired in from two places: a new **My Bookings** icon on `HomeScreen`, and
  the **"Book Now"** button on `EventDetailsScreen` (which now passes the
  event's name through so it's pre-selected in the booking form).
- `local_storage_service.dart` moved to `lib/services/` and its import of
  `models/booking.dart` was updated to a relative `../models/booking.dart`.
- `pubspec.yaml` → added `shared_preferences` (event_booking) to event_app's
  existing dependency list; both projects' `flutter_lints` versions were
  reconciled by keeping event_app's `^3.0.0`.
- Booking form (`booking_screen.dart`) gained an optional
  `initialEventName` constructor param, matched case-insensitively against
  its `availableEvents` catalog, so the booking form starts pre-filled when
  reached from an event's details page.

## Setup

```bash
flutter pub get
flutter run
```
