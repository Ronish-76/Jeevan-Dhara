# API Endpoints for Donor Model

This document outlines the necessary API endpoints for managing donor information.

### Authentication

*   **POST /api/auth/register**
    *   Description: Registers a new donor.
    *   Request Body: `{ "fullName": "John Doe", "email": "john.doe@example.com", "phone": "1234567890", "location": "City", "age": 30, "bloodGroup": "A+", "password": "password123", "donationCapability": "Yes" }`
    *   Response: `{ "message": "Donor registered successfully" }`

*   **POST /api/auth/login**
    *   Description: Logs in a donor.
    *   Request Body: `{ "email": "john.doe@example.com", "password": "password123" }`
    *   Response: `{ "token": "your_jwt_token" }`

### Donor Management

*   **GET /api/donors**
    *   Description: Retrieves a list of all available donors.
    *   Response: `[{ "fullName": "John Doe", "bloodGroup": "A+", ... }]`

*   **GET /api/donors/:id**
    *   Description: Retrieves a single donor by their ID.
    *   Response: `{ "fullName": "John Doe", "bloodGroup": "A+", ... }`

*   **PUT /api/donors/:id**
    *   Description: Updates a donor's information.
    *   Request Body: `{ "phone": "0987654321", "isAvailable": true }`
    *   Response: `{ "message": "Donor updated successfully" }`

*   **DELETE /api/donors/:id**
    *   Description: Deletes a donor.
    *   Response: `{ "message": "Donor deleted successfully" }`

### Search

*   **GET /api/donors/search**
    *   Description: Searches for donors based on blood group and location.
    *   Query Parameters: `?bloodGroup=A%2B&location=City`
    *   Response: `[{ "fullName": "John Doe", "bloodGroup": "A+", ... }]`
