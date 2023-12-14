import 'package:flutter/material.dart';
import 'package:flutterquiz/ui/custom_widgets/button_round_with_shadow.dart';
import 'package:flutterquiz/utils/colors.dart';

class CustomBackButton extends StatelessWidget {
  final bool? removeSnackBars;
  final Color? iconColor;
  final Function? onTap;

  const CustomBackButton({
    super.key,
    this.removeSnackBars,
    this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap == null
          ? () {
              Navigator.pop(context);
              if (removeSnackBars != null && removeSnackBars!) {
                ScaffoldMessenger.of(context).removeCurrentSnackBar();
              }
            }
          : () {
              onTap?.call();
            },
      child: ButtonRoundWithShadow(
          size: 8,
          borderColor: wood_smoke,
          color: white,
          callback: () {
            Navigator.pop(context);
          },
          shadowColor: wood_smoke,
          iconPath: "assets/icons/arrow_back.svg"),
    );
  }
}

class QBackButton extends StatelessWidget {
  const QBackButton({
    super.key,
    this.onTap,
    this.removeSnackBars = true,
    this.color,
  });

  final bool removeSnackBars;
  final void Function()? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap == null
          ? () {
              Navigator.pop(context);
              if (removeSnackBars != null && removeSnackBars!) {
                ScaffoldMessenger.of(context).removeCurrentSnackBar();
              }
            }
          : () {
              onTap?.call();
            },
      child: ButtonRoundWithShadow(
          size: 8,
          borderColor: wood_smoke,
          color: white,
          callback: () {
            Navigator.pop(context);
          },
          shadowColor: wood_smoke,
          iconPath: "assets/icons/arrow_back.svg"),
    );
  }
}
