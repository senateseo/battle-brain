import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterquiz/utils/colors.dart';
import 'package:flutterquiz/utils/ui_utils.dart';

class ButtonRoundWithShadow extends StatelessWidget {
  final Color borderColor;
  final Color shadowColor;
  final Color color;
  final String iconPath;
  final VoidCallback callback;
  final double size;

  const ButtonRoundWithShadow(
      {required this.borderColor,
      required this.shadowColor,
      required this.color,
      required this.iconPath,
      required this.size,
      required this.callback});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: callback,
      child: Container(
        height: size == null ? null : size,
        width: size == null ? null : size,
        padding: EdgeInsets.all(size != null ? 8 : 8),
        margin: EdgeInsets.all(8.0), // THIS affects to the button size
        decoration: ShapeDecoration(
            shadows: [
              BoxShadow(
                color: shadowColor,
                offset: Offset(
                  0.0, // Move to right 10  horizontally
                  4.0, // Move to bottom 5 Vertically
                ),
              )
            ],
            color: color,
            shape:
                CircleBorder(side: BorderSide(color: borderColor, width: 2))),
        child: SvgPicture.asset(
                      UiUtils.getImagePath("arrow_back.svg"),
                      height: 16, width: 16,
                      fit: BoxFit.scaleDown
                    ),
      ),
    );
  }
}
