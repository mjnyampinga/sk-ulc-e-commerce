import 'package:e_commerce/core/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PhoneEntryScreen extends StatefulWidget {
  const PhoneEntryScreen({Key? key}) : super(key: key);

  @override
  State<PhoneEntryScreen> createState() => _PhoneEntryScreenState();
}

class _PhoneEntryScreenState extends State<PhoneEntryScreen> {
  final TextEditingController phoneController =
      TextEditingController(text: '+250');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 32),
                // Back Button
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: const Color(0xFFE8ECF4), width: 2),
                      color: Colors.white,
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        size: 24,
                        color: const Color(0xFF219EBC),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Logo
                Center(
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 72,
                    height: 72,
                  ),
                ),
                const SizedBox(height: 32),
                // Title
                Text(
                  'Enter your mobile\nnumber',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.urbanist(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E232C),
                  ),
                ),
                const SizedBox(height: 12),
                // Subtitle
                Text(
                  'Enter  your active  phone number',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.urbanist(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
                const SizedBox(height: 32),
                // Phone Input
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F8F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    style: GoogleFonts.urbanist(
                      fontSize: 20,
                      color: const Color(0xFF1E232C),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 18),
                      hintText: '+250 (000) 000-00',
                      hintStyle: GoogleFonts.urbanist(
                        color: const Color(0xFFBDBDBD),
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Continue Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Continue',
                      style: GoogleFonts.urbanist(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Terms of use
                Text.rich(
                  TextSpan(
                    text: 'By clicking on "Continue" you are agreeing\nto our ',
                    style: GoogleFonts.urbanist(
                      color: const Color(0xFF9CA3AF),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    children: [
                      TextSpan(
                        text: 'terms of use',
                        style: GoogleFonts.urbanist(
                          color: const Color(0xFF1E232C),
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
