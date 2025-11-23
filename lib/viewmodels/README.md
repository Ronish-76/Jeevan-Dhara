# ViewModels

This directory contains all ViewModels following the MVVM (Model-View-ViewModel) architecture pattern.

## Structure

- **BaseViewModel**: Abstract base class providing common functionality (loading, error handling)
- **BloodRequestViewModel**: Manages blood request state and business logic
- **DonorViewModel**: Manages donor-specific state and business logic
- **InventoryViewModel**: Manages inventory and facility state
- **DonationViewModel**: Manages donation state and business logic
- **AuthViewModel**: Manages authentication state and business logic

## Usage

ViewModels are provided via `MultiProvider` in `main.dart` and accessed in Views using:

```dart
final viewModel = Provider.of<BloodRequestViewModel>(context);
```

Or using `Consumer`:

```dart
Consumer<BloodRequestViewModel>(
  builder: (context, viewModel, child) {
    return Text('Requests: ${viewModel.totalRequests}');
  },
)
```

## Migration from Providers

All old `*Provider` classes have been renamed to `*ViewModel`:
- `RequestProvider` → `BloodRequestViewModel`
- `DonorProvider` → `DonorViewModel`
- `InventoryProvider` → `InventoryViewModel`
- `DonationProvider` → `DonationViewModel`
- `AuthProvider` → `AuthViewModel`

Update imports and class names accordingly.

