# JeevanDhara – Blood Donation and Emergency Support System

JeevanDhara is a mobile application designed to streamline blood donation, emergency blood requests, and coordination between donors, hospitals, and blood banks in Nepal. The system connects all stakeholders into a unified digital network to ensure faster access to lifesaving blood during emergencies. The project uses Flutter for the frontend, Node.js/Express for the backend, and MongoDB for the database.

## Features

### Core Features
- Multi-role authentication (Requester, Donor, Hospital, Blood Bank)
- Secure login and registration
- GPS-based nearby donor and hospital detection
- Real-time posting of blood requests
- Notifications for donors and institutions
- Search donors by blood group and location
- Donor profiles with donation history
- Hospital and blood bank inventory management
- Blood request tracking and status updates
- Blood donation appointment system

## User Types
- Normal User (Blood Requester)
- Blood Donor
- Hospital
- Blood Bank

## Tech Stack

### Frontend
- Flutter
- Dart
- Provider / Riverpod
- Google Maps API
- Firebase Cloud Messaging

### Backend
- Node.js
- Express.js
- REST API
- JWT Authentication

### Database
- MongoDB
- Mongoose ORM

## App Modules

### Authentication
- Multi-role login and registration
- Password reset and verification
- Secure JWT sessions

### Blood Request System
- Create, update and track blood requests
- Nearby donor detection
- Request cancellation and completion

### Donor Module
- Update availability
- View donation history
- Receive urgent alerts

### Hospital Module
- Manage blood requests
- Manage blood stock
- Approve or decline requests

### Blood Bank Module
- Track blood inventory
- Approve or fulfill blood units
- Manage donor supply

## Project Structure

### Flutter (Frontend)
JeevanDhara/
└── lib/
├── main.dart
├── routes/
├── models/
├── screens/
│ ├── auth/
│ ├── requester/
│ ├── donor/
│ ├── hospital/
│ ├── bloodbank/
├── providers/
├── services/
└── widgets/
assets/
├── icons/
├── images/
### Backend (Node.js)
backend/
├── src/
│ ├── config/
│ ├── controllers/
│ ├── routes/
│ ├── middlewares/
│ ├── models/
│ └── utils/
├── server.js

### MongoDB Collections
- users
- donors
- hospitals
- bloodbanks
- blood_requests
- donations
- inventory

## System Requirements

### Functional Requirements
- Role-based authentication
- Create and view blood requests
- Search donors by group and location
- Manage blood stock
- Notification and alert system

### Non-Functional Requirements
- Fast response time
- Secure authentication
- Scalable backend
- Consistent and clean UI/UX
- High availability and reliability

## Installation and Setup

### Clone Repository
git clone https://github.com/yourusername/JeevanDhara.git

cd JeevanDhara

### Flutter Setup
flutter pub get

### Backend Setup
cd backend
npm install
npm start

### Environment Variables (backend/.env)
MONGO_URI=your_mongodb_url
JWT_SECRET=your_secret
FCM_KEY=your_key

## UI/UX Design
The application uses a Nepal-focused red and white theme, simple medical UI, clean form layouts, and consistent card-based dashboards. Figma screens include splash, onboarding, login, registration, and dashboards for each role.

## Objectives
- Improve emergency blood accessibility in Nepal
- Reduce delays in medical blood matching
- Increase verified donor participation
- Digitize the blood request and donation workflow
- Build a coordinated national blood network

## Security Considerations
- Encrypted passwords using bcrypt
- JWT-secured routes
- Role-based access control
- Input validation on client and server

## Project Status
Early development phase with research, UI wireframes, and login screens completed. Backend integration starting soon.

## License
Open-source license. You may modify and use this code with attribution.

## Contributions
To contribute, submit a pull request or report an issue in GitHub issues.

