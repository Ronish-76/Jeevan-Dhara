import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:jeevandhara/firebase_options.dart';
import 'package:jeevandhara/screens/auth/auth_wrapper.dart';
import 'package:jeevandhara/viewmodels/auth_viewmodel.dart';
import 'package:provider/provider.dart';

// FIX #1: Import all the other ViewModels your app will need.
import 'package:jeevandhara/viewmodels/blood_request_viewmodel.dart';
import 'package:jeevandhara/viewmodels/donor_viewmodel.dart';
import 'package:jeevandhara/viewmodels/inventory_viewmodel.dart';
import 'package:jeevandhara/viewmodels/donation_viewmodel.dart';


void main() async {
  // This setup is perfect. No changes needed here.
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // FIX #2: Use MultiProvider to make all ViewModels available to the app.
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => BloodRequestViewModel()),
        ChangeNotifierProvider(create: (_) => DonorViewModel()),
        ChangeNotifierProvider(create: (_) => InventoryViewModel()),
        ChangeNotifierProvider(create: (_) => DonationViewModel()),
      ],
      child: MaterialApp(
        title: 'Jeevan Dhara',
        // BEST PRACTICE: Use modern Material 3 theming.
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
          visualDensity: VisualDensity.adaptivePlatformDensity,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            elevation: 1,
          ),
        ),
        home: const AuthWrapper(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
