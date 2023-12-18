import 'package:flutter/material.dart';
import 'package:flutterquiz/utils/colors.dart';

class ErrorMessageDialog extends StatelessWidget {
  final String? errorMessage;

  const ErrorMessageDialog({super.key, required this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.symmetric(vertical: 24, horizontal: 36),
      actionsAlignment: MainAxisAlignment.center,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: wood_smoke, width: 2)),
      shadowColor: Colors.transparent,
      content: Text(
        errorMessage!,
        style: TextStyle(color: Theme.of(context).colorScheme.onTertiary),
      ),
    );
  }
}
