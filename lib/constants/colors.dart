import 'package:flutter/material.dart';
import 'package:sms/utils/constants.dart';


class FzColors {
  FzColors._();
  static Color bgcolor =
      Constants.darkModeOn ? Color(0xFF05050C) : Color(0xFFFFFFFF);
  static Color whiteText = Constants.darkModeOn ? Colors.white : Colors.black;
  static Color lightText = Color(0xFF5E5F64);
  static Color textBoxColor = Color(0xFF262A34);
  // static Color btnColor = Color(0xFFFB4242);
  static Color btnColor = Color(0xFF1F6E8C);
  static Color errColor = Color(0xFFFF0000);
  static Color msgloadingColor = Color(0xfff5a623);
  static Color msgleftbgcolor = Color(0xFF17202A);
  static Color msgrightbgcolor = Color(0xFF006064);
  static Color nameColor = Color(0xFFFFD700);
}
