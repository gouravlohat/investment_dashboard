import 'bootstrap.dart';
import 'core/config/app_config.dart';

/// Pass the real key at build/run time:
///   --dart-define=FINNHUB_API_KEY=your_key_here
/// Never hardcode it here.
const _finnhubApiKey = String.fromEnvironment('FINNHUB_API_KEY');

void main() {
  bootstrap(AppConfig.prod(
    finnhubApiKey: _finnhubApiKey.isEmpty ? null : _finnhubApiKey,
  ));
}
