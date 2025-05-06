// ignore_for_file: use_build_context_synchronously

import 'package:casaluxe/screens/main_layout.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import '../app_config.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../screens/profile_form_screen.dart';

class OtpScreen extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;
  final String signupMethod;
  final String? googleName;
  final String? googleEmail;

  const OtpScreen({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
    required this.signupMethod,
    this.googleName,
    this.googleEmail,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _codeController = TextEditingController();
  bool isVerifying = false;
  String? error;
  bool canResend = false;
  int secondsRemaining = 60;
  Timer? _timer;
  late String _currentVerificationId;

  @override
  void initState() {
    super.initState();
    _currentVerificationId = widget.verificationId;
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      canResend = false;
      secondsRemaining = 60;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsRemaining == 0) {
        timer.cancel();
        setState(() => canResend = true);
      } else {
        setState(() => secondsRemaining--);
      }
    });
  }

  void _resendCode() async {
    setState(() => canResend = false);
    _startTimer();

    await AuthService().verifyPhoneNumber(
      phoneNumber: widget.phoneNumber,
      onVerificationCompleted: (_) {},
      onVerificationFailed: (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to resend code: ${e.message}')),
        );
      },
      onCodeSent: (newVerificationId) {
        setState(() => _currentVerificationId = newVerificationId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP code resent')),
        );
      },
    );
  }

  void _verifyCode() async {
    setState(() {
      isVerifying = true;
      error = null;
    });

    try {
      final phoneCredential = PhoneAuthProvider.credential(
        verificationId: _currentVerificationId,
        smsCode: _codeController.text.trim(),
      );

      final currentUser = FirebaseAuth.instance.currentUser;

      if (widget.signupMethod == 'google' && currentUser != null) {
        // 🔐 Link phone credential to the current Google user
        await currentUser.linkWithCredential(phoneCredential);

        // 📥 Check if profile exists for this UID
        final profileExists =
            await FirestoreService().userProfileExists(currentUser.uid);

        if (!profileExists) {
          await FirestoreService().createUserProfile(
            uid: currentUser.uid,
            name: widget.googleName ?? '',
            phone: widget.phoneNumber,
            email: widget.googleEmail ?? '',
            signupMethod: 'google',
          );
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainLayout()),
        );
      } else {
        // 🚪 Regular phone sign-in
        final userCredential =
            await AuthService().signInWithCredential(phoneCredential);
        final user = userCredential.user;

        if (user == null) throw FirebaseAuthException(code: 'user-null');

        final profileExists =
            await FirestoreService().userProfileExists(user.uid);

        if (profileExists) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainLayout()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => ProfileFormScreen(
                phoneNumber: widget.phoneNumber,
                signupMethod: widget.signupMethod,
              ),
            ),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        error = e.message ?? 'Verification failed.';
        isVerifying = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: isVerifying ? null : () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Verify ${widget.phoneNumber}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Enter the 6-digit code sent via SMS',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: _codeController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  style: GoogleFonts.poppins(fontSize: 20, letterSpacing: 2),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    counterText: '',
                    filled: true,
                    fillColor: Colors.white,
                    hintText: '123456',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                  ),
                ),
                if (error != null) ...[
                  const SizedBox(height: 10),
                  Text(error!, style: const TextStyle(color: Colors.red)),
                ],
                const SizedBox(height: 20),
                if (!canResend)
                  Text(
                    'Resend code in $secondsRemaining seconds',
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: Colors.grey[600]),
                  ),
                if (canResend)
                  TextButton(
                    onPressed: _resendCode,
                    child: const Text('Resend Code'),
                  ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isVerifying ? null : _verifyCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isVerifying
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Verify',
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
      ),
    );
  }
}
