import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image/image.dart';
import 'package:poke_scouter/providers/camera_provider.dart';

class ScouterState {
  final CameraController controller;
  final Image? originalImage;
  final Image? croppedImage;

  ScouterState({
    required this.controller,
    this.originalImage,
    this.croppedImage,
  });

  Uint8List? get originalImageBytes {
    final image = originalImage;
    if (image == null) {
      return null;
    }
    return Uint8List.fromList(encodePng(image));
  }
}

final scouterControllerProvider =
    AutoDisposeAsyncNotifierProvider<ScouterController, ScouterState>(() {
  return ScouterController();
});

class ScouterController extends AutoDisposeAsyncNotifier<ScouterState> {
  @override
  FutureOr<ScouterState> build() async {
    final camera = ref.read(camerasProvider).first;
    final controller =
        CameraController(camera, ResolutionPreset.high, enableAudio: false);
    await controller.initialize();
    ref.onDispose(() {
      controller.dispose();
    });
    return ScouterState(
      controller: controller,
    );
  }

  void takePicture() async {
    state = await AsyncValue.guard(() async {
      final currentState = state.asData?.value;
      if (currentState == null) {
        throw StateError('CameraController is not initialized');
      }
      final xfile = await currentState.controller.takePicture();
      final bytes = await xfile.readAsBytes();
      final originalImage = decodeImage(bytes);

      return ScouterState(
        controller: currentState.controller,
        originalImage: originalImage,
      );
    });
  }
}
