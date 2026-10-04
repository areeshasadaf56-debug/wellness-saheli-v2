import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'language_provider.dart';

/// Small floating EN | اردو switch shown on every screen.
/// Drag it anywhere if it is covering something; tap to switch language.
class LanguageFab extends StatefulWidget {
  const LanguageFab({super.key});

  @override
  State<LanguageFab> createState() => _LanguageFabState();
}

class _LanguageFabState extends State<LanguageFab> {
  Offset? _pos;
  static const double _w = 92;
  static const double _h = 36;

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final size = MediaQuery.sizeOf(context);
    final pad = MediaQuery.paddingOf(context);

    _pos ??= Offset(size.width - _w - 10, size.height * 0.38);
    final left = _pos!.dx.clamp(6.0, size.width - _w - 6);
    final top = _pos!.dy.clamp(pad.top + 6, size.height - _h - pad.bottom - 70);

    return Positioned(
      left: left,
      top: top,
      child: GestureDetector(
        onPanUpdate: (d) => setState(() => _pos = Offset(left, top) + d.delta),
        onTap: () => lang.toggle(),
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: _w,
            height: _h,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFF1D3DF)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF912260).withValues(alpha: 0.18),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [_half('EN', !lang.isUrdu), _half('اردو', lang.isUrdu)],
            ),
          ),
        ),
      ),
    );
  }

  Widget _half(String label, bool active) {
    return Expanded(
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? const Color(0xFF912260) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: active ? Colors.white : const Color(0xFF7D4A65),
            decoration: TextDecoration.none,
          ),
        ),
      ),
    );
  }
}
