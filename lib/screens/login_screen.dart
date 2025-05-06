// ignore_for_file: use_build_context_synchronously

import 'package:casaluxe/screens/main_layout.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../app_config.dart';
import '../screens/otp_screen.dart';
import '../screens/phone_auth_screen.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();

  PhoneNumber? _phoneNumber;
  String fullPhoneNumber = '';
  bool _isLoading = false;
  String? _errorText;

  void _startPhoneVerification() {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid || _phoneNumber == null) {
      setState(() {
        _errorText =
            'There is an error with your phone number. Please check and try again.';
      });
      return;
    }

    fullPhoneNumber = _phoneNumber!.completeNumber;

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    AuthService().verifyPhoneNumber(
      phoneNumber: fullPhoneNumber,
      onCodeSent: (verificationId) {
        setState(() => _isLoading = false);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpScreen(
              signupMethod: 'phone',
              verificationId: verificationId,
              phoneNumber: fullPhoneNumber,
            ),
          ),
        );
      },
      onVerificationCompleted: (credential) async {
        setState(() => _isLoading = false);
        final userCredential =
            await AuthService().signInWithCredential(credential);
        final user = userCredential.user;

        if (user != null) {
          final exists = await FirestoreService().userProfileExists(user.uid);
          if (exists) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const MainLayout()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => OtpScreen(
                  signupMethod: 'phone',
                  verificationId: '',
                  phoneNumber: fullPhoneNumber,
                ),
              ),
            );
          }
        }
      },
      onVerificationFailed: (e) {
        setState(() {
          _isLoading = false;
          _errorText = _getFriendlyErrorMessage(e);
        });
      },
    );
  }

  String _getFriendlyErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-phone-number':
        return 'This phone number is invalid. Please check and try again.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'quota-exceeded':
        return 'Quota exceeded. Try again later.';
      default:
        return e.message ?? 'An unknown error occurred.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 30),
                  Text(
                    'Sign In',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter your phone number to continue',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 30),
                  IntlPhoneField(
                    controller: _phoneController,
                    initialCountryCode: 'GH',
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: '123456789',
                      hintStyle: GoogleFonts.poppins(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                    ),
                    style: GoogleFonts.poppins(),
                    keyboardType: TextInputType.phone,
                    showDropdownIcon: true,
                    onChanged: (phone) {
                      _phoneNumber = phone;
                    },
                    validator: (phone) {
                      if (phone == null || phone.number.isEmpty) {
                        return 'Phone number is required';
                      } else if (phone.countryCode == '+233' &&
                          phone.number.length != 9) {
                        return 'Number must be 9 digits for Ghana';
                      }
                      return null;
                    },
                  ),
                  if (_errorText != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _errorText!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _startPhoneVerification,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'Sign In',
                              style: GoogleFonts.playfairDisplay(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: const Color(0xFFF5F5F5),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'OR',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildThirdPartyButton(
                    label: 'Continue with Google',
                    icon: Icons.g_mobiledata,
                    onTap: () async {
                      setState(() => _isLoading = true);
                      try {
                        final result = await AuthService().signInWithGoogle();
                        if (result != null) {
                          final UserCredential userCredential =
                              result['credential'];
                          final String name = result['name'];
                          final String email = result['email'];
                          final user = userCredential.user;
                          if (user != null) {
                            final profileExists = await FirestoreService()
                                .userProfileExists(user.uid);
                            if (profileExists) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const MainLayout()),
                              );
                            } else {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PhoneAuthScreen(
                                    signupMethod: 'google',
                                    googleName: name,
                                    googleEmail: email,
                                  ),
                                ),
                              );
                            }
                          }
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Google sign-in failed: $e')),
                        );
                      } finally {
                        setState(() => _isLoading = false);
                      }
                    },
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'By continuing, you agree to our Terms and Privacy Policy.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
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

  Widget _buildThirdPartyButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.black),
        label: Text(
          label,
          style: GoogleFonts.poppins(color: Colors.black),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          elevation: 1,
          side: const BorderSide(color: Colors.grey, width: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}
