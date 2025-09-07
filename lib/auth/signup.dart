import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:auto_route/auto_route.dart';

import '../routes/navigate.dart';

@RoutePage()
class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _agreeToTerms = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_agreeToTerms) {
      _showSnackBar('Please agree to the terms and conditions', Colors.red);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );

      if (userCredential.user != null) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'email': _emailController.text.trim(),
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        _showSnackBar('Account created successfully!', Colors.green);
        // Navigate to home screen
        // context.router.push(const HomeRoute());
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'weak-password':
          errorMessage = 'The password provided is too weak.';
          break;
        case 'email-already-in-use':
          errorMessage = 'The account already exists for that email.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        case 'operation-not-allowed':
          errorMessage =
              'Email/password accounts are not enabled. Please contact support.';
          break;
        default:
          errorMessage = 'An error occurred. Please try again.';
      }
      _showSnackBar(errorMessage, Colors.red);
    } on FirebaseException catch (e) {
      _showSnackBar('Database error: ${e.message}', Colors.red);
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

  void _navigateToLogin() {
    context.router.push(const LoginRoute());
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
                            'Sign Up',
                            style: TextStyle(
                              fontSize: isTablet ? 36 : 32,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2D2D2D),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Subtitle
                          Text(
                            'Enter your details below & free sign up',
                            style: TextStyle(
                              fontSize: isTablet ? 18 : 16,
                              color: const Color(0xFF999999),
                              fontWeight: FontWeight.w400,
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
                                  hintText: 'Enter Email',
                                  hintStyle: TextStyle(
                                    color: const Color(0xFF666666),
                                    fontSize: isTablet ? 16 : 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFF8F8F8),
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
                                style: TextStyle(fontSize: isTablet ? 16 : 14),
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
                                  fontSize: isTablet ? 18 : 14,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF999999),
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: !_isPasswordVisible,
                                decoration: InputDecoration(
                                  hintText: 'enter password',
                                  hintStyle: TextStyle(
                                    color: const Color(0xFF666666),
                                    fontSize: isTablet ? 16 : 14,
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFF8F8F8),
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
                                style: TextStyle(fontSize: isTablet ? 16 : 14),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your password';
                                  }
                                  if (value.length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: isTablet ? 50 : 40),

                              // Create Account Button
                              SizedBox(
                                width: double.infinity,
                                height: isTablet ? 64 : 56,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _signUp,
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
                                            'Create account',
                                            style: TextStyle(
                                              fontSize: isTablet ? 20 : 18,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                ),
                              ),
                              SizedBox(height: isTablet ? 28 : 20),

                              // Terms and Conditions Checkbox
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: isTablet ? 24 : 20,
                                    width: isTablet ? 24 : 20,
                                    child: Checkbox(
                                      value: _agreeToTerms,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          _agreeToTerms = value ?? false;
                                        });
                                      },
                                      activeColor: const Color(0xFF4285F4),
                                      checkColor: Colors.white,
                                      side: const BorderSide(
                                        color: Color(0xFFBBBBBB),
                                        width: 1.5,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'By creating an account you have to agree with our terms & conditions.',
                                      style: TextStyle(
                                        fontSize: isTablet ? 16 : 14,
                                        color: const Color(0xFF999999),
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: isTablet ? 40 : 30),

                              // Login Link
                              Center(
                                child: RichText(
                                  text: TextSpan(
                                    text: 'Already have an account ? ',
                                    style: TextStyle(
                                      fontSize: isTablet ? 16 : 14,
                                      color: const Color(0xFF999999),
                                      fontFamily: 'Roboto',
                                    ),
                                    children: [
                                      WidgetSpan(
                                        child: GestureDetector(
                                          onTap: _navigateToLogin,
                                          child: Text(
                                            'Log in',
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

                              // Add bottom padding to ensure content is above keyboard
                              SizedBox(height: keyboardHeight > 0 ? 20 : 0),
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
