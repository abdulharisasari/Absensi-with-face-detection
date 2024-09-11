import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceDetectorPainter extends CustomPainter {
  final List<Face> faces;
  final Size absoluteImageSize;
  final InputImageRotation rotation;
  final Rect guideBox;
  final ValueChanged<bool> onFaceInsideGuide; // Callback untuk memberitahu jika wajah sepenuhnya dalam kotak panduan

  FaceDetectorPainter(this.faces, this.absoluteImageSize, this.rotation, this.guideBox, this.onFaceInsideGuide);

  @override
  void paint(final Canvas canvas, final Size size) {
    bool faceInsideGuide = false; // Flag untuk memeriksa jika ada wajah di dalam guide box

    final Paint facePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..color = Colors.blue; // Warna kotak wajah ketika sepenuhnya berada dalam kotak panduan

    final Paint guideBoxPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..color = Colors.green; // Warna kotak panduan default

    // Periksa semua wajah yang terdeteksi
    for (final Face face in faces) {
      final rect = Rect.fromLTRB(
        translateX(face.boundingBox.left, rotation, size, absoluteImageSize),
        translateY(face.boundingBox.top, rotation, size, absoluteImageSize),
        translateX(face.boundingBox.right, rotation, size, absoluteImageSize),
        translateY(face.boundingBox.bottom, rotation, size, absoluteImageSize),
      );

      // Cek apakah wajah sepenuhnya berada di dalam kotak panduan
      if (guideBox.contains(rect.topLeft) && guideBox.contains(rect.bottomRight)) {
        faceInsideGuide = true;
        // canvas.drawRect(rect, facePaint); // Gambar kotak wajah dengan warna biru
      } else {
        // Jika wajah di luar kotak panduan, beri peringatan (warna merah)
        final Paint warningPaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5.0
          ..color = Colors.red; // Warna kotak wajah di luar kotak panduan

        canvas.drawRect(rect, warningPaint);
      }
    }

    // Hanya gambar kotak panduan jika wajah tidak berada di dalam guide box
    if (!faceInsideGuide) {
      canvas.drawRect(guideBox, guideBoxPaint); // Gambar kotak panduan jika wajah tidak di dalamnya
    }

    // Callback untuk memberi tahu jika wajah sepenuhnya berada dalam kotak panduan
    onFaceInsideGuide(faceInsideGuide);
  }

  @override
  bool shouldRepaint(final FaceDetectorPainter oldDelegate) {
    return oldDelegate.absoluteImageSize != absoluteImageSize || oldDelegate.faces != faces;
  }

  double translateX(double x, InputImageRotation rotation, Size size, Size absoluteImageSize) {
    switch (rotation) {
      case InputImageRotation.rotation90deg:
        return x * size.width / absoluteImageSize.height;
      case InputImageRotation.rotation270deg:
        return size.width - x * size.width / absoluteImageSize.height;
      default:
        return x * size.width / absoluteImageSize.width;
    }
  }

  double translateY(double y, InputImageRotation rotation, Size size, Size absoluteImageSize) {
    switch (rotation) {
      case InputImageRotation.rotation90deg:
      case InputImageRotation.rotation270deg:
        return y * size.height / absoluteImageSize.width;
      default:
        return y * size.height / absoluteImageSize.height;
    }
  }
}

// import 'dart:ui' as ui; // Untuk menggunakan ui.Image
// import 'package:flutter/services.dart'; // Untuk memuat gambar dari assets
// import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
// import 'package:flutter/material.dart';

// class FaceDetectorPainter extends CustomPainter {
//   final List<Face> faces;
//   final Size absoluteImageSize;
//   final InputImageRotation rotation;
//   final Rect guideBox;
//   final ValueChanged<bool> onFaceInsideGuide;
//   ui.Image? _scanIcon; // Variable to store the loaded image

//   FaceDetectorPainter(this.faces, this.absoluteImageSize, this.rotation, this.guideBox, this.onFaceInsideGuide) {
//     _loadScanIcon(); // Load the icon when the painter is created
//   }

//   void _loadScanIcon() async {
//     final ByteData data = await rootBundle.load('assets/scan_icon.png');
//     final Uint8List bytes = data.buffer.asUint8List(); // Perubahan dilakukan di sini
//     ui.decodeImageFromList(bytes, (result) {
//       _scanIcon = result;
//       // Trigger repaint when the image is loaded
//       if (_scanIcon != null) {
//         scheduleRepaint();
//       }
//     });
//   }

//   void scheduleRepaint() {
//     // Call this to trigger repaint when the image is loaded
//     onFaceInsideGuide(faces.isNotEmpty); // We can still check if faces are inside guide
//   }

//   @override
//   void paint(final Canvas canvas, final Size size) {
//     bool faceInsideGuide = false;

//     final Paint facePaint = Paint()
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 5.0
//       ..color = Colors.blue;

//     // Periksa semua wajah yang terdeteksi
//     for (final Face face in faces) {
//       final rect = Rect.fromLTRB(
//         translateX(face.boundingBox.left, rotation, size, absoluteImageSize),
//         translateY(face.boundingBox.top, rotation, size, absoluteImageSize),
//         translateX(face.boundingBox.right, rotation, size, absoluteImageSize),
//         translateY(face.boundingBox.bottom, rotation, size, absoluteImageSize),
//       );

//       // Cek apakah wajah sepenuhnya berada di dalam kotak panduan
//       if (guideBox.contains(rect.topLeft) && guideBox.contains(rect.bottomRight)) {
//         faceInsideGuide = true;
//       } else {
//         final Paint warningPaint = Paint()
//           ..style = PaintingStyle.stroke
//           ..strokeWidth = 5.0
//           ..color = Colors.red;

//         canvas.drawRect(rect, warningPaint);
//       }
//     }

//     // Gambar ikon scan alih-alih kotak panduan
//     if (_scanIcon != null && !faceInsideGuide) {
//       final double iconWidth = guideBox.width;
//       final double iconHeight = guideBox.height;
//       final Offset iconPosition = Offset(guideBox.left, guideBox.top);

//       canvas.drawImageRect(
//         _scanIcon!,
//         Rect.fromLTWH(0, 0, _scanIcon!.width.toDouble(), _scanIcon!.height.toDouble()), // Source rect (ikon)
//         Rect.fromLTWH(iconPosition.dx, iconPosition.dy, iconWidth, iconHeight), // Destination rect (di mana ikon muncul)
//         Paint(),
//       );
//     }

//     // Callback untuk memberi tahu jika wajah sepenuhnya berada dalam kotak panduan
//     onFaceInsideGuide(faceInsideGuide);
//   }

//   @override
//   bool shouldRepaint(final FaceDetectorPainter oldDelegate) {
//     return oldDelegate.absoluteImageSize != absoluteImageSize || oldDelegate.faces != faces || _scanIcon != oldDelegate._scanIcon;
//   }

//   double translateX(double x, InputImageRotation rotation, Size size, Size absoluteImageSize) {
//     switch (rotation) {
//       case InputImageRotation.rotation90deg:
//         return x * size.width / absoluteImageSize.height;
//       case InputImageRotation.rotation270deg:
//         return size.width - x * size.width / absoluteImageSize.height;
//       default:
//         return x * size.width / absoluteImageSize.width;
//     }
//   }

//   double translateY(double y, InputImageRotation rotation, Size size, Size absoluteImageSize) {
//     switch (rotation) {
//       case InputImageRotation.rotation90deg:
//       case InputImageRotation.rotation270deg:
//         return y * size.height / absoluteImageSize.width;
//       default:
//         return y * size.height / absoluteImageSize.height;
//     }
//   }
// }
