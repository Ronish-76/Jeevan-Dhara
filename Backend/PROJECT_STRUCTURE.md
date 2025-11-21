# JeevanDhara Backend - Project Structure

## Directory Organization

```
Backend/
├── src/
│   ├── config/
│   │   └── database.js              # Database connection setup
│   ├── constants/
│   │   └── httpStatus.js            # HTTP status code constants
│   ├── controllers/
│   │   ├── authController.js        # Authentication logic
│   │   ├── requesterController.js   # Requester business logic
│   │   ├── donorController.js       # Donor business logic
│   │   ├── hospitalController.js    # Hospital business logic
│   │   └── bloodBankController.js   # Blood bank business logic
│   ├── middleware/
│   │   └── auth.js                  # Authentication middleware
│   ├── models/
│   │   ├── Requester.js             # Requester schema
│   │   ├── Donor.js                 # Donor schema
│   │   ├── Hospital.js              # Hospital schema
│   │   └── BloodBank.js             # Blood bank schema
│   ├── routes/
│   │   ├── index.js                 # Centralized route aggregator
│   │   ├── authRoutes.js            # Auth endpoints
│   │   ├── requesterRoutes.js       # Requester endpoints
│   │   ├── donorRoutes.js           # Donor endpoints
│   │   ├── hospitalRoutes.js        # Hospital endpoints
│   │   └── bloodBankRoutes.js       # Blood bank endpoints
│   ├── utils/
│   │   └── errorHandler.js          # Error handling utilities
│   └── app.js                       # Express app configuration
├── server.js                        # Server entry point
├── package.json
├── .env
└── README.md
```

## API Endpoints

All endpoints are prefixed with `/api/v1`

### Authentication
- `POST /api/v1/auth/register` - Register user
- `POST /api/v1/auth/login` - Login user
- `GET /api/v1/auth/profile/:userType/:userId` - Get user profile

### Requesters
- `GET /api/v1/requesters` - Get all requesters
- `POST /api/v1/requesters/register` - Register requester
- `POST /api/v1/requesters/login` - Login requester

### Donors
- `GET /api/v1/donors` - Get all donors
- `POST /api/v1/donors/register` - Register donor

### Hospitals
- `GET /api/v1/hospitals` - Get all hospitals
- `POST /api/v1/hospitals/register` - Register hospital

### Blood Banks
- `GET /api/v1/blood-banks` - Get all blood banks
- `POST /api/v1/blood-banks/register` - Register blood bank

## Key Improvements

✅ **Centralized Route Management** - All routes aggregated in `routes/index.js`
✅ **API Versioning** - Routes prefixed with `/api/v1` for future compatibility
✅ **Error Handling** - Centralized error handler middleware
✅ **Constants** - HTTP status codes in dedicated constants file
✅ **Clean Separation** - Clear separation of concerns across layers
✅ **Scalability** - Easy to add new routes and features
