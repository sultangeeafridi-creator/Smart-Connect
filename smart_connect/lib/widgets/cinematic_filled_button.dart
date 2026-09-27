import 'package:flutter/material.dart';

/// A filled button with a clear ripple, a small press-in motion, and elevation.
class CinematicFilledButton extends StatefulWidget {
  const CinematicFilledButton({
    super.key,
    required this.onPressed,
    required this.child,
  });

  final VoidCallback? onPressed;
  final Widget child;

  @override
  State<CinematicFilledButton> createState() => _CinematicFilledButtonState();
}

class _CinematicFilledButtonState extends State<CinematicFilledButton> {
  bool _pointerDown = false;

  void _setPointerDown(bool value) {
    if (_pointerDown != value) {
      setState(() => _pointerDown = value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Listener(
      onPointerDown: widget.onPressed == null
          ? null
          : (_) => _setPointerDown(true),
      onPointerUp: (_) => _setPointerDown(false),
      onPointerCancel: (_) => _setPointerDown(false),
      child: AnimatedScale(
        scale: _pointerDown ? 0.975 : 1,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        child: FilledButton(
          onPressed: widget.onPressed,
          style: ButtonStyle(
            elevation: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.disabled)) return 0;
              if (states.contains(WidgetState.pressed)) return 2;
              if (states.contains(WidgetState.hovered)) return 7;
              return 5;
            }),
            shadowColor: WidgetStatePropertyAll(
              colors.primary.withValues(alpha: 0.32),
            ),
            overlayColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.pressed)) {
                return colors.onPrimary.withValues(alpha: 0.18);
              }
              return null;
            }),
            splashFactory: InkRipple.splashFactory,
            animationDuration: const Duration(milliseconds: 180),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
