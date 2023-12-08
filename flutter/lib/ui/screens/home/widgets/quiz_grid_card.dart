import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterquiz/utils/constants/fonts.dart';

class QuizGridCard extends StatelessWidget {
  const QuizGridCard({
    super.key,
    required this.title,
    required this.desc,
    required this.img,
    this.onTap,
    this.iconOnRight = true,
  });

  final String title;
  final String desc;
  final String img;
  final bool iconOnRight;
  final void Function()? onTap;

  ///
  static const _borderRadius = 10.0;
  static const _padding = EdgeInsets.all(12.0);
  static const _iconBorderRadius = 6.0;
  static const _iconMargin = EdgeInsets.all(5.0);

  static const _boxShadow = [
    BoxShadow(
      offset: Offset(0, 50),
      blurRadius: 30,
      spreadRadius: 5,
      color: Color(0xff45536d),
    )
  ];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: LayoutBuilder(
        builder: (_, constraints) {
          var cSize = constraints.maxWidth;
          final iconSize = cSize * .28;
          final iconColor = Theme.of(context).primaryColor;

          return Stack(
            children: [
              /// Box Shadow
              Positioned(
                top: 0,
                left: cSize * 0.2,
                right: cSize * 0.2,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    boxShadow: _boxShadow,
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(cSize * .525),
                    ),
                  ),
                  width: cSize,
                  height: cSize * .6,
                ),
              ),

              /// Card
              Container(
                width: cSize,
                height: cSize,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(_borderRadius),
                  color: Theme.of(context).colorScheme.background,
                ),
                padding: _padding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    /// Title
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.clip,
                      style: TextStyle(
                        fontWeight: FontWeights.semiBold,
                        fontSize: 18.0,
                        color: Theme.of(context).colorScheme.onTertiary,
                      ),
                    ),

                    /// Description
                    Expanded(
                      child: Text(
                        desc,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeights.regular,
                          color: Theme.of(context)
                              .colorScheme
                              .onTertiary
                              .withOpacity(0.6),
                        ),
                      ),
                    ),

                    /// Svg Icon
                    Align(
                      alignment: iconOnRight
                          ? Alignment.bottomRight
                          : Alignment.bottomLeft,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius:
                              BorderRadius.circular(_iconBorderRadius),
                          border: Border.all(
                            color: Theme.of(context).scaffoldBackgroundColor,
                          ),
                        ),
                        padding: _iconMargin,
                        width: iconSize,
                        height: iconSize,
                        child: SvgPicture.asset(img, color: iconColor),
                      ),
                    )
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
