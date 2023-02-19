import 'dart:developer';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';


class FaceDetection extends StatefulWidget {
  const FaceDetection({super.key, required this.title});

  final String title;

  @override
  State<FaceDetection> createState() => _FaceDetectionState();
}

class _FaceDetectionState extends State<FaceDetection> {
  File? _imageFile;
  List<Face>? _faces;
  bool isLoading = false;
  ui.Image? _image;
  final picker = ImagePicker();
  var imageFile;
  /// The options for the image labeler.
  final options = FaceDetectorOptions();

  final id = DateTime.now().microsecondsSinceEpoch.toString();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title,),
      ),
      body:  Container(
        margin: const EdgeInsets.only(top: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            (_imageFile!=null&& _image!=null && _faces!=null)?FittedBox(
              child: SizedBox(
                width: _image?.width.toDouble() ?? 300,
                height: _image?.height.toDouble() ?? 300,
                child: CustomPaint(
                  painter: FacePainter(_image!, _faces!),
                ),
              ),
            ) :
            Container(
                height: 300,
                width: 300,
                decoration: BoxDecoration(border: Border.all(color: Colors.lightBlueAccent.withOpacity(0.6),), borderRadius: BorderRadius.circular(15)),child: const Center(child: Text("No Face Found"))),
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(onPressed: () async {
                    try {
                      var file =
                      await ImagePicker.platform.pickImage(source: ImageSource.camera);
                      final faceDetector = FaceDetector(options: options);
                      final InputImage inputImage = InputImage.fromFile(File(file!.path));
                      final List<Face> faces = await faceDetector.processImage(inputImage);
                      setState(()  {
                        _imageFile = File(file.path);
                        _faces = faces;
                        _loadImage(File(file.path));
                      });
                    } catch (e) {
                      log(e.toString());
                    }
                  }, icon: const Icon(Icons.camera_alt, size: 50, color: Colors.blue,)),
                  IconButton(onPressed: () async{
                    try {
                      var file =
                      await ImagePicker.platform.pickImage(source: ImageSource.gallery);
                      final faceDetector = FaceDetector(options: options);
                      final InputImage inputImage = InputImage.fromFile(File(file!.path));
                      final List<Face> faces = await faceDetector.processImage(inputImage);
                      setState(()  {
                        _imageFile = File(file.path);
                        _faces = faces;
                        _loadImage(File(file.path));
                      });
                    } catch (e) {
                      log(e.toString());
                    }
                  }, icon: const Icon(Icons.add_photo_alternate, size: 50, color: Colors.blue),),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

_loadImage(File file) async {
  final data = await file.readAsBytes();
  await decodeImageFromList(data).then((value) => setState(() {
    _image = value;
    isLoading = false;
  }));
}
}

// paint the face
class FacePainter extends CustomPainter {
  final ui.Image image;
  final List<Face> faces;
  final List<Rect> rects = [];

  FacePainter(this.image, this.faces) {
    for (var i = 0; i < faces.length; i++) {
      rects.add(faces[i].boundingBox);
    }
  }

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.red;

    canvas.drawImage(image, Offset.zero, Paint());
    for (var i = 0; i < faces.length; i++) {
      canvas.drawRect(rects[i], paint);
    }
  }

  @override
  bool shouldRepaint(FacePainter old) {
    return image != old.image  || faces != old.faces;
  }
}