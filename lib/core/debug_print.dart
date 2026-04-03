import 'dart:convert';

import 'package:flutter/foundation.dart';

void appPrint(Object?  value){
  if (kDebugMode) {
    print(value);
  }
}


void safePrint(String text, {int chunkSize = 800}) {
  final pattern = RegExp('.{1,$chunkSize}', dotAll: true);
  for (final match in pattern.allMatches(text)) {
    print(match.group(0));
  }
}

void appPrintJson(Object? json, {String indent = '  '}) {
  if (!kDebugMode) return;

  try {
    const encoder = JsonEncoder.withIndent('  ');
    final pretty = encoder.convert(json);

    // ✅ print in chunks so full JSON is shown
    safePrint(pretty, chunkSize: 800);
  } catch (e) {
    safePrint("❌ appPrintJson error: $e");
    safePrint(json.toString());
  }
}
