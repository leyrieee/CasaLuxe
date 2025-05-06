// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_config.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'otp_screen.dart';

class PhoneAuthScreen extends StatefulWidget {
  final String signupMethod;
  final String? googleName;
  final String? googleEmail;

  const PhoneAuthScreen(
      {super.key,
      required this.signupMethod,
      this.googleName,
      this.googleEmail});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  String fullPhoneNumber = '';
  bool _isSendingCode = false;
  String? _errorMessage;

  void _sendCode() async {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      setState(() {
        _errorMessage = 'Please correct the highlighted errors and try again.';
      });
      return;
    }

    _formKey.currentState?.save();

    if (fullPhoneNumber.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Phone number cannot be empty.';
      });
      return;
    }

    setState(() {
      _isSendingCode = true;
      _errorMessage = null;
    });

    try {
      // Check if phone number already exists in Firestore
      final phoneExists =
          await FirestoreService().phoneNumberExists(fullPhoneNumber);
      if (phoneExists) {
        setState(() {
          _isSendingCode = false;
          _errorMessage = 'This phone number is already in use.';
        });
        return;
      }

      await AuthService().verifyPhoneNumber(
        phoneNumber: fullPhoneNumber,
        onVerificationCompleted: (_) {},
        onVerificationFailed: (e) {
          setState(() {
            _isSendingCode = false;
            _errorMessage =
                e.message ?? 'Verification failed. Please try again.';
          });
        },
        onCodeSent: (verificationId) {
          setState(() => _isSendingCode = false);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OtpScreen(
                signupMethod: 'google',
                verificationId: verificationId,
                phoneNumber: fullPhoneNumber,
                googleName: widget.googleName,
                googleEmail: widget.googleEmail,
              ),
            ),
          );
        },
      );
    } catch (e) {
      setState(() {
        _isSendingCode = false;
        _errorMessage = 'Something went wrong. Please try again.';
      });
    }
  }

  void _goBackToLogin() {
    Navigator.pushNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text("Verify Your Phone", style: GoogleFonts.playfairDisplay()),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        elevation: 0,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _goBackToLogin,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text(
                "Your phone number is required to give you the best experience on Casa Luxe — including connecting with artisans.",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 20),
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
                  fullPhoneNumber = phone.completeNumber;
                },
                onSaved: (phone) {
                  if (phone != null) fullPhoneNumber = phone.completeNumber;
                },
                validator: (phone) {
                  if (phone == null || phone.number.trim().isEmpty) {
                    return 'Phone number is required';
                  } else if (phone.countryCode == '+233' &&
                      phone.number.length != 9) {
                    return 'Ghana numbers must have 9 digits';
                  }
                  return null;
                },
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 10),
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSendingCode ? null : _sendCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSendingCode
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Continue',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
