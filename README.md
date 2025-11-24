# Jeevan Dhara

Full-stack blood donation platform with a role-aware geospatial map.

## Project Layout

- `lib/` – Flutter application with Google Maps integration (`lib/screens/map/map_screen.dart`)
- `server/` – Node.js + MongoDB backend for geospatial queries (`/api/map/nearby`)

## Backend Setup

```bash
cd server
npm install
copy env.example .env   # set MONGO_URI and PORT
npm run seed:locations  # seeds Kathmandu Valley dataset
npm run dev             # starts Express server
```

## Flutter Setup

1. Enable Windows Developer Mode (needed for Flutter plugins on Windows)  
   `start ms-settings:developers`
2. Add your Google Maps API key to:
   - Android: `android/app/src/main/AndroidManifest.xml`
   - iOS: `ios/Runner/AppDelegate.swift` (`GMSServices.provideAPIKey`)
   - Web: `web/index.html` `<script src="https://maps.googleapis.com/maps/api/js?key=YOUR_KEY"></script>`
3. Run the app pointing to the backend (Android uses `10.0.2.2`, iOS `127.0.0.1` by default)

## Map Module Features

- Patients: find nearby hospitals/blood banks, filter by blood type/distance, request blood, get directions
- Donors: view donation sites, filter by availability, accept requests, navigate
- Hospitals: scan blood banks, request inventory, track delivery routes
- Blood Banks: view hospitals/donors, monitor inventory, manage logistics

Backend responses are validated via MongoDB 2dsphere queries; frontend markers surface role-specific actions through a bottom sheet (`lib/widgets/marker_sheet.dart`).
