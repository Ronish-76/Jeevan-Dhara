# Jeevan Dhara - Map Integration Guide

This guide provides complete setup and integration instructions for the map-based features across all user roles.

## 📋 Table of Contents

1. [Backend Setup](#backend-setup)
2. [Google Maps API Configuration](#google-maps-api-configuration)
3. [Database Seeding](#database-seeding)
4. [Flutter Setup](#flutter-setup)
5. [API Endpoints](#api-endpoints)
6. [Role-Specific Features](#role-specific-features)

## 🔧 Backend Setup

### Prerequisites

- Node.js (v16 or higher)
- MongoDB (v4.4 or higher)
- Google Maps API Key

### Installation

```bash
cd server
npm install
```

### Environment Variables

Create a `.env` file in the `server/` directory:

```env
PORT=5000
MONGO_URI=mongodb://localhost:27017/jeevan_dhara
GOOGLE_MAPS_API_KEY=your_google_maps_api_key_here
NODE_ENV=development
```

### Database Seeding

Seed the Kathmandu Valley dataset (20 hospitals + 20 blood banks):

```bash
npm run seed:locations
```

This will populate the database with real coordinates for facilities in Kathmandu Valley.

### Start Server

```bash
npm run dev
```

Server will run on `http://localhost:5000`

## 🗺️ Google Maps API Configuration

### 1. Get API Key

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing
3. Enable the following APIs:
   - Maps JavaScript API
   - Geocoding API
   - Directions API
   - Places API (optional)
4. Create credentials (API Key)
5. Restrict the API key for production use

### 2. Flutter Configuration

#### Android

1. Open `android/app/src/main/AndroidManifest.xml`
2. Add inside `<application>` tag:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_GOOGLE_MAPS_API_KEY"/>
```

#### iOS

1. Open `ios/Runner/AppDelegate.swift`
2. Add in `application(_:didFinishLaunchingWithOptions:)`:

```swift
GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY")
```

#### Web

1. Open `web/index.html`
2. Update the script tag:

```html
<script async defer src="https://maps.googleapis.com/maps/api/js?key=YOUR_GOOGLE_MAPS_API_KEY"></script>
```

### 3. Backend Configuration

Add the API key to `server/.env`:

```env
GOOGLE_MAPS_API_KEY=your_google_maps_api_key_here
```

## 🌱 Database Seeding

The seeding script (`server/src/seed/seedLocations.js`) creates:

- **20 Hospitals** with real Kathmandu Valley coordinates
- **20 Blood Banks** with real Kathmandu Valley coordinates

Each location includes:
- Realistic coordinates (latitude/longitude)
- Address information
- Contact details
- Blood type availability
- Services offered
- Inventory data

To re-seed (clears existing data):

```bash
npm run seed:locations
```

## 📱 Flutter Setup

### Dependencies

All required dependencies are in `pubspec.yaml`:

```yaml
dependencies:
  google_maps_flutter: ^2.7.0
  geolocator: ^11.1.0
  http: ^1.2.2
  url_launcher: ^6.3.1
```

Install dependencies:

```bash
flutter pub get
```

### Backend URL Configuration

Update the backend URL in `lib/services/map_service.dart`:

```dart
static const String _baseUrl = 'http://10.0.2.2:5000/api';
```

- **Android Emulator**: `http://10.0.2.2:5000/api`
- **iOS Simulator**: `http://127.0.0.1:5000/api`
- **Physical Device**: Use your computer's IP address (e.g., `http://192.168.1.100:5000/api`)

### Permissions

#### Android

Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```

#### iOS

Add to `ios/Runner/Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to show nearby hospitals and blood banks</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>We need your location to show nearby hospitals and blood banks</string>
```

## 🔌 API Endpoints

### Locations

#### POST `/api/locations/seed`
Seed the database with Kathmandu Valley locations.

#### GET `/api/locations/nearby`
Get nearby locations based on user position.

**Query Parameters:**
- `lat` (required): Latitude
- `lng` (required): Longitude
- `role` (required): `patient`, `donor`, `hospital`, `blood_bank`
- `radius` (optional): Search radius in km (default: 10)
- `bloodType` (optional): Filter by blood type (e.g., "A+")
- `availability` (optional): Filter by inventory level (`low`, `medium`, `high`)
- `limit` (optional): Maximum results (default: 25)

**Response:**
```json
{
  "success": true,
  "count": 15,
  "data": [
    {
      "_id": "...",
      "name": "Bir Hospital",
      "type": "hospital",
      "address": {...},
      "coordinates": [85.3173, 27.7079],
      "distance": 2.5,
      "inventory": {"A+": 15, "B+": 20},
      ...
    }
  ]
}
```

#### GET `/api/locations/bloodbanks/:id/inventory`
Get inventory for a specific blood bank.

### Blood Requests

#### POST `/api/requests/create-from-map`
Create a blood request from map interaction.

**Body:**
```json
{
  "requesterId": "user_id",
  "requesterName": "John Doe",
  "requesterPhone": "+977-9800000000",
  "bloodType": "O+",
  "quantity": 2,
  "urgency": "high",
  "locationId": "location_id",
  "latitude": 27.7172,
  "longitude": 85.3240,
  "address": "Kathmandu",
  "reason": "Emergency surgery"
}
```

#### GET `/api/requests/urgent`
Get urgent blood requests (for donors).

**Query Parameters:**
- `lat` (optional): Donor latitude
- `lng` (optional): Donor longitude
- `radius` (optional): Search radius in km (default: 20)
- `bloodType` (optional): Filter by blood type

### Donor

#### POST `/api/donor/accept-request`
Donor accepts a blood request.

**Body:**
```json
{
  "requestId": "request_id",
  "donorId": "donor_id",
  "locationId": "location_id",
  "notes": "Will arrive in 30 minutes"
}
```

### Routes

#### GET `/api/routes/supply`
Get supply routes for hospitals/blood banks.

**Query Parameters:**
- `facilityId` (required): Facility ID
- `facilityType` (optional): `hospital` or `blood_bank`
- `destinationId` (optional): Filter by destination
- `status` (optional): Route status (default: "pending")

## 👥 Role-Specific Features

### Patient Role

**Map Features:**
- View nearby hospitals and blood banks
- Filter by blood type and distance
- Check blood availability
- Request blood from facilities
- Navigate to selected location via Google Maps

**Implementation:**
- Use `PatientMapScreen` widget
- Calls `getNearbyLocations` with `role=patient`
- Shows hospitals and blood banks
- Allows creating blood requests

### Donor Role

**Map Features:**
- View donation centers (hospitals and blood banks)
- See urgent blood requests with distances
- Accept requests from map
- Estimate distance to donation center
- Navigate to donation location

**Implementation:**
- Use map to show donation centers
- Display urgent requests as markers
- Accept requests via `acceptRequest` API
- Show distance calculations

### Blood Bank Role

**Map Features:**
- View all hospitals in area
- Monitor donor locations
- Track supply routes to hospitals
- View urgent requests from hospitals
- Manage inventory distribution

**Implementation:**
- Use `getSupplyRoutes` API
- Shows routes to hospitals needing supply
- Displays donor locations for coordination
- Inventory management interface

### Hospital Role

**Map Features:**
- Full map view of all facilities
- View nearby blood banks
- Manage blood requests from patients
- Assign delivery routes
- Track donors and requests
- View supply chain

**Implementation:**
- Use `getSupplyRoutes` API
- Shows blood banks for inventory requests
- Displays patient requests
- Route planning for deliveries

## 📍 Location Schema

Each location document follows this structure:

```json
{
  "name": "Hospital Name",
  "type": "hospital" | "blood_bank",
  "geo": {
    "type": "Point",
    "coordinates": [longitude, latitude]
  },
  "address": {
    "street": "Street Address",
    "city": "City",
    "district": "District"
  },
  "contactNumber": "+977-1-XXXXXXX",
  "email": "email@example.com",
  "bloodTypesAvailable": ["A+", "B+", "O+", ...],
  "services": ["Emergency Care", "Blood Request", ...],
  "inventory": {
    "A+": 15,
    "B+": 20,
    "O+": 30
  },
  "availability": {
    "inventoryLevel": "medium",
    "acceptingDonations": true,
    "donorsNeeded": false
  }
}
```

## 🛠️ Troubleshooting

### Map Not Loading

1. Check Google Maps API key is correctly set
2. Verify API key has proper restrictions
3. Check internet connection
4. Review console logs for errors

### No Locations Showing

1. Ensure database is seeded: `npm run seed:locations`
2. Check MongoDB connection
3. Verify coordinates are within Kathmandu Valley bounds
4. Check API response in network tab

### Location Permission Issues

1. Request permissions on app first launch
2. Check platform-specific permission settings
3. Verify manifest/Info.plist permissions

### Backend Connection Errors

1. Verify backend server is running
2. Check backend URL in `map_service.dart`
3. Test API endpoints with Postman/curl
4. Check CORS settings in backend

## 📚 Additional Resources

- [Google Maps Flutter Plugin](https://pub.dev/packages/google_maps_flutter)
- [MongoDB Geospatial Queries](https://docs.mongodb.com/manual/geospatial-queries/)
- [Google Maps Platform Documentation](https://developers.google.com/maps/documentation)

## 🎯 Testing

### Test Nearby Locations

```bash
curl "http://localhost:5000/api/locations/nearby?lat=27.7172&lng=85.3240&role=patient&radius=10"
```

### Test Blood Request Creation

```bash
curl -X POST http://localhost:5000/api/requests/create-from-map \
  -H "Content-Type: application/json" \
  -d '{
    "requesterId": "test_user",
    "requesterName": "Test User",
    "requesterPhone": "+977-9800000000",
    "bloodType": "O+",
    "quantity": 2,
    "urgency": "high",
    "latitude": 27.7172,
    "longitude": 85.3240
  }'
```

---

**Note:** Replace all placeholder API keys and URLs with your actual values before deploying to production.

