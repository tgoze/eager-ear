import 'dart:async';

import 'package:flutter/services.dart';

import 'package:eager_ear/shared/pitch.dart';

import 'package:permission_handler/permission_handler.dart';

class PitchMatchListener {
  static const _hertzStream = EventChannel('com.tgconsulting.eager_ear/stream');

  bool isCorrect = false;

  Future<Stream<Pitch>> startPitchStream() async {
    var audioAccessGranted = await requestAudioPermission();
    Stream<Pitch> pitchStream;
    if (audioAccessGranted) {
      pitchStream = _hertzStream.receiveBroadcastStream()
        .map((hertz) => Pitch.fromHertz(hertz));
    }
    return pitchStream;
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

  bool comparePitch(Pitch reference, double inputHertz) {
    return reference == Pitch.fromHertz(inputHertz);
  }
}