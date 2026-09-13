import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/network/websocket/connection_status.dart';
import '../../cubit/connection_cubit.dart';

/// Reflects real connection state — Live / Reconnecting… / Offline — never
/// a static icon. Only this badge rebuilds when the status flips, thanks
/// to `context.select`.
class ConnectionStatusBadge extends StatelessWidget {
  /// On narrow phones there isn't room for the full "Reconnecting…" label
  /// next to the ticker/theme/debug buttons — compact mode drops to just
  /// the dot (still the real status, just no text) with a tooltip.
  final bool compact;

  const ConnectionStatusBadge({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final status = context.select<ConnectionCubit, ConnectionStatus>((c) => c.state.status);

    final (color, label, icon) = switch (status) {
      ConnectionStatus.live => (const Color(0xFF17803D), 'Live', Icons.circle),
      ConnectionStatus.reconnecting => (const Color(0xFFE0A100), 'Reconnecting…', Icons.sync),
      ConnectionStatus.offline => (const Color(0xFFD62839), 'Offline', Icons.cloud_off),
    };

    final badge = Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 6 : 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StatusDot(color: color, animate: status == ConnectionStatus.reconnecting),
          if (!compact) ...[
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ],
      ),
    );

    return compact ? Tooltip(message: label, child: badge) : badge;
  }
}

class _StatusDot extends StatefulWidget {
  final Color color;
  final bool animate;

  const _StatusDot({required this.color, required this.animate});

  @override
  State<_StatusDot> createState() => _StatusDotState();
}

class _StatusDotState extends State<_StatusDot> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.animate) {
      return Icon(Icons.circle, size: 8, color: widget.color);
    }
    return FadeTransition(
      opacity: _controller,
      child: Icon(Icons.circle, size: 8, color: widget.color),
    );
  }
}
