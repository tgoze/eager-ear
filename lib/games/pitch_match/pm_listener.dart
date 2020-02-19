import 'dart:async';

import 'package:flutter/services.dart';

import 'package:eager_ear/shared/pitch.dart';

import 'package:permission_handler/permission_handler.dart';

class PitchMatchListener {
  static const _pitchStream = EventChannel('com.tgconsulting.eager_ear/stream');
  StreamSubscription _pitchSubscription;

  Future<bool> listenForPitch(Pitch referencePitch) async {
    bool isCorrect = false;
    var audioAccessGranted = await requestAudioPermission();
    if (audioAccessGranted) {
      _pitchSubscription = _pitchStream.receiveBroadcastStream().listen(
        (hertz) => isCorrect = _comparePitch(referencePitch, hertz)
      );
    }
    if (isCorrect)
      stopListening();
    return isCorrect;
  }

  void stopListening() {
    if (_pitchSubscription != null)
      _pitchSubscription.cancel();
  }

  Future<bool> requestAudioPermission() async {
    PermissionStatus permissionStatus = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.speech);

    if (permissionStatus != PermissionStatus.granted) {
      Map<PermissionGroup, PermissionStatus> permission =
      await PermissionHandler().requestPermissions([PermissionGroup.speech]);
      permissionStatus = permission[PermissionGroup.speech];
    }

    return permissionStatus == PermissionStatus.granted;
  }

  bool _comparePitch(Pitch reference, double inputHertz) {
    return reference == Pitch.fromHertz(inputHertz);
  }
}