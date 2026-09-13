import 'package:flutter/material.dart';

import '../../../../../core/config/app_config.dart';
import '../../../../../core/utils/formatters.dart';
import 'connection_status_badge.dart';
import 'debug_kill_connection_button.dart';
import 'theme_toggle_button.dart';
import 'ticker_strip.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final AppConfig config;

  const AppHeader({super.key, required this.config});

  @override
  Size get preferredSize => const Size.fromHeight(56 + 40 + 8);

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.sizeOf(context).width < 400;

    return AppBar(
      titleSpacing: 16,
      title: LayoutBuilder(
        builder: (context, constraints) {
          final shortName = config.appName.replaceFirst(' Dev', '').replaceFirst(' QA', '');
          final showDate = constraints.maxWidth > 280;
          final showEnvChip = config.flavor != Flavor.prod && constraints.maxWidth > 160;
          return Row(
            children: [
              Flexible(child: Text(shortName, overflow: TextOverflow.ellipsis)),
              if (showEnvChip) ...[
                const SizedBox(width: 8),
                _EnvChip(label: config.envLabel),
              ],
              if (showDate) ...[
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    Formatters.date(DateTime.now()),
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ],
          );
        },
      ),
      actions: [
        if (config.flavor != Flavor.prod) const DebugKillConnectionButton(),
        ConnectionStatusBadge(compact: isNarrow),
        const SizedBox(width: 4),
        const ThemeToggleButton(),
        const SizedBox(width: 8),
      ],
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(48),
        child: Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: TickerStrip(),
        ),
      ),
    );
  }
}

class _EnvChip extends StatelessWidget {
  final String label;

  const _EnvChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
