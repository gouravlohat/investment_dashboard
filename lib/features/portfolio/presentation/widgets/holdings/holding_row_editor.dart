import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/holding.dart';
import '../../cubit/portfolio_cubit.dart';

/// Inline "target price alert" editor for one holding row.
///
/// Snapshot-and-diff: the original value is captured once, in [initState],
/// when the row is opened. Save only calls the cubit (and therefore only
/// "sends" anything) if the parsed value differs from that snapshot —
/// mirroring a partial-update API where sending unchanged fields is wasted
/// traffic. Because this widget never reads `PortfolioCubit`'s quotes
/// (only `read`s it to dispatch the update), a live price tick elsewhere
/// can never rebuild it or touch its `TextEditingController`, so an
/// in-progress unsaved edit is never overwritten.
///
/// Save is optimistic: `PortfolioCubit` applies the new value to state
/// immediately, before the (simulated) network call resolves. If that call
/// fails, the cubit rolls the holding back and this widget just reports
/// it — the text the user typed is left alone so they can retry.
class HoldingRowEditor extends StatefulWidget {
  final Holding holding;

  const HoldingRowEditor({super.key, required this.holding});

  @override
  State<HoldingRowEditor> createState() => _HoldingRowEditorState();
}

class _HoldingRowEditorState extends State<HoldingRowEditor> {
  late double? _snapshot;
  late final TextEditingController _controller;
  bool _saving = false;
  String? _lastSavedMessage;

  @override
  void initState() {
    super.initState();
    _snapshot = widget.holding.targetPriceAlert;
    _controller = TextEditingController(text: _formatSnapshot(_snapshot));
  }

  String _formatSnapshot(double? value) => value == null ? '' : value.toStringAsFixed(2);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final text = _controller.text.trim();
    final parsed = text.isEmpty ? null : double.tryParse(text);

    if (parsed == _snapshot) {
      setState(() => _lastSavedMessage = 'No change — nothing sent');
      return;
    }

    final previousSnapshot = _snapshot;
    setState(() {
      _saving = true;
      _lastSavedMessage = null;
      // Applied optimistically in the cubit already — reflect that here
      // too so a re-tap of Save before the network call resolves is
      // correctly treated as "no change".
      _snapshot = parsed;
    });

    final succeeded = await context
        .read<PortfolioCubit>()
        .updateTargetPriceAlert(widget.holding.symbol, parsed);

    if (!mounted) return;
    setState(() {
      _saving = false;
      if (succeeded) {
        _lastSavedMessage = 'Saved';
      } else {
        // Cubit already rolled the holding back — undo our optimistic
        // snapshot too, but leave the typed text so Save can be retried.
        _snapshot = previousSnapshot;
        _lastSavedMessage = 'Failed to save — tap Save to retry';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
              decoration: InputDecoration(
                labelText: 'Target price alert (₹)',
                isDense: true,
                helperText: _lastSavedMessage,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: (_) {
                if (_lastSavedMessage != null) setState(() => _lastSavedMessage = null);
              },
            ),
          ),
          const SizedBox(width: 12),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
    );
  }
}
