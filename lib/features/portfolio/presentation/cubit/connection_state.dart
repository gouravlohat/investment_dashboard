import 'package:equatable/equatable.dart';

import '../../../../core/network/websocket/connection_status.dart';

class ConnectionUiState extends Equatable {
  final ConnectionStatus status;

  const ConnectionUiState(this.status);

  @override
  List<Object?> get props => [status];
}
