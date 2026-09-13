# Mindorigin Portfolio

Live investment dashboard built for the Mindorigin Flutter assignment. Mock holdings, live prices over a WebSocket, a performance chart, and a reconnect flow that actually works instead of just showing a spinner.

Live demo (web build, dev flavor): **https://investmentdasgboard.web.app**

## Running it

```bash
flutter pub get
flutter test
```

There are 3 flavors, each its own entrypoint and its own feed config (not just a different name/icon):

```bash
# dev - simulated prices, 8 symbols, updates fast (~900ms)
flutter run -t lib/main_dev.dart --flavor dev --dart-define=FLAVOR=dev

# qa - simulated too, but fewer symbols and slower ticks, on purpose
flutter run -t lib/main_qa.dart --flavor qa --dart-define=FLAVOR=qa

# prod - real Finnhub feed, you'll need a free API key from finnhub.io
flutter run -t lib/main_prod.dart --flavor prod --dart-define=FLAVOR=prod --dart-define=FINNHUB_API_KEY=your_key
```

iOS has real flavors too (own bundle id per flavor), same command just add a device:
```bash
flutter run -d <device> -t lib/main_dev.dart --flavor dev --dart-define=FLAVOR=dev
```

macOS/web don't really have a flavor concept in Flutter so just drop `--flavor` and keep the rest. Plain `flutter run` with nothing specified falls back to dev.

## Libraries

- **flutter_bloc + equatable** - Cubit for state, `context.watch`/`select` everywhere. Equatable is the reason `select()` actually skips rebuilds.
- **web_socket_channel** - the real socket connection for prod.
- **connectivity_plus** - so "offline" means the phone actually has no internet, not just "socket dropped."
- **get_it** - tiny manual DI, no codegen.
- **fl_chart** - the performance chart.
- **intl** - currency/date formatting.
- **shared_preferences** - remembers your theme.
- **bloc_test, mocktail** - for tests.

Didn't bother with freezed/build_runner - plain classes with copyWith are enough for this size of app and it's one less thing to regenerate every time I touch a model.

## Structure

Pretty standard clean architecture, split by feature:

```
lib/
  main_dev.dart / main_qa.dart / main_prod.dart   # entrypoints
  bootstrap.dart                                  # DI setup + runApp
  app/            # MaterialApp, DI wiring
  core/           # config, theme, websocket clients, small utils
  features/portfolio/
    domain/       # entities, repo interface, PortfolioCalculator
    data/         # models, mock data, repo impl
    presentation/
      cubit/      # PortfolioCubit, ConnectionCubit, HoldingsUiCubit, ChartRangeCubit
      pages/      # DashboardPage
      widgets/    # header, summary, chart, holdings
```

## Why P/L isn't stored anywhere

`PortfolioCubit` only holds raw holdings and the latest quotes. No `totalPL` field sitting in state. Every number on screen gets computed on the spot from those two things whenever the widget builds.

I could cache the computed numbers and update them on every tick, but then you've got two copies of the truth that can drift apart - update the holdings somewhere and forget to recompute the cached P/L, now you're showing a wrong number that looks correct. Computing it fresh every time just removes that bug from being possible.

## Reconnect logic

Exponential backoff with a bit of jitter - 1s, 2s, 4s, 8s, 16s, caps at 30s. Same policy for both the simulated and real client.

When it reconnects it just grabs a fresh price snapshot, doesn't try to replay whatever happened while it was down. A tick from 3 minutes ago is useless the second a newer price shows up, so why bother.

Live / Reconnecting / Offline are actually different states, not just three labels for "not working":
- Live - socket's up, getting ticks
- Reconnecting - socket dropped but you still have internet, retry is queued
- Offline - no internet at all, checked separately from the socket

Dev and QA have a bolt icon in the header to kill the connection on demand, so you can see the whole reconnect cycle without needing airplane mode. (Still need to screenshot this for the submission.)

## Rebuilds

Two things keep this from re-rendering everything on every tick:

A tick only ever updates `state.quotes`, never touches `state.holdings` - same list instance before and after. So anything watching just the holdings list (ticker strip, the table in its normal view) doesn't rebuild at all on a tick, because nothing actually changed by reference. The table does start re-filtering on every tick if you pick a price-based filter like "today's gainers" - that's expected since the list itself depends on price there.

On top of that, every row and every ticker chip grabs its own quote individually (`context.select` on `quotes[symbol]`), so only the row that actually moved gets marked dirty. Doesn't matter if the parent above it rebuilds or not.

End result: one tick, one row updates. Summary cards are the exception - they use the whole quotes map since total value changes every tick, so they just rebuild every time on purpose.

(Also still need a DevTools screenshot with "track widget rebuilds" on to actually show this.)

## Ticks don't interrupt you

Search/sort/filter live in a separate cubit that a price tick never touches, so typing in the search box or scrolling doesn't get reset when a price updates. Same for the inline "target price alert" editor - it grabs the original value when you open the row and only sends an update if what you typed is actually different. Since it never reads live prices, nothing can overwrite it mid-edit either.

## Flavors

| | feed | symbols | android id | ios id |
|---|---|---|---|---|
| dev | simulated | 8 | com.example.investment_dashboard.dev | com.example.investmentDashboard.dev |
| qa | simulated | 5 | com.example.investment_dashboard.qa | com.example.investmentDashboard.qa |
| prod | finnhub | 8 | com.example.investment_dashboard | com.example.investmentDashboard |

Small note on prod: finnhub gives raw trade prices, not a ready % change. There's no backend to pull a prior close from, so % change is just relative to the first price seen for that symbol this session. Not perfect but it's honest about what it is.

iOS flavors are the real thing, not just a Dart-level trick - actual Xcode schemes with their own build configs and bundle ids. Tested with `flutter build ios --flavor dev --simulator` and `--flavor prod --simulator`, both come out right.

## Still need to do (can't do these myself)

- [ ] DevTools screenshot showing only isolated cells rebuilding
- [ ] Screenshot/GIF of the disconnect → reconnect flow
- [ ] Screenshot of the chart tooltip

## Firebase App Distribution

Done - uploaded the dev build already. Didn't need google-services.json or the SDK for this, App Distribution just wants a binary and an app id.

```bash
flutter build apk --flavor dev -t lib/main_dev.dart --dart-define=FLAVOR=dev
firebase login
firebase appdistribution:distribute \
  build/app/outputs/flutter-apk/app-dev-release.apk \
  --app 1:238846682495:android:7979d063da9c1144c6264a \
  --groups "testers"
```

No testers group existed yet so it uploaded with nobody attached. Make a group in the Firebase console (App Distribution → Testers & Groups) and rerun that last command, or swap `--groups` for `--testers "someone@email.com"` for a one-off.

## Bonus stuff I added

- **Price flash animation** - the price and P/L cells flash green/red for a moment whenever they update, then fade back. `FlashOnChange` widget, wraps the ticker chips and the holdings row cells.
- **Optimistic UI on the target price alert edit** - the value applies to state right away on Save, doesn't wait for the network call. If the (simulated) call fails, it rolls back and tells you to retry. Simulated a ~15% random failure rate on that call just so the rollback path actually happens sometimes instead of only existing in a unit test.
- **Retry button on disconnect** - when the connection drops or you go offline, there's a toast with a Retry button that skips the rest of the backoff wait and reconnects immediately.
- **Live web build** - deployed to Firebase Hosting, link at the top of this file. To redeploy:
  ```bash
  flutter build web -t lib/main_dev.dart --dart-define=FLAVOR=dev
  firebase deploy --only hosting
  ```

## Tests

```bash
flutter test
```

- `portfolio_calculator_test.dart` - the math
- `reconnect_policy_test.dart` - backoff behaves
- `portfolio_cubit_test.dart` - holdings load, ticks fold in right, target price updates only touch one holding
- `widget_test.dart` / `responsive_test.dart` - app boots, no layout overflow at phone/tablet sizes
