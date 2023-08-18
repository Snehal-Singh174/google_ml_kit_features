import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';

class TextRecognition extends StatefulWidget {
  const TextRecognition({super.key, required this.title});

  final String title;

  @override
  State<TextRecognition> createState() => _TextRecognitionState();
}

class _TextRecognitionState extends State<TextRecognition> {
  String? text;

  final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  final id = DateTime.now().microsecondsSinceEpoch.toString();

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
            text != null
                ? Container(
                    alignment: Alignment.center, child: _buildBody(text))
                : Container(
                    height: 300,
                    width: 300,
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.lightBlueAccent.withOpacity(0.6),
                        ),
                        borderRadius: BorderRadius.circular(15)),
                    child: const Center(child: Text("No Data Found"))),
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
                          final RecognizedText recognizedText =
                              await textRecognizer.processImage(inputImage);

                          setState(() {
                            text = recognizedText.text;
                          });
                        } catch (e) {
                          log(e.toString());
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
                          final RecognizedText recognizedText =
                              await textRecognizer.processImage(inputImage);

                          setState(() {
                            text = recognizedText.text;
                          });
                        } catch (e) {
                          log(e.toString());
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

  Widget _buildBody(String? file) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [Text(text ?? "Nothing Detected")],
    );
  }
}
