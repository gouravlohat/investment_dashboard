import '../../../../core/network/websocket/raw_quote_tick.dart';
import '../../domain/entities/quote.dart';

/// Maps the transport-level [RawQuoteTick] (from whichever WebsocketClient
/// is wired up) into the domain [Quote] entity.
class QuoteModel {
  static Quote fromRawTick(RawQuoteTick tick) => Quote(
        symbol: tick.symbol,
        price: tick.price,
        changePercent: tick.changePercent,
        timestamp: tick.timestamp,
      );
}
