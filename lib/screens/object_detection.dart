import 'dart:developer';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_labeling/screens/painter/object_painter.dart';
import 'package:image_picker/image_picker.dart';

class ObjectDetection extends StatefulWidget {
  const ObjectDetection({super.key, required this.title});

  final String title;

  @override
  State<ObjectDetection> createState() => _ObjectDetectionState();
}

class _ObjectDetectionState extends State<ObjectDetection> {
  String? text;
  File? _imageFile;
  List<DetectedObject>? _objects;
  ui.Image? _image;

  final objectDetector = ObjectDetector(
      options: ObjectDetectorOptions(
          mode: DetectionMode.single,
          classifyObjects: true,
          multipleObjects: false));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
        ),
      ),
      body: Container(
        margin: const EdgeInsets.only(top: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            (_imageFile != null && _image != null && _objects != null)
                ? FittedBox(
                    child: SizedBox(
                      width: _image?.width.toDouble() ?? 300,
                      height: _image?.height.toDouble() ?? 300,
                      child: CustomPaint(
                        painter: ObjectPainter(_image!, _objects!),
                      ),
                    ),
                  )
                : Container(
                    height: 300,
                    width: 300,
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.lightBlueAccent.withOpacity(0.6),
                        ),
                        borderRadius: BorderRadius.circular(15)),
                    child: const Center(child: Text("No Object Found"))),
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                      onPressed: () async {
                        try {
                          var file = await ImagePicker.platform
                              .pickImage(source: ImageSource.camera);
                          final InputImage inputImage =
                              InputImage.fromFile(File(file!.path));
                          setState(() {
                            text = 'processing...';
                          });
                          final List<DetectedObject> objects =
                              await objectDetector.processImage(inputImage);
                          setState(() {
                            _imageFile = File(file.path);
                            _objects = objects;
                            _loadImage(File(file.path));
                          });
                        } catch (e) {
                          log(e.toString());
                          setState(() {
                            text = e.toString();
                          });
                        }
                      },
                      icon: const Icon(
                        Icons.camera_alt,
                        size: 50,
                        color: Colors.blue,
                      )),
                  IconButton(
                      onPressed: () async {
                        try {
                          var file = await ImagePicker.platform
                              .pickImage(source: ImageSource.gallery);
                          final InputImage inputImage =
                              InputImage.fromFile(File(file!.path));
                          setState(() {
                            text = 'processing...';
                          });

                          final List<DetectedObject> objects =
                              await objectDetector.processImage(inputImage);
                          setState(() {
                            _imageFile = File(file.path);
                            _objects = objects;
                            _loadImage(File(file.path));
                          });
                        } catch (e) {
                          log(e.toString());
                          setState(() {
                            text = e.toString();
                          });
                        }
                      },
                      icon: const Icon(
                        Icons.add_photo_alternate,
                        size: 50,
                        color: Colors.blue,
                      )),
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
        }));
  }
}
