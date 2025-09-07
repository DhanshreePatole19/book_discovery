import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'routes/navigate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final _appRouter = AppRouter();

  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Study Plan App',
      debugShowCheckedModeBanner: false,
      routerConfig: _appRouter.config(),
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'SF Pro Display',
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    await Future.delayed(Duration(seconds: 2)); // Splash screen delay
    
    try {
      // Check if user manually logged out
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool hasManuallyLoggedOut = prefs.getBool('manually_logged_out') ?? false;
      
      // If user manually logged out, go to onboarding/login
      if (hasManuallyLoggedOut) {
        Navigator.of(context).pushReplacementNamed('/onboarding');
        return;
      }
      
      // Check Firebase Auth state
      User? currentUser = FirebaseAuth.instance.currentUser;
      
      if (currentUser != null) {
        // User is logged in, navigate to home
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        // No user logged in, go to onboarding
        Navigator.of(context).pushReplacementNamed('/onboarding');
      }
    } catch (e) {
      // Error occurred, go to onboarding as fallback
      Navigator.of(context).pushReplacementNamed('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Your app logo or splash image
            Icon(
              Icons.book,
              size: 100,
              color: Color(0xFF4F46E5),
            ),
            SizedBox(height: 20),
            Text(
              'Study Plan App',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4F46E5)),
            ),
          ],
        ),
      ),
    );
  }
}