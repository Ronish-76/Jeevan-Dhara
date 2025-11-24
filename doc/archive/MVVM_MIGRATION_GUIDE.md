# MVVM Architecture Migration Guide

## Overview
The codebase has been refactored to follow the **Model-View-ViewModel (MVVM)** architectural pattern for better separation of concerns, testability, and maintainability.

## Architecture Structure

```
lib/
├── models/          # Data models (pure data classes)
├── views/           # UI components (screens, widgets)
├── viewmodels/      # Business logic and state management
├── services/        # API calls, data fetching
└── utils/           # Helper functions
```

## Key Changes

### 1. Providers → ViewModels
All providers have been renamed and refactored to ViewModels:

- `RequestProvider` → `BloodRequestViewModel`
- `DonorProvider` → `DonorViewModel`
- `InventoryProvider` → `InventoryViewModel`
- `DonationProvider` → `DonationViewModel`
- `AuthProvider` → `AuthViewModel`

### 2. Base ViewModel
All ViewModels extend `BaseViewModel` which provides:
- `isLoading` state management
- `error` state management
- Common helper methods (`setLoading`, `setError`, `clearError`)

### 3. Separation of Concerns

**Models** (`lib/models/`):
- Pure data classes
- JSON serialization/deserialization
- No business logic

**ViewModels** (`lib/viewmodels/`):
- Business logic
- State management
- Data transformation
- Service orchestration

**Views** (`lib/screens/`, `lib/widgets/`):
- UI rendering only
- User interaction handling
- No business logic
- Access ViewModels via `Provider.of<ViewModel>(context)`

**Services** (`lib/services/`):
- API calls
- Data fetching
- External service integration
- No state management

## Migration Steps for Existing Code

### Step 1: Update Imports

**Before:**
```dart
import 'package:jeevandhara/providers/request_provider.dart';
import 'package:jeevandhara/providers/donor_provider.dart';
```

**After:**
```dart
import 'package:jeevandhara/viewmodels/blood_request_viewmodel.dart';
import 'package:jeevandhara/viewmodels/donor_viewmodel.dart';
```

### Step 2: Update Provider References

**Before:**
```dart
final provider = Provider.of<RequestProvider>(context);
final requests = provider.requests;
```

**After:**
```dart
final viewModel = Provider.of<BloodRequestViewModel>(context);
final requests = viewModel.requests;
```

### Step 3: Update Method Calls

Most method names remain the same, but check the ViewModel for any new methods or renamed ones.

## ViewModel Features

### BloodRequestViewModel
- `fetchActiveRequests()` - Get all active requests
- `submitRequest()` - Create new request
- `respondToRequest()` - Respond to a request
- `getRequestsByStatus()` - Filter by status
- `getRequestsByBloodType()` - Filter by blood type

### DonorViewModel
- `loadUrgentRequests()` - Load urgent requests near donor
- `respondToRequest()` - Donor responds to request
- `getRequestsByBloodType()` - Filter by blood type
- `getRequestsWithinDistance()` - Filter by distance

### InventoryViewModel
- `fetchNearbyFacilities()` - Get nearby facilities
- `fetchFacilityInventory()` - Get inventory for facility
- `getFacilitiesWithBloodType()` - Filter by blood type
- `getFacilitiesWithLowStock()` - Get low stock facilities

### DonationViewModel
- `fetchDonationHistory()` - Get donation history
- `createDonation()` - Create new donation
- `getDonationsByStatus()` - Filter by status
- `getDonationsByBloodType()` - Filter by blood type

### AuthViewModel
- `login()` - User login
- `register()` - User registration
- `logout()` - User logout
- `getCurrentUser()` - Get current user info
- `resetPassword()` - Reset password

## Benefits of MVVM

1. **Separation of Concerns**: Clear boundaries between UI, business logic, and data
2. **Testability**: ViewModels can be tested independently of UI
3. **Maintainability**: Changes to business logic don't affect UI and vice versa
4. **Reusability**: ViewModels can be reused across different views
5. **Scalability**: Easy to add new features without affecting existing code

## Next Steps

1. Update all screen files to use new ViewModel imports
2. Remove old provider files (after migration is complete)
3. Add unit tests for ViewModels
4. Document ViewModel methods and their usage

