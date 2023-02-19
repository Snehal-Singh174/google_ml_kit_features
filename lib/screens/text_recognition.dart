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
        title: Text(widget.title,),
      ),
      body: _buildBody(text),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            var file =
            await ImagePicker.platform.pickImage(source: ImageSource.camera);
            final InputImage inputImage = InputImage.fromFile(File(file!.path));
            final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

            setState(()  {
               text = recognizedText.text;
            });
          } catch (e) {
            log(e.toString());
          }
        },
        child: const Icon(Icons.select_all),
      ),
    );
  }

  Widget _buildBody(String? file) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [Text(text??"Nothing Detected")],
    );
  }

}
