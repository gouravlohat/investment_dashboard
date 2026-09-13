import 'package:flutter/material.dart';

/// Wraps [child] and briefly flashes a colored background whenever [value]
/// changes (compared with `==`), fading back to transparent. Used to
/// animate price updates green/red without touching the child's own
/// rebuild logic.
class FlashOnChange<T> extends StatefulWidget {
  final T value;
  final Color flashColor;
  final Widget child;
  final Duration duration;

  const FlashOnChange({
    super.key,
    required this.value,
    required this.flashColor,
    required this.child,
    this.duration = const Duration(milliseconds: 700),
  });

  @override
  State<FlashOnChange<T>> createState() => _FlashOnChangeState<T>();
}

class _FlashOnChangeState<T> extends State<FlashOnChange<T>> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );
  late final Animation<double> _progress = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

  @override
  void didUpdateWidget(covariant FlashOnChange<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _progress,
      builder: (context, child) => DecoratedBox(
        decoration: BoxDecoration(
          color: widget.flashColor.withValues(alpha: (1 - _progress.value) * 0.3),
          borderRadius: BorderRadius.circular(4),
        ),
        child: child,
      ),
      child: widget.child,
    );
  }
}
