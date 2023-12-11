import 'package:flutter/material.dart';
import 'package:flutterquiz/app/app_localization.dart';
import 'package:flutterquiz/utils/constants/fonts.dart';
import 'package:flutterquiz/utils/colors.dart';

class SubcategoriesLevelChip extends StatefulWidget {
  final bool isLevelUnlocked;
  final bool isLevelPlayed;
  final int currIndex;
  final double width;

  const SubcategoriesLevelChip({
    super.key,
    this.width = 90,
    required this.isLevelUnlocked,
    required this.currIndex,
    required this.isLevelPlayed,
  });

  @override
  State<SubcategoriesLevelChip> createState() => _SubcategoriesLevelChipState();
}

class _SubcategoriesLevelChipState extends State<SubcategoriesLevelChip> {
  IconData? icon;
  Color? iconColor;
  Color? textColor;
  Color? backgroundColor;

  @override
  void didChangeDependencies() {
    if (widget.isLevelPlayed) {
      icon = Icons.check_circle_rounded;
      iconColor = Theme.of(context).primaryColor;
      textColor = Theme.of(context).colorScheme.onTertiary;
      backgroundColor = Theme.of(context).primaryColor.withOpacity(.3);
    } else {
      if (widget.isLevelUnlocked) {
        icon = Icons.lock_open_rounded;
        iconColor = Theme.of(context).colorScheme.onTertiary;
        textColor = Theme.of(context).colorScheme.onTertiary;
        backgroundColor = Theme.of(context).scaffoldBackgroundColor;
      } else {
        icon = Icons.lock_rounded;
        iconColor = Theme.of(context).colorScheme.onTertiary.withOpacity(.3);
        textColor = Theme.of(context).colorScheme.onTertiary.withOpacity(.3);
        backgroundColor = Theme.of(context).colorScheme.onSurface;
      }
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ShapeDecoration(
              color: white,
              shadows: [
                BoxShadow(
                  color: wood_smoke,
                  offset: Offset(
                    0.0, // Move to right 10  horizontally
                    4.0, // Move to bottom 5 Vertically
                  ),
                )
              ],
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                  side: BorderSide(color: wood_smoke, width: 2))),
      width: widget.width,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "${AppLocalization.of(context)!.getTranslatedValues("levelLbl")!} ${widget.currIndex + 1}",
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeights.regular,
            ),
          ),
          Icon(icon, size: 15, color: iconColor),
        ],
      ),
    );
  }
}
