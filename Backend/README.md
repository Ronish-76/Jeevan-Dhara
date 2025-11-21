# JeevanDhara Backend

## Project Structure

```
Backend/
├── src/
│   ├── config/
│   │   └── database.js          # Database configuration
│   ├── controllers/
│   │   └── requesterController.js # Business logic for requesters
│   ├── models/
│   │   └── Requester.js         # Requester data model
│   ├── routes/
│   │   └── requesterRoutes.js   # API routes
│   └── app.js                   # Express app configuration
├── server.js                    # Main server entry point
├── package.json
└── .env
```

## API Endpoints

- `GET /api/requesters` - Get all requesters
- `POST /api/register` - Register a new requester

## Database

- Database name: `requester`
- Collection: `requesters`