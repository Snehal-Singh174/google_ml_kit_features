import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mlkit_selfie_segmentation/google_mlkit_selfie_segmentation.dart';
import 'package:image_picker/image_picker.dart';

import 'painter/segmentation_painter.dart';

class SelfieSegmentation extends StatefulWidget {
  const SelfieSegmentation({super.key, required this.title});

  final String title;

  @override
  State<SelfieSegmentation> createState() => _SelfieSegmentationState();
}

class _SelfieSegmentationState extends State<SelfieSegmentation> {
  final SelfieSegmenter _segmenter = SelfieSegmenter(
    mode: SegmenterMode.stream,
    enableRawSizeMask: true,
  );
  CustomPaint? _customPaint;
  File? _image;

  @override
  void dispose() async {
    _segmenter.close();
    super.dispose();
  }

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
          child: Column(children: [
            _image != null
                ? SizedBox(
                    height: 400,
                    width: 400,
                    child: Stack(
                      fit: StackFit.expand,
                      children: <Widget>[
                        Image.file(_image!),
                        if (_customPaint != null)
                          Container(
                              margin: const EdgeInsets.only(top: 70),
                              child: _customPaint!),
                      ],
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
                    child: const Center(child: Text("No Image Found"))),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const IconButton(
                    onPressed: null,
                    icon: Icon(
                      Icons.camera_alt,
                      size: 50,
                    )),
                IconButton(
                    onPressed: () => processImage(ImageSource.gallery),
                    icon: const Icon(
                      Icons.add_photo_alternate,
                      size: 50,
                      color: Colors.blue,
                    )),
              ],
            )
          ]),
        ));
  }

  Future<void> processImage(ImageSource source) async {
    ImagePicker _imagePicker = ImagePicker();
    setState(() {
      _image = null;
    });
    final pickedFile = await _imagePicker.pickImage(source: source);

    setState(() {
      _image = File(pickedFile!.path);
    });
    final inputImage = InputImage.fromFilePath(pickedFile!.path);
    setState(() {});
    File image =
        File(pickedFile.path); // Or any other way to get a File instance.
    var decodedImage = await decodeImageFromList(image.readAsBytesSync());

    ///need to do calculation for finding image exact height and width
    final Size imageSize = Size(decodedImage.width.toDouble()/7 ,
        decodedImage.height.toDouble()/7);

    print("imageSize=> $imageSize");
    ///As our source is gallery then the image
    ///will always be at 90 degree orientation
    var sensorOrientation = 90;
    final imageRotation =
        InputImageRotationValue.fromRawValue(sensorOrientation);
    final mask = await _segmenter.processImage(inputImage);
    if (mask != null && imageRotation != null) {
      final painter = SegmentationPainter(
        mask,
        imageSize,
        imageRotation,
      );
      _customPaint = CustomPaint(painter: painter);
    } else {
      _customPaint = null;
    }
    if (mounted) {
      setState(() {});
    }
  }
}
