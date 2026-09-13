import '../../../../core/network/websocket/connection_status.dart';
import '../../../../core/network/websocket/websocket_client.dart';
import '../../domain/entities/quote.dart';
import '../models/quote_model.dart';

/// Thin adapter between the transport-level [WebsocketClient] (which knows
/// nothing about domain types) and the domain [Quote] stream the
/// repository exposes.
class StockPriceRemoteDataSource {
  final WebsocketClient _client;

  StockPriceRemoteDataSource(this._client);

  Stream<Quote> get quoteStream => _client.quoteStream.map(QuoteModel.fromRawTick);

  Stream<ConnectionStatus> get statusStream => _client.statusStream;

  Future<void> connect(List<String> symbols) => _client.connect(symbols);

  void debugKillConnection() => _client.debugKillConnection();

  void dispose() => _client.dispose();
}
