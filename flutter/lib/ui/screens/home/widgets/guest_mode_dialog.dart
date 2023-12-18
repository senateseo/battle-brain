import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterquiz/app/app_localization.dart';
import 'package:flutterquiz/utils/colors.dart';

class GuestModeDialog extends StatelessWidget {
  const GuestModeDialog({
    super.key,
    required this.onTapYesButton,
    this.onTapNoButton,
  });

  final Function() onTapYesButton;
  final Function? onTapNoButton;

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(color: Theme.of(context).primaryColor);
    final appLocalization = AppLocalization.of(context);
    return AlertDialog(
      contentPadding: EdgeInsets.symmetric(vertical: 24, horizontal: 24),
      alignment: Alignment.center,
      actionsAlignment: MainAxisAlignment.center,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: wood_smoke, width: 2)),
      content: Wrap(children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [Text(appLocalization!.getTranslatedValues("guestMode")!)],
        )
      ]),
      actions: [
        OutlinedButton(
          style: OutlinedButton.styleFrom(
              backgroundColor: white,
              side: BorderSide(color: wood_smoke, width: 2)),
          onPressed: () {
            if (onTapNoButton != null) {
              onTapNoButton!();
              return;
            }
            Navigator.pop(context);
          },
          child: Text(
            appLocalization.getTranslatedValues("cancel")!,
            style: TextStyle(color: black),
          ),
        ),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
              backgroundColor: black,
              side: BorderSide(color: wood_smoke, width: 2)),
          onPressed: onTapYesButton,
          child: Text(
            appLocalization.getTranslatedValues("loginLbl")!,
            style: TextStyle(color: white),
          ),
        ),
      ],
    );
  }
}
