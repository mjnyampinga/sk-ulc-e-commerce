import 'package:e_commerce/core/utils/constants.dart';
import 'package:e_commerce/ui/screens/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 24),
                // Product Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: Image.asset(
                    'assets/icons/cosmetics1.png',
                    width: 320,
                    height: 220,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 32),
                // Logo
                Image.asset(
                  'assets/images/logo.png',
                  width: 64,
                  height: 64,
                ),
                const SizedBox(height: 32),
                // Title
                Text(
                  'Get your cosmetics\ndelivered to your home',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.urbanist(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E232C),
                  ),
                ),
                const SizedBox(height: 16),
                // Subtitle
                Text(
                  'The best delivery app in town for\ndelivering cosmetics',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.urbanist(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
                const SizedBox(height: 40),
                // Shop now button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () async {
                      // Navigate to PhoneEntryScreen first
                      // final result = await Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //       builder: (context) => const PhoneEntryScreen()),
                      // );
                      // After phone entry, go to LoginScreen
                      // if (result == true || result == null) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginScreen()),
                      );
                      // }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Get Started',
                      style: GoogleFonts.urbanist(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
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
