import 'package:flutter_bloc/flutter_bloc.dart';

import 'holdings_ui_state.dart';

class HoldingsUiCubit extends Cubit<HoldingsUiState> {
  HoldingsUiCubit() : super(const HoldingsUiState());

  void setSearchQuery(String query) => emit(state.copyWith(searchQuery: query));

  void setSort(HoldingsSortColumn column) {
    if (state.sortColumn == column) {
      emit(state.copyWith(sortAscending: !state.sortAscending));
    } else {
      emit(state.copyWith(sortColumn: column, sortAscending: true));
    }
  }

  void setFilter(SummaryFilter filter) => emit(state.copyWith(activeFilter: filter));
}
