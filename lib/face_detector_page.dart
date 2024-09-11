import 'dart:io';
import 'package:absensiwithselfie/camera_view.dart';
import 'package:absensiwithselfie/display.dart';
import 'package:absensiwithselfie/util/face_detector_painter.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceDetectorPage extends StatefulWidget {
  const FaceDetectorPage({Key? key}) : super(key: key);

  @override
  State<FaceDetectorPage> createState() => _FaceDetectorPageState();
}

class _FaceDetectorPageState extends State<FaceDetectorPage> {
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      enableClassification: true,
    ),
  );

  bool _canProcess = true;
  bool _isBusy = false;
  bool _pictureTaken = false;
  bool _showGuideBox = true;
  CustomPaint? _customPaint;
  String? _text;
  CameraController? _cameraController;

  @override
  void dispose() {
    _canProcess = false;
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CameraView(
      title: 'Face Detector',
      customPaint: _customPaint,
      text: _text,
      onImage: (inputImage) {
        processImage(inputImage);
      },
      initialDirection: CameraLensDirection.front,
      onCameraControllerReady: (CameraController controller) {
        _cameraController = controller;
      },
    );
  }

  Future<void> processImage(final InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;

    setState(() {
      _text = "";
    });

    final faces = await _faceDetector.processImage(inputImage);

    if (inputImage.inputImageData?.size != null && inputImage.inputImageData?.imageRotation != null) {
      final guideBox = Rect.fromCenter(
        center: Offset(inputImage.inputImageData!.size.width / 8, inputImage.inputImageData!.size.height / 2.5),
        width: 200,
        height: 250,
      );

      final painter = FaceDetectorPainter(
        faces,
        inputImage.inputImageData!.size,
        inputImage.inputImageData!.imageRotation,
        guideBox,
        (faceInsideGuide) async {
          if (faceInsideGuide && _cameraController != null && !_pictureTaken) {
            _pictureTaken = true;

            try {
              final image = await _cameraController!.takePicture();

              if (!mounted) return;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DisplayPictureScreen(imagePath: image.path),
                ),
              );
            } catch (e) {
              print('Error taking picture: $e');
              _pictureTaken = false;
            }
          }
        },
      );
      _customPaint = CustomPaint(painter: painter);
    } else {
      String text = 'face found ${faces.length}\n\n';
      for (final face in faces) {
        text += 'face ${face.boundingBox}\n\n';
      }
      _text = text;
      _customPaint = null;
    }

    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}
