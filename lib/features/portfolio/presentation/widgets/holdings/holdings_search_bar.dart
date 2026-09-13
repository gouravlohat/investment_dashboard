import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/holdings_ui_cubit.dart';

/// Owns its own [TextEditingController] in `State`, created once. Because
/// this widget never reads `PortfolioCubit`/quotes, a price tick can never
/// cause it to rebuild — so the controller (and whatever the user typed)
/// survives every tick untouched.
class HoldingsSearchBar extends StatefulWidget {
  const HoldingsSearchBar({super.key});

  @override
  State<HoldingsSearchBar> createState() => _HoldingsSearchBarState();
}

class _HoldingsSearchBarState extends State<HoldingsSearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: context.read<HoldingsUiCubit>().state.searchQuery);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        hintText: 'Search holdings by symbol or company…',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _controller.text.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _controller.clear();
                  context.read<HoldingsUiCubit>().setSearchQuery('');
                  setState(() {});
                },
              ),
        isDense: true,
      ),
      onChanged: (value) {
        context.read<HoldingsUiCubit>().setSearchQuery(value);
        setState(() {});
      },
    );
  }
}
