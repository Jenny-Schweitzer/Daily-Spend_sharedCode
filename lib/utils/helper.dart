import 'dart:math';
import 'dart:ui';
import 'package:intl/intl.dart';

class Helper {
  final int? monthCount;
  final String? monthName;

  Helper({
    this.monthCount,
    this.monthName,
  });

  // Methode, um Monat im Integer (1-12)in ein 'MMM'-Format umzuwandeln
  static String monthToString(int? monthCount) {
    String monthString;
    if (monthCount == null) {
      monthString = "";
    } else {
      List<String> months = DateFormat('MMM').dateSymbols.MONTHS;
      monthString = months[monthCount - 1];
    }
    return monthString;
  }

  // Methode, um Monat im 'MMM'-Format in eine Integer (1-12) umzuwandeln
  static int monthToInt(String? monthName) {
    int monthInt;
    if (monthName == null) {
      monthInt = 0;
    } else {
      List<String> months = DateFormat('MMM').dateSymbols.MONTHS;
      monthInt = months.indexOf(monthName) + 1;
    }
    return monthInt;
  }

  //Methode um eine zufällige Kategiriefarbe zu designen
  static String randomColorString() {
    Color color = baseColors[Random().nextInt(baseColors.length)];
    String selectedColor = color.value
        .toRadixString(16)
        .padLeft(8, '0'); // Erzeugt z.B. "ffaa7f65"
    selectedColor =
        '0x$selectedColor'; // Damit es dem Color value entspricht, z.B. "0xffaa7f65"
    return selectedColor;
  }

  static final List<Color> baseColors = [
    //Base: Primary
    const Color(0xFF12211E),
    const Color(0xFF23433C),
    const Color(0xFF35645A),
    //const Color(0xFF3E7569), //used in Onbording
    const Color(0xFF4F9687),
    const Color(0xFF69B0A0),
    const Color(0xFF69B09F),
    const Color(0xFF8AC1B5),
    const Color(0xFFABD3CA),

    //Base: Secondary
    const Color(0xFF27160C),
    const Color(0xFF4E2C18),
    // const Color(0xFF894D2A), //used in Onbording
    const Color(0xFFC36D3C),
    const Color(0xFFD59976),

    //Base: 0xFF995D81
    const Color(0xFF301D28),
    const Color(0xFF503042),
    const Color(0xFF70435C),
    //const Color(0xFF70435B), //used in Onbording
    const Color(0xFF8F5675),
    const Color(0xFFA9708F),
    const Color(0xFF995D81),

    //Base: 0xFF68764e
    // const Color(0xFF68764e), //used in Onbording
    const Color(0xFF363D29),
    const Color(0xFF515C3D),
    const Color(0xFF6C7A52),
    const Color(0xFF7A8A5C),
  ];
}
