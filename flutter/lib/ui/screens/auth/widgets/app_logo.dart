import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../utils/ui_utils.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key});

  @override
  Widget build(context) => SizedBox(
        height: 240,
        width: 240,
        child: SvgPicture.asset(
          UiUtils.getImagePath("brain_logo.svg"),
          // color: Theme.of(context).primaryColor,
        ),
      );
}
