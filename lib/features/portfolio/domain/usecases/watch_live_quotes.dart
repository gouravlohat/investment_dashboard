import '../entities/quote.dart';
import '../repositories/portfolio_repository.dart';

class WatchLiveQuotes {
  final PortfolioRepository _repository;

  WatchLiveQuotes(this._repository);

  Stream<Quote> call() => _repository.watchLiveQuotes();
}
