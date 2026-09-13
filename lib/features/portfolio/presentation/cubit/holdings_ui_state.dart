import 'package:equatable/equatable.dart';

enum HoldingsSortColumn { symbol, quantity, avgBuyPrice, currentPrice, profitLoss }

enum SummaryFilter { all, profit, loss, todaysGainers, todaysLosers }

/// Pure UI state: search text, sort choice, active summary filter. Lives
/// in its own Cubit, completely separate from [PortfolioCubit], so a price
/// tick can never reset the search box, sort order, or scroll position.
class HoldingsUiState extends Equatable {
  final String searchQuery;
  final HoldingsSortColumn sortColumn;
  final bool sortAscending;
  final SummaryFilter activeFilter;

  const HoldingsUiState({
    this.searchQuery = '',
    this.sortColumn = HoldingsSortColumn.symbol,
    this.sortAscending = true,
    this.activeFilter = SummaryFilter.all,
  });

  HoldingsUiState copyWith({
    String? searchQuery,
    HoldingsSortColumn? sortColumn,
    bool? sortAscending,
    SummaryFilter? activeFilter,
  }) =>
      HoldingsUiState(
        searchQuery: searchQuery ?? this.searchQuery,
        sortColumn: sortColumn ?? this.sortColumn,
        sortAscending: sortAscending ?? this.sortAscending,
        activeFilter: activeFilter ?? this.activeFilter,
      );

  @override
  List<Object?> get props => [searchQuery, sortColumn, sortAscending, activeFilter];
}
