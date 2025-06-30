import 'dart:convert';

import 'package:http/http.dart' as http;

const String apiUrl = 'https://order-placed.vercel.app';
const String apiKey = '319dac37bedb0b7905a731608e082a47';

Future<void> sendConfirmEmail(Map<String, dynamic> orderDetails) async {
  print('Sending confirmation email with details: $orderDetails');
  try {
    await http.post(
      Uri.parse('$apiUrl/send-order-confirm'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(orderDetails),
    );
    print('Email sent successfully');
  } catch (e) {
    print('Error sending email: $e');
    return;
  }
}
