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
      body: Container(
        margin: const EdgeInsets.only(top: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            text!=null ?
            Container(alignment: Alignment.center,child: SelectableText(text ?? "No Url Found")) :
            Container(
                height: 300,
                width: 300,
                decoration: BoxDecoration(border: Border.all(color: Colors.lightBlueAccent.withOpacity(0.6),), borderRadius: BorderRadius.circular(15)),child: const Center(child: Text("No Data Found"))),
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(onPressed: () async {
                    try {
                      var file =
                      await ImagePicker.platform.pickImage(source: ImageSource.camera);
                      final options = ObjectDetectorOptions(mode: mode, classifyObjects: true, multipleObjects: false);
                      final InputImage inputImage = InputImage.fromFile(File(file!.path));
                      final objectDetector = ObjectDetector(options: options);
                      final List<DetectedObject> objects = await objectDetector.processImage(inputImage);
                      String? label1;
                      for(DetectedObject detectedObject in objects){
                       for(Label label in detectedObject.labels){
                          label1 = label.text;
                        }
                      }
                      setState(()  {
                       text = label1;
                      });
                    } catch (e) {
                      log(e.toString());
                    }
                  }, icon: const Icon(Icons.camera_alt, size: 50, color: Colors.blue,)),
                  IconButton(onPressed: () async{
                    try {
                      var file =
                      await ImagePicker.platform.pickImage(source: ImageSource.gallery);
                      final options = ObjectDetectorOptions(mode: mode, classifyObjects: true, multipleObjects: false);
                      final InputImage inputImage = InputImage.fromFile(File(file!.path));
                      final objectDetector = ObjectDetector(options: options);
                      final List<DetectedObject> objects = await objectDetector.processImage(inputImage);
                      String? label1;
                      for(DetectedObject detectedObject in objects){
                        for(Label label in detectedObject.labels){
                          label1 = label.text;
                        }
                      }
                      setState(()  {
                        text = label1;
                      });
                    } catch (e) {
                      log(e.toString());
                    }
                  }, icon: const Icon(Icons.add_photo_alternate, size: 50, color: Colors.blue,)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
