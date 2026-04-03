import 'package:flutter/material.dart';

TableRow tableRowSpacer(int columnCount , double height) {
  return TableRow(children: [
    ...List.generate(columnCount, (index) =>  SizedBox(height: height,))
  ]);
}