import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:auto_route/auto_route.dart';

import '../routes/navigate.dart';
import 'firbase.dart';
import 'verified.dart';

@RoutePage()
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (userCredential.user != null) {
        context.router.push(const Verifiedpage());
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found for that email.';
          break;
        case 'wrong-password':
          errorMessage = 'Wrong password provided.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        case 'user-disabled':
          errorMessage = 'This user account has been disabled.';
          break;
        default:
          errorMessage = 'Login failed. Please try again.';
      }
      _showSnackBar(errorMessage, Colors.red);
    } catch (e) {
      _showSnackBar('An unexpected error occurred.', Colors.red);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _navigateToSignUp() {
    // Navigate to sign up page
    // Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpPage()));
    context.router.push(const SignUpRoute());
  }

  void _forgotPassword() async {
    if (_emailController.text.isEmpty) {
      _showSnackBar('Please enter your email first', Colors.red);
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: _emailController.text.trim());
      _showSnackBar('Password reset email sent', Colors.green);
    } catch (e) {
      _showSnackBar('Error sending reset email', Colors.red);
    }
  }

  void _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential? userCredential = await FirebaseService.signInWithGoogle();

      if (userCredential != null && userCredential.user != null) {
        context.router.push(const Verifiedpage());

        // Navigate to home page
        // context.router.replace(const HomeRoute());
      } else {
        _showSnackBar('Google Sign-In was canceled', Colors.orange);
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Google Sign-In failed';
      if (e.code == 'account-exists-with-different-credential') {
        errorMessage =
            'An account already exists with the same email address but different sign-in credentials.';
      } else if (e.code == 'invalid-credential') {
        errorMessage = 'The credential received is malformed or has expired.';
      }
      _showSnackBar(errorMessage, Colors.red);
    } catch (e) {
      _showSnackBar('An error occurred during Google Sign-In: $e', Colors.red);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    // Responsive padding and sizing
    final horizontalPadding = screenWidth > 600 ? 48.0 : 24.0;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFE8E8E8),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  screenHeight -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  // Top grey section with title
                  Container(
                    width: double.infinity,
                    color: const Color(0xFFE8E8E8),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: isTablet ? 60 : 40),

                          // Title
                          Text(
                            'Log In',
                            style: TextStyle(
                              fontSize: isTablet ? 36 : 32,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2D2D2D),
                            ),
                          ),
                          SizedBox(height: isTablet ? 40 : 30),
                        ],
                      ),
                    ),
                  ),

                  // White container with form
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      constraints: BoxConstraints(
                        maxWidth: isTablet ? 600 : double.infinity,
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(horizontalPadding),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: isTablet ? 30 : 20),

                              // Email Field
                              Text(
                                'Your Email',
                                style: TextStyle(
                                  fontSize: isTablet ? 18 : 16,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF999999),
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  hintText: 'Enter your email',
                                  hintStyle: TextStyle(
                                    color: Colors.grey,
                                    fontSize: isTablet ? 12 : 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFE5E5EA),
                                      width: 1,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFE5E5EA),
                                      width: 1,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF4285F4),
                                      width: 2,
                                    ),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: isTablet ? 20 : 16,
                                  ),
                                ),
                                style: TextStyle(
                                  fontSize: isTablet ? 16 : 14,
                                  color: const Color(0xFF2D2D2D),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  if (!RegExp(
                                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                  ).hasMatch(value)) {
                                    return 'Please enter a valid email';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: isTablet ? 28 : 24),

                              // Password Field
                              Text(
                                'Password',
                                style: TextStyle(
                                  fontSize: isTablet ? 18 : 16,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF999999),
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: !_isPasswordVisible,
                                decoration: InputDecoration(
                                  hintText: 'Enter your password',
                                  hintStyle: TextStyle(
                                    color: Colors.grey,
                                    fontSize: isTablet ? 12 : 14,
                                    // letterSpacing: 2,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isPasswordVisible
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: const Color(0xFF666666),
                                      size: isTablet ? 24 : 20,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isPasswordVisible =
                                            !_isPasswordVisible;
                                      });
                                    },
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFE5E5EA),
                                      width: 1,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFE5E5EA),
                                      width: 1,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF4285F4),
                                      width: 2,
                                    ),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: isTablet ? 20 : 16,
                                  ),
                                ),
                                style: TextStyle(
                                  fontSize: isTablet ? 16 : 14,
                                  color: const Color(0xFF2D2D2D),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your password';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: isTablet ? 20 : 16),

                              // Forgot Password Link
                              Align(
                                alignment: Alignment.centerRight,
                                child: GestureDetector(
                                  onTap: _forgotPassword,
                                  child: Text(
                                    'Forget password?',
                                    style: TextStyle(
                                      fontSize: isTablet ? 16 : 14,
                                      color: const Color(0xFF999999),
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: isTablet ? 40 : 32),

                              // Log In Button
                              SizedBox(
                                width: double.infinity,
                                height: isTablet ? 64 : 56,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _signIn,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF4285F4),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: 0,
                                    disabledBackgroundColor: const Color(
                                      0xFF4A68FF,
                                    ).withOpacity(0.6),
                                  ),
                                  child:
                                      _isLoading
                                          ? SizedBox(
                                            height: isTablet ? 24 : 20,
                                            width: isTablet ? 24 : 20,
                                            child:
                                                const CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                        Color
                                                      >(Colors.white),
                                                ),
                                          )
                                          : Text(
                                            'Log In',
                                            style: TextStyle(
                                              fontSize: isTablet ? 20 : 18,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                ),
                              ),
                              SizedBox(height: isTablet ? 32 : 24),

                              // Sign Up Link
                              Center(
                                child: RichText(
                                  text: TextSpan(
                                    text: 'Don\'t have an account? ',
                                    style: TextStyle(
                                      fontSize: isTablet ? 16 : 14,
                                      color: const Color(0xFF999999),
                                      fontFamily: 'Roboto',
                                    ),
                                    children: [
                                      WidgetSpan(
                                        child: GestureDetector(
                                          onTap: _navigateToSignUp,
                                          child: Text(
                                            'Sign up',
                                            style: TextStyle(
                                              fontSize: isTablet ? 16 : 14,
                                              color: const Color(0xFF4285F4),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: isTablet ? 32 : 24),

                              // Or login with text
                              Center(
                                child: Text(
                                  'Or login with',
                                  style: TextStyle(
                                    fontSize: isTablet ? 16 : 14,
                                    color: const Color(0xFF999999),
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                              SizedBox(height: isTablet ? 24 : 20),

                              // Google Sign In Button
                              Center(
                                child: GestureDetector(
                                  onTap: _signInWithGoogle,
                                  child: Container(
                                    // width: isTablet ? 60 : 52,
                                    // height: isTablet ? 60 : 52,
                                    // decoration: BoxDecoration(
                                    //   color: Colors.white,
                                    //   borderRadius: BorderRadius.circular(12),
                                    //   border: Border.all(
                                    //     color: const Color(0xFFE5E5EA),
                                    //     width: 1,
                                    //   ),
                                    //   boxShadow: [
                                    //     BoxShadow(
                                    //       color: Colors.black.withOpacity(0.05),
                                    //       blurRadius: 4,
                                    //       offset: const Offset(0, 2),
                                    //     ),
                                    //   ],
                                    // ),
                                    child: Center(
                                      child: Image.asset(
                                        'assets/google.png', // You'll need to add Google logo asset
                                        width: isTablet ? 24 : 26,
                                        height: isTablet ? 24 : 26,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // Add bottom padding to ensure content is above keyboard
                              SizedBox(height: keyboardHeight > 0 ? 20 : 24),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
