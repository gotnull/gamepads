import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:gamepads_platform_interface/api/gamepad_controller.dart';
import 'package:gamepads_platform_interface/api/gamepad_event.dart';
import 'package:gamepads_platform_interface/gamepads_platform_interface.dart';
import 'package:gamepads_platform_interface/method_channel_interface.dart';

class MethodChannelGamepadsPlatformInterface extends GamepadsPlatformInterface {
  final MethodChannel _channel = const MethodChannel('xyz.luan/gamepads');

  MethodChannelGamepadsPlatformInterface() {
    _channel.setMethodCallHandler(platformCallHandler);
  }

  @override
  Future<List<GamepadController>> listGamepads() async {
    final result = await _channel.compute<List<Object?>>(
      'listGamepads',
      <String, dynamic>{},
    );
    return result!.map((Object? e) {
      return GamepadController.parse(e! as Map<dynamic, dynamic>);
    }).toList();
  }

  Future<void> platformCallHandler(MethodCall call) async {
    switch (call.method) {
      case 'onGamepadEvent':
        emitGamepadEvent(GamepadEvent.parse(call.args));
        break;
      case 'onGamepadConnectedEvent':
        emitGamepadConnectedEvent(GamepadConnectedEvent.parse(call.args));
        break;
    }
  }

  void emitGamepadEvent(GamepadEvent event) {
    _gamepadEventsStreamController.add(event);
  }

  void emitGamepadConnectedEvent(GamepadConnectedEvent event) {
    _gamepadConnectedStreamController.add(event);
  }

  final StreamController<GamepadEvent> _gamepadEventsStreamController =
      StreamController<GamepadEvent>.broadcast();

  final StreamController<GamepadConnectedEvent>
      _gamepadConnectedStreamController =
      StreamController<GamepadConnectedEvent>.broadcast();

  @override
  Stream<GamepadEvent> get gamepadEventsStream =>
      _gamepadEventsStreamController.stream;

  @override
  Stream<GamepadConnectedEvent> get gamepadConnectedStream =>
      _gamepadConnectedStreamController.stream;

  @mustCallSuper
  Future<void> dispose() async {
    _gamepadEventsStreamController.close();
    _gamepadConnectedStreamController.close();
  }
}
