import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:absensiwithselfie/face_detector_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<CameraDescription> _cameras;

  @override
  void initState() {
    super.initState();
    _initializeCameras();
  }

  Future<void> _initializeCameras() async {
    _cameras = await availableCameras();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Face Detector'),
      ),
      body: _body(),
    );
  }

  Widget _body() {
    return Center(
      child: SizedBox(
        width: 450,
        height: 80,
        child: OutlinedButton(
          style: ButtonStyle(
            side: MaterialStateProperty.all(
              const BorderSide(color: Colors.blue, width: 1.0, style: BorderStyle.solid),
            ),
          ),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const FaceDetectorPage(),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildIconWidget(Icons.arrow_forward_ios),
              const Text(
                'Go to Face Detector',
                style: TextStyle(fontSize: 14),
              ),
              _buildIconWidget(Icons.arrow_back_ios),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconWidget(final IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Icon(
        icon,
        size: 24,
      ),
    );
  }
}
