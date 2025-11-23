# JeevanDhara API Documentation

## 🔐 Authentication Module

### Universal Auth (Recommended)
- **POST** `/api/auth/register` - Multi-role registration (donor/requester)
- **POST** `/api/auth/login` - Multi-role authentication
- **GET** `/api/auth/profile/:userType/:userId` - User profile retrieval

### Role-Specific Auth (Legacy)
- **POST** `/api/donors/login` - Donor-only authentication
- **POST** `/api/requesters/login` - Requester-only authentication

## 🩸 Donor Management Module

### Registration & Profile
- **POST** `/api/donors/register` - Donor registration
- **GET** `/api/donors/:id` - Get donor profile
- **PUT** `/api/donors/:id` - Update donor profile
- **DELETE** `/api/donors/:id` - Remove donor account

### Discovery & Search
- **GET** `/api/donors` - List all available donors
- **GET** `/api/donors/search?bloodGroup=A+&location=City` - Advanced donor search

## 🏥 Requester Management Module

### Registration & Profile
- **POST** `/api/requesters/register` - Requester registration
- **GET** `/api/requesters` - List all requesters (Admin)

## 🆘 Blood Request Module

### Request Lifecycle
- **POST** `/api/requests` - Create urgent blood request
- **GET** `/api/requests` - List all blood requests
- **GET** `/api/requests/:id` - Get specific request details
- **PUT** `/api/requests/:id` - Update request status
- **DELETE** `/api/requests/:id` - Cancel blood request

## 📊 API Summary

| Module | Endpoints | Status |
|--------|-----------|--------|
| Authentication | 5 | ✅ Complete |
| Donor Management | 6 | ✅ Complete |
| Requester Management | 2 | ✅ Complete |
| Blood Requests | 5 | ✅ Complete |
| **Total** | **18** | **✅ Production Ready** |