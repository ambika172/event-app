# EventHub – Combined Smart Event Management Platform

This project merges five separate Flutter apps into one:

- **event_app** ("EventHub") — animated splash screen, full-featured home
  screen (carousel, categories, featured events), event listing with
  search/filter, and a rich event details screen. Dark theme.
- **smart_event_app (login/register)** ("Smart Events") — email/password
  **Login** and **Register** screens with form validation.
- **event_booking** ("Booking Module") — a booking form (event picker,
  attendee details, tickets, date) with locally-persisted booking history
  (add / view / cancel), using `shared_preferences`.
- **smart_event_app (payment module)** ("Payment & Confirmation") — a
  dedicated **Payment** screen (method selection, card/UPI validation,
  service-charge calculation) and **Booking Confirmation** screen, now
  wired in as the final two steps of the booking flow.
- **day5_app** ("Reviews & Favorites") — an **Event Review & Rating**
  module (add/edit/delete star reviews with validation) and an **Event
  Favorites** module (favorite/unfavorite events, view a favorite-history
  log), now running against the real event catalog and reachable from the
  home screen and event details screen.

## Combined app flow

```
SplashScreen → LoginScreen ⇄ RegisterScreen → HomeScreen → EventListingScreen → EventDetailsScreen
                                                    ↑  |                                  |
                                                    |  └──────── My Bookings ─────────┐   |
                                                    |                                 ↓   ↓
                                                    └──────────── Logout ──── BookingManagementScreen
                                                                              (New Booking / My Bookings)
                                                                                   |
                                                                                   ↓
                                                                              PaymentScreen
                                                                                   |
                                                                                   ↓
                                                                       BookingConfirmationScreen
                                                                     ("Back to My Bookings" pops back to
                                                                      BookingManagementScreen and
                                                                      refreshes the My Bookings tab)
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
5. **Booking Management** (from event_booking) — a 2-tab screen:
   - **New Booking**: pick an event, enter attendee/ticket details and a
     booking date, then tap **Continue to Payment**.
   - **My Bookings**: view booking history persisted on-device and cancel
     any booking.
6. **Payment** (from the payment module, new) — choose a payment method
   (Credit/Debit Card, UPI, Net Banking, Wallet), fill in method-specific
   details with validation (16-digit card number, 3-digit CVV, MM/YY expiry
   not in the past, or a valid UPI ID), see the ticket cost, 5% service
   charge and grand total, then **Pay Now**. On success the booking is saved
   to local storage.
7. **Booking Confirmation** (from the payment module, new) — shows the
   booking ID, event, date, tickets, total, payment method and status, with
   a **Download Ticket** stub and a **Back to My Bookings** button that
   returns to `BookingManagementScreen` and refreshes/switches to the
   **My Bookings** tab.

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
    ├── booking_screen.dart            # New booking form (event_booking);
    │                                   # hands off to PaymentScreen instead
    │                                   # of saving directly
    ├── payment_screen.dart            # Payment method + validation + price
    │                                   # summary (payment module); saves the
    │                                   # Booking, then → BookingConfirmationScreen
    ├── booking_confirmation_screen.dart # Success screen (payment module):
    │                                   # booking summary, Download Ticket
    │                                   # stub, Back to My Bookings
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
- **smart_event_app (payment module)**'s standalone `SmartEventApp` entry
  point was dropped; its `PaymentScreen` and `BookingConfirmationScreen`
  were split out of its single `main.dart` into their own files under
  `lib/screens/`, re-themed to use `AppTheme`'s dark palette instead of the
  original's Material 3 indigo `ThemeData`, and wired into the existing
  booking flow:
  - `booking_screen.dart` no longer has its own inline payment-method
    dropdown or computes the service charge/grand total itself — validating
    the event, attendee details and date is now enough to tap **Continue to
    Payment**, which pushes `PaymentScreen` with that data.
  - `PaymentScreen` owns payment-method selection, card/UPI validation and
    the price breakdown (previously duplicated in both projects — the more
    thorough payment-module version, with card/UPI field validation, won
    out). On **Pay Now** it builds and persists the `Booking` via
    `LocalStorageService.addBooking` (reusing event_booking's model/service
    rather than introducing a second one) and replaces itself with
    `BookingConfirmationScreen`.
  - `BookingConfirmationScreen` was changed to take a `Booking` object
    (instead of individual fields) so it reflects exactly what was saved,
    and gained a **Back to My Bookings** button that pops back to
    `BookingManagementScreen` and invokes the existing
    `onBookingConfirmed` callback to refresh/switch to the My Bookings tab
    — reusing that callback plumbing instead of adding a new mechanism.
  - Removed the unused `dart:math`-based booking-ID generator that used to
    live in `booking_screen.dart`'s confirm step; `PaymentScreen` now owns
    booking-ID generation.
- **day5_app** ("Event Review & Rating" + "Event Favorites" modules) — a
  single-file Flutter build (`main.dart`) with its own `Day5App` entry
  point, mock `MockEvent` catalog, and a bottom-nav shell (Events /
  Favorites / My Reviews tabs). This was merged in as follows:
  - Its standalone `Day5App`/`RootScreen`/`MockEvent` were dropped; the two
    modules now run against the real `Event` model/`sampleEvents` catalog
    from `models/event.dart` instead of their own mock list.
  - **Favorites module** → `models/favorite.dart` (`FavoriteHistoryEntry`)
    plus favorites/history methods added to the existing
    `LocalStorageService` (rather than a separate `FavoritesStore`, so all
    on-device persistence stays in one place). New `FavoritesScreen`
    (3 tabs: All Events / My Favorites / History), re-themed to
    `AppTheme`'s dark palette, reachable from a new **heart icon** (with an
    unread-style favorite-count badge) on `HomeScreen`'s app bar and from a
    favorite toggle on `EventDetailsScreen`'s app bar.
  - **Reviews module** → `models/review.dart` (`Review`) plus
    reviews CRUD methods added to `LocalStorageService`. New
    `ReviewsScreen` (list + add/edit/delete) and `ReviewFormScreen`
    (unchanged validation rules: rating 1–5 required, title ≥ 5 chars,
    description ≥ 20 chars), re-themed to dark mode, reachable from a new
    **review icon** on `HomeScreen`'s app bar and a **"Write a review" /
    "See all reviews"** section on `EventDetailsScreen`, both of which
    pre-select the current event.
  - `pubspec.yaml` — day5_app's only dependency, `shared_preferences`, was
    already present in the combined app, so no changes were needed there.

## Setup

```bash
flutter pub get
flutter run
```
