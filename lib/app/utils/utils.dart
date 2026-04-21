import 'package:flutter/material.dart';

class AppUtils {
  static Future<DateTime?> datePicker(BuildContext context) {
    final DateTime now = DateTime.now();
    return showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2026),
      lastDate: DateTime(now.year + 1, 12, 31),
      helpText: 'Selecione a data do rancho',
      cancelText: 'Sair',
      confirmText: 'Selecionar',
    );
  }

  static DateTime parseDate(String dateString) {
    List<String> parts = dateString.split('/');
    return DateTime(
      int.parse(parts[2]), // year
      int.parse(parts[1]), // month
      int.parse(parts[0]), // day
    );
  }
}
