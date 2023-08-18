import 'package:flutter/material.dart';

import '../barcode_scanning.dart';
import '../face_detection.dart';
import '../image_labeling.dart';
import '../object_detection.dart';
import '../selfie_segmentation.dart';
import '../text_recognition.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List mlKits = [
      {
        'img': 'assets/barcode_scanning@2x.png',
        'name': 'Barcode Scanning',
        'route': const BarcodeScanning(title: 'BarcodeScanning'),
      },
      {
        'img': 'assets/face_detection@2x.png',
        'name': 'Face Detection',
        'route': const FaceDetection(title: 'FaceDetection'),
      },
      {
        'img': 'assets/image_labeling@2x.png',
        'name': 'Image Labeling',
        'route': const ImageLabeling(title: 'ImageLabeling'),
      },
      {
        'img': 'assets/object_detection@2x.png',
        'name': 'Object Detection',
        'route': const ObjectDetection(title: 'ObjectDetection'),
      },
      {
        'img': 'assets/text_recognition@2x.png',
        'name': 'Text Recognition',
        'route': const TextRecognition(title: 'TextRecognition'),
      },
      {
        'img': 'assets/selfie_segmentation.png',
        'name': 'Selfie Segmentation',
        'route': const SelfieSegmentation(title: 'SelfieSegmentation'),
      },
    ];

    return Scaffold(
      body: ListView.builder(
          itemCount: mlKits.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => mlKits[index]['route']));
              },
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                        color: Colors.lightBlueAccent.withOpacity(0.6))),
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        mlKits[index]['name'],
                        style: const TextStyle(fontSize: 26),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(left: 10),
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            image: DecorationImage(
                                image: AssetImage(mlKits[index]['img']),
                                fit: BoxFit.cover)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
    );
  }
}
