import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date and currency formatting

class Helpers {
  // --- Formatting ---
  static String formatDate(DateTime? date, {String format = 'dd/MM/yyyy'}) {
    if (date == null) return 'N/A';
    return DateFormat(format).format(date);
  }

  static String formatDateTime(DateTime? dateTime, {String format = 'dd/MM/yyyy HH:mm'}) {
    if (dateTime == null) return 'N/A';
    return DateFormat(format).format(dateTime);
  }

  static String formatCurrency(double? amount, {String symbol = 'S/', int decimalDigits = 2}) {
    if (amount == null) return 'N/A';
    final formatter = NumberFormat.currency(
      locale: 'es_PE', // Spanish (Peru) locale for appropriate formatting
      symbol: symbol,
      decimalDigits: decimalDigits,
    );
    return formatter.format(amount);
  }

  // --- UI Helpers ---
  static void showSnackBar(BuildContext context, String message, {bool isError = false, Duration duration = const Duration(seconds: 3)}) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar(); // Remove existing snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.secondary, // Or primary
        duration: duration,
      ),
    );
  }

  static Future<bool?> showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String content,
    String confirmText = 'Confirmar',
    String cancelText = 'Cancelar',
  }) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: Text(cancelText),
              onPressed: () {
                Navigator.of(dialogContext).pop(false); // User cancelled
              },
            ),
            ElevatedButton(
              child: Text(confirmText),
              onPressed: () {
                Navigator.of(dialogContext).pop(true); // User confirmed
              },
            ),
          ],
        );
      },
    );
  }

  static Future<void> showLoadingDialog(BuildContext context, {String message = 'Cargando...'}) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must not close it manually
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 20),
              Text(message),
            ],
          ),
        );
      },
    );
  }

  static void hideLoadingDialog(BuildContext context) {
    // Check if a dialog is currently open before trying to pop.
    if (Navigator.of(context, rootNavigator: true).canPop()) {
       Navigator.of(context, rootNavigator: true).pop();
    }
  }


  // --- String Manipulation ---
  static String capitalizeFirstLetter(String? text) {
    if (text == null || text.isEmpty) return '';
    return "${text[0].toUpperCase()}${text.substring(1).toLowerCase()}";
  }

  static String getInitials(String? name) {
    if (name == null || name.isEmpty) return '';
    List<String> nameParts = name.trim().split(' ');
    if (nameParts.length == 1) {
      return nameParts[0].isNotEmpty ? nameParts[0][0].toUpperCase() : '';
    }
    return nameParts[0][0].toUpperCase() + nameParts[nameParts.length -1][0].toUpperCase();
  }

  // --- Validation (simple examples) ---
  static bool isValidEmail(String email) {
    return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
  }

  static bool isValidPhoneNumber(String phone, {String countryCode = '51', int minLength = 9}) {
    // Basic Peruvian phone number check (9 digits after country code)
    final RegExp phoneRegExp = RegExp(r'^\d{' + minLength.toString() + r'}$');
    return phoneRegExp.hasMatch(phone.startsWith(countryCode) ? phone.substring(countryCode.length) : phone);
  }
}

// Example Usage:
// Helpers.formatDate(DateTime.now())
// Helpers.showSnackBar(context, "Operation successful!")
// bool? confirmed = await Helpers.showConfirmationDialog(context, title: "Delete Item", content: "Are you sure?");
// String initials = Helpers.getInitials("Juan Perez"); // JP
// if (Helpers.isValidEmail("test@example.com")) { ... }
