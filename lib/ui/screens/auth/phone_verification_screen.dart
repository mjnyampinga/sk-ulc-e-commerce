import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:e_commerce/core/services/auth_provider.dart' as app_auth;
import 'package:e_commerce/core/services/firebase_service.dart';
import '../../../core/utils/constants.dart';
import '../../main_scaffold.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PhoneVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;
  final bool isSignUp;
  final String? username;
  final String? userType;

  const PhoneVerificationScreen({
    Key? key,
    required this.phoneNumber,
    required this.verificationId,
    this.isSignUp = false,
    this.username,
    this.userType,
  }) : super(key: key);

  @override
  State<PhoneVerificationScreen> createState() =>
      _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState extends State<PhoneVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );
  bool _isLoading = false;
  String? _error;
  int _resendTimer = 0;
  bool _canResend = true;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
    _setupAutoFocus();
  }

  void _setupAutoFocus() {
    for (int i = 0; i < 5; i++) {
      _controllers[i].addListener(() {
        if (_controllers[i].text.length == 1) {
          _focusNodes[i + 1].requestFocus();
        }
      });
    }
  }

  void _startResendTimer() {
    _resendTimer = 60;
    _canResend = false;
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_resendTimer > 0) {
            _resendTimer--;
          } else {
            _canResend = true;
            timer.cancel();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get _verificationCode {
    return _controllers.map((controller) => controller.text).join();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // Back Button
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: const Color(0xFFE8ECF4), width: 1),
                    color: Colors.white,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      size: 18,
                      color: Color(0xFF1E232C),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(height: 32),

                // Title
                Text(
                  'Verify your\nphone number',
                  style: GoogleFonts.urbanist(
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                    color: const Color(0xFF1E232C),
                  ),
                ),
                const SizedBox(height: 12),

                // Subtitle
                Text(
                  'We\'ve sent a verification code to\n${widget.phoneNumber}',
                  style: GoogleFonts.urbanist(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF8391A1),
                  ),
                ),
                const SizedBox(height: 40),

                // Verification Code Input
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    6,
                    (index) => Container(
                      width: 50,
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F8F9),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _focusNodes[index].hasFocus
                              ? AppConstants.primaryColor
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: TextField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.urbanist(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1E232C),
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          counterText: '',
                        ),
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(1),
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (value) {
                          if (value.length == 1 && index < 5) {
                            _focusNodes[index + 1].requestFocus();
                          }
                          _checkCodeComplete();
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Error Message
                if (_error != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Text(
                      _error!,
                      style: GoogleFonts.urbanist(
                        color: Colors.red.shade700,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                if (_error != null) const SizedBox(height: 20),

                // Verify Button
                Consumer<app_auth.AuthProvider>(
                  builder: (context, authProvider, child) {
                    return SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading || authProvider.isLoading
                            ? null
                            : _handleVerification,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading || authProvider.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Verify',
                                style: GoogleFonts.urbanist(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 30),

                // Resend Code
                Center(
                  child: Column(
                    children: [
                      Text(
                        'Didn\'t receive the code?',
                        style: GoogleFonts.urbanist(
                          color: const Color(0xFF8391A1),
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _canResend ? _resendCode : null,
                        child: Text(
                          _canResend
                              ? 'Resend Code'
                              : 'Resend Code in $_resendTimer seconds',
                          style: GoogleFonts.urbanist(
                            color: _canResend
                                ? AppConstants.primaryColor
                                : const Color(0xFF8391A1),
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            decoration: _canResend
                                ? TextDecoration.underline
                                : TextDecoration.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _checkCodeComplete() {
    if (_verificationCode.length == 6) {
      _handleVerification();
    }
  }

  Future<void> _handleVerification() async {
    if (_verificationCode.length != 6) {
      setState(() {
        _error = 'Please enter the complete 6-digit code';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authProvider =
          Provider.of<app_auth.AuthProvider>(context, listen: false);

      bool success;
      if (widget.isSignUp) {
        // For sign up, we need to create the user first
        success = await authProvider.signUpWithPhone(
          phoneNumber: widget.phoneNumber,
          username: widget.username ?? 'User',
          userType: widget.userType ?? 'client',
        );
      } else {
        // For sign in
        success = await authProvider.signInWithPhone(
          phoneNumber: widget.phoneNumber,
          verificationId: widget.verificationId,
          smsCode: _verificationCode,
        );
      }

      if (success && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScaffold()),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Verification failed: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _resendCode() async {
    try {
      await FirebaseService.verifyPhoneNumber(
        phoneNumber: widget.phoneNumber,
        onCodeSent: (String verificationId) {
          // Update the verification ID
          // Note: In a real app, you might want to store this in a provider
          print('Code sent to ${widget.phoneNumber}');
        },
        onCodeAutoRetrievalTimeout: (String verificationId) {
          print('Auto retrieval timeout');
        },
        onVerificationCompleted: (PhoneAuthCredential credential) {
          // Auto-verification completed
          print('Auto verification completed');
        },
        onVerificationFailed: (FirebaseAuthException e) {
          setState(() {
            _error = 'Failed to send code: ${e.message}';
          });
        },
      );
      _startResendTimer();
    } catch (e) {
      setState(() {
        _error = 'Failed to resend code: $e';
      });
    }
  }
}
