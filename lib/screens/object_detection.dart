import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';


class ObjectDetection extends StatefulWidget {
  const ObjectDetection({super.key, required this.title});

  final String title;

  @override
  State<ObjectDetection> createState() => _ObjectDetectionState();
}

class _ObjectDetectionState extends State<ObjectDetection> {
  String? text;

  final mode = DetectionMode.single;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title,),
      ),
      body:  text!=null ?  Center(child: SelectableText(text ?? "No Url Found")): const Center(child: Text("No Data Found")),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            var file =
            await ImagePicker.platform.pickImage(source: ImageSource.camera);
            final options = ObjectDetectorOptions(mode: mode, classifyObjects: true, multipleObjects: false);
            final InputImage inputImage = InputImage.fromFile(File(file!.path));
            final objectDetector = ObjectDetector(options: options);
            final List<DetectedObject> objects = await objectDetector.processImage(inputImage);
            String? label1;
            for(DetectedObject detectedObject in objects){
              final rect = detectedObject.boundingBox;
              final trackingId = detectedObject.trackingId;

              for(Label label in detectedObject.labels){
                print('${label.text} ${label.confidence}');
                label1 = label.text;
              }
            }

            setState(()  {
              print("object detection");
              print(objects);
              print(objects.first.labels);
              text = label1;
            });
          } catch (e) {
            log(e.toString());
          }
        },
        child: const Icon(Icons.select_all),
      ),
    );
  }
}
