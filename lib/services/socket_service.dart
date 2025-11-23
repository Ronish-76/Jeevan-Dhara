import 'dart:async';

import '../core/constants.dart';
import '../models/blood_request_model.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  SocketService._();

  static final SocketService instance = SocketService._();

  IO.Socket? _socket;
  StreamController<BloodRequestModel>? _requestCreatedController;
  StreamController<BloodRequestModel>? _requestRespondedController;

  void connect({
    required void Function(BloodRequestModel) onRequestCreated,
    required void Function(BloodRequestModel) onRequestResponded,
  }) {
    if (_socket != null && _socket!.connected) {
      return;
    }

    _requestCreatedController = StreamController<BloodRequestModel>.broadcast();
    _requestRespondedController = StreamController<BloodRequestModel>.broadcast();

    _socket = IO.io(
      AppConfig.socketUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .build(),
    );

    _socket!.onConnect((_) {
      print('Socket connected');
    });

    _socket!.onDisconnect((_) {
      print('Socket disconnected');
    });

    _socket!.on('bloodRequest:created', (data) {
      try {
        final request = BloodRequestModel.fromJson(data as Map<String, dynamic>);
        onRequestCreated(request);
        _requestCreatedController?.add(request);
      } catch (e) {
        print('Error parsing request created: $e');
      }
    });

    _socket!.on('bloodRequest:responded', (data) {
      try {
        final request = BloodRequestModel.fromJson(data as Map<String, dynamic>);
        onRequestResponded(request);
        _requestRespondedController?.add(request);
      } catch (e) {
        print('Error parsing request responded: $e');
      }
    });

    _socket!.connect();
  }

  void dispose() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _requestCreatedController?.close();
    _requestRespondedController?.close();
    _requestCreatedController = null;
    _requestRespondedController = null;
  }
}

