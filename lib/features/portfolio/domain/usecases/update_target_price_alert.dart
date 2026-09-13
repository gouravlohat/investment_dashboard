import '../../../../core/utils/result.dart';
import '../repositories/portfolio_repository.dart';

/// Snapshot-and-diff lives in the presentation layer (the editor widget
/// knows what the original value was); this use case only fires the
/// actual "send" once the caller has already decided the value changed.
class UpdateTargetPriceAlert {
  final PortfolioRepository _repository;

  UpdateTargetPriceAlert(this._repository);

  Future<Result<void>> call(String symbol, double? newValue) =>
      _repository.updateTargetPriceAlert(symbol, newValue);
}
