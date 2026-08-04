import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum NetworkStatus { connected, disconnected }

class NetworkCubit extends Cubit<NetworkStatus> {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription? _subscription;

  NetworkCubit() : super(NetworkStatus.connected) {
    _checkInitialConnection();
    _subscription = _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      if (results.contains(ConnectivityResult.none)) {
        emit(NetworkStatus.disconnected);
      } else {
        emit(NetworkStatus.connected);
      }
    });
  }

  void _checkInitialConnection() async {
    final List<ConnectivityResult> results = await _connectivity.checkConnectivity();
    if (results.contains(ConnectivityResult.none)) {
      emit(NetworkStatus.disconnected);
    } else {
      emit(NetworkStatus.connected);
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
