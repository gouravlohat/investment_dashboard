import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/connection_cubit.dart';

/// Dev/QA-only affordance so reconnect/backoff can be demoed and screenshot
/// without needing airplane mode. Not shown in the prod flavor.
class DebugKillConnectionButton extends StatelessWidget {
  const DebugKillConnectionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Simulate disconnect (debug)',
      icon: const Icon(Icons.bolt_outlined),
      onPressed: () => context.read<ConnectionCubit>().debugKillConnection(),
    );
  }
}
