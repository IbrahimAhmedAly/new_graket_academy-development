import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

Future<bool> checkInternetFunction() async {
  if (kIsWeb) {
    // On web, assume online — browser handles connectivity
    return true;
  }
  try {
    final response = await http
        .get(Uri.parse('https://www.google.com'))
        .timeout(const Duration(seconds: 5));
    return response.statusCode == 200;
  } catch (_) {
    return false;
  }
}