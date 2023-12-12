import 'package:flutter/material.dart';
import 'package:flutterquiz/utils/constants/fonts.dart';
import 'package:flutterquiz/utils/colors.dart';
import 'package:google_fonts/google_fonts.dart';

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
        child: Container(
          margin: EdgeInsets.only(top: 24),
          padding: EdgeInsets.all(6),
          decoration: ShapeDecoration(
              color: lightening_yellow,
              shadows: [
                BoxShadow(
                  color: wood_smoke,
                  offset: Offset(
                    0.0, // Move to right 10  horizontally
                    6.0, // Move to bottom 5 Vertically
                  ),
                )
              ],
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                  side: BorderSide(color: wood_smoke, width: 2))),
          child: LayoutBuilder(
            builder: (_, constraints) {
              var cSize = constraints.maxWidth;
              final iconSize = cSize * .28;
              final iconColor = Theme.of(context).primaryColor;

              return Stack(
                children: [
                  /// Card
                  Container(
                    width: cSize,
                    height: cSize * 0.3,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(_borderRadius),
                      color: lightening_yellow,
                    ),
                    padding: _padding,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        /// Title
                        Text('$title!',
                            maxLines: 1,
                            overflow: TextOverflow.clip,
                            style: GoogleFonts.montserrat(
                              textStyle: TextStyle(
                                fontWeight: FontWeights.extrabold,
                                fontSize: 24.0,
                                color: Theme.of(context).colorScheme.onTertiary,
                              ),
                            )),

                        /// Description
                        // Expanded(
                        //   child: Text(
                        //     desc,
                        //     maxLines: 2,
                        //     overflow: TextOverflow.ellipsis,
                        //     style: TextStyle(
                        //       fontSize: 14,
                        //       fontWeight: FontWeights.regular,
                        //       color: Theme.of(context)
                        //           .colorScheme
                        //           .onTertiary
                        //           .withOpacity(0.6),
                        //     ),
                        //   ),
                        // ),

                        /// Svg Icon
                        // Align(
                        //   alignment: iconOnRight
                        //       ? Alignment.bottomRight
                        //       : Alignment.bottomLeft,
                        //   child: Container(
                        //     decoration: BoxDecoration(
                        //       color: Colors.transparent,
                        //       borderRadius:
                        //           BorderRadius.circular(_iconBorderRadius),
                        //       border: Border.all(
                        //         color: Theme.of(context).scaffoldBackgroundColor,
                        //       ),
                        //     ),
                        //     padding: _iconMargin,
                        //     width: iconSize,
                        //     height: iconSize,
                        //     child: SvgPicture.asset(img, color: iconColor),
                        //   ),
                        // )
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ));
  }
}
