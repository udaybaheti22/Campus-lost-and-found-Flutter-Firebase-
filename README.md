# Campus Lost & Found

A Flutter + Firebase app for reporting, browsing, claiming, and resolving lost or found items on campus. The app is built around MAHE registration IDs, so students can post items, search active reports, submit claims, and let item owners approve or reject claim requests.

## Features

- Register and log in with a 9-digit MAHE registration ID.
- Browse lost and found item reports in real time.
- Search by title, description, and location.
- Filter reports by category (`Lost`, `Found`) and status (`Open`, `Claimed`, `Closed`).
- Report lost or found items with title, description, location, date, and an optional image.
- View item details, reporter information, and current status.
- Submit claim requests for found items.
- Notify owners when a lost item has been found.
- Allow item owners to approve, reject, dismiss, or resolve incoming requests.
- Store item photos in Firebase Storage and app data in Cloud Firestore.

## Tech Stack

- Flutter
- Dart
- Firebase Authentication
- Cloud Firestore
- Firebase Storage
- image_picker

## Project Structure

```text
lib/
  main.dart                    App entry point, Firebase init, routes
  firebase_options.dart         Firebase platform configuration
  models/
    item.dart                   Lost/found item model
    claim.dart                  Claim request model
  screens/
    login_screen.dart           Login with registration ID
    registration_screen.dart    Account creation
    home_screen.dart            Item feed, search, filters
    report_item_screen.dart     Item report form
    item_detail_screen.dart     Item details and claim workflow
  services/
    auth_service.dart           Firebase Auth and user profile helpers
    item_service.dart           Firestore and Storage item/claim operations
```

## Getting Started

### Prerequisites

Install the following before running the project:

- Flutter SDK 3.11.0 or newer
- Dart SDK bundled with Flutter
- Firebase CLI
- Android Studio, Xcode, Chrome, or another Flutter-supported target
- A Firebase project with Authentication, Firestore, and Storage enabled

Check your local Flutter setup:

```bash
flutter doctor
```

### Install Dependencies

```bash
flutter pub get
```

### Firebase Setup

This app expects Firebase to be configured for the target platforms. The repository already contains `lib/firebase_options.dart` and Android's `android/app/google-services.json`, but you should regenerate them if you connect the app to a different Firebase project.

1. Log in to Firebase:

   ```bash
   firebase login
   ```

2. Configure FlutterFire:

   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```

3. In the Firebase console, enable:

   - Email/Password Authentication
   - Cloud Firestore
   - Firebase Storage

The app converts a student's 9-digit registration ID into an internal Firebase Auth email by appending `@mahe.campus`. Users still enter only their registration ID in the UI.

## Running the App

Run on a connected device or emulator:

```bash
flutter run
```

Run on Chrome:

```bash
flutter run -d chrome
```

Build a release APK:

```bash
flutter build apk --release
```

## Firestore Data Model

### `users`

Each document is keyed by Firebase Auth UID.

```text
users/{uid}
  name: string
  regId: string
  createdAt: timestamp
```

### `items`

Created when a user reports a lost or found item.

```text
items/{itemId}
  title: string
  category: "Lost" | "Found"
  description: string
  location: string
  date: timestamp
  status: "Open" | "Claimed" | "Closed"
  imageUrl: string | null
  userId: string
  postedByName: string
  postedByRegId: string
```

### `claims`

Created when a user claims a found item or reports that they found a lost item.

```text
claims/{claimId}
  itemId: string
  claimantId: string
  claimantName: string
  claimantRegId: string
  message: string
  createdAt: timestamp
  status: "Pending" | "Approved" | "Rejected"
```

## Firebase Storage

Item photos are uploaded to:

```text
items/{timestamp}_{fileName}
```

The resulting download URL is saved on the corresponding `items` document as `imageUrl`.

## Development Commands

Analyze the code:

```bash
flutter analyze
```

Run tests:

```bash
flutter test
```

Format Dart files:

```bash
dart format lib test
```

## Notes

- The app starts at `/login` and navigates to `/home` after successful authentication.
- Only item owners can see and manage incoming claims for their own reports.
- Approving a claim marks that claim as approved, closes the item, and rejects other pending claims for the same item.
- Firestore security rules should be configured before production use so users can only edit their own items, submit valid claims, and manage claims for items they own.

