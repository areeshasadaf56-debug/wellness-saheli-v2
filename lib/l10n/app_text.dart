import 'package:flutter/material.dart' hide Text;
import 'package:flutter/material.dart' as m show Text;
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'language_provider.dart';
import 'urdu_string.dart';

/// Translate a string right now (use for non-Text places, e.g. hint text).
String tr(String s) => LanguageProvider.urdu ? translate(s) : s;

final RegExp _arabicChars = RegExp(r'[\u0600-\u06FF]');

/// Drop-in replacement for Flutter's Text.
/// Screens import this instead of Flutter's Text (see install_urdu.ps1),
/// so every Text in the app translates itself when the language changes.
class Text extends StatelessWidget {
  const Text(
    this.data, {
    super.key,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaler,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
  });

  final String data;
  final TextStyle? style;
  final StrutStyle? strutStyle;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final Locale? locale;
  final bool? softWrap;
  final TextOverflow? overflow;
  final TextScaler? textScaler;
  final int? maxLines;
  final String? semanticsLabel;
  final TextWidthBasis? textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;
  final Color? selectionColor;

  @override
  Widget build(BuildContext context) {
    final urdu = Provider.of<LanguageProvider>(context).isUrdu;

    var text = data;
    var textStyle = style;
    var direction = textDirection;

    if (urdu) {
      text = translate(data);
      if (_arabicChars.hasMatch(text)) {
        // Urdu script: use a proper Urdu-capable font, no letter spacing
        // (it breaks joined letters), a bit more line height, no italics.
        final base = GoogleFonts.notoNaskhArabic(textStyle: style);
        textStyle = base.copyWith(
          letterSpacing: 0,
          fontStyle: FontStyle.normal,
          height: style?.height ?? 1.7,
          fontSize: style?.fontSize == null ? null : style!.fontSize! * 1.08,
        );
      } else {
        // Not translated yet (still English): keep it left-to-right so
        // punctuation doesn't jump to the wrong side.
        direction ??= TextDirection.ltr;
      }
    }

    return m.Text(
      text,
      style: textStyle,
      strutStyle: strutStyle,
      textAlign: textAlign,
      textDirection: direction,
      locale: locale,
      softWrap: softWrap,
      overflow: overflow,
      textScaler: textScaler,
      maxLines: maxLines,
      semanticsLabel: semanticsLabel,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
      selectionColor: selectionColor,
    );
  }
}
