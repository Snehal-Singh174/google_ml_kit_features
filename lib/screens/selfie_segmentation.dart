import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_selfie_segmentation/google_mlkit_selfie_segmentation.dart';
import 'package:image_picker/image_picker.dart';

import '../main.dart';
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
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  File? _image;

  @override
  void dispose() async {
    _canProcess = false;
    _segmenter.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title,),
      ),
      body: ListView(shrinkWrap: true, children: [
        _image != null
            ? SizedBox(
          height: 400,
          width: 400,
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Image.file(_image!),
              if (_customPaint != null) Container(margin: EdgeInsets.only(top: 70), child: _customPaint!),
            ],
          ),
        )
            : Icon(
          Icons.image,
          size: 200,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: ElevatedButton(
            child: Text('From Gallery'),
            onPressed: () => _getImage(ImageSource.gallery),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: ElevatedButton(
            child: Text('Take a picture'),
            onPressed: () => _getImage(ImageSource.camera),
          ),
        ),
      ])
      // Container(
      //   margin: const EdgeInsets.only(top: 40),
      //   child: Column(
      //     crossAxisAlignment: CrossAxisAlignment.center,
      //     children: [
      //       _customPaint!=null?
      //       _customPaint!
      //           :  Container(
      //       height: 300,
      //       width: 300,
      //       decoration: BoxDecoration(border: Border.all(color: Colors.lightBlueAccent.withOpacity(0.6),), borderRadius: BorderRadius.circular(15)),child: const Center(child: Text("No Data Found"))),
      //       SelectableText(_text ?? ''),
      //       Padding(
      //         padding: const EdgeInsets.all(18.0),
      //         child: Row(
      //           mainAxisAlignment: MainAxisAlignment.spaceAround,
      //           children: [
      //             IconButton(onPressed: () async {
      //               var file =
      //               await ImagePicker.platform.pickImage(source: ImageSource.camera);
      //               final InputImage inputImage = InputImage.fromFile(File(file!.path));
      //               processImage(inputImage);
      //             }, icon: const Icon(Icons.camera_alt, size: 50, color: Colors.blue,)),
      //             IconButton(onPressed: () async{
      //               ImagePicker _imagePicker = ImagePicker();
      //               XFile? pickedFile =
      //               await _imagePicker.pickImage(source: ImageSource.gallery);
      //               final inputImage = InputImage.fromFilePath(pickedFile!.path);
      //               processImage(inputImage);
      //             }, icon: const Icon(Icons.add_photo_alternate, size: 50, color: Colors.blue,)),
      //           ],
      //         ),
      //       )
      //     ],
      //   ),
      // ),
    );
  }

  Future _getImage(ImageSource source) async {
    ImagePicker _imagePicker = ImagePicker();
    setState(() {
      _image = null;
    });
    final pickedFile = await _imagePicker.pickImage(source: source);
    if (pickedFile != null) {
      processImage(pickedFile);
    }
    setState(() {
      _image = File(pickedFile!.path);
      // print(_image!.length());
    });
  }


  Future<void> processImage(XFile pickedFile) async {
    final inputImage = InputImage.fromFilePath(pickedFile.path);
    print(inputImage);
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    setState(() {
    });
    File image =  File(pickedFile.path); // Or any other way to get a File instance.
    var decodedImage = await decodeImageFromList(image.readAsBytesSync());
    final Size imageSize = Size(decodedImage.width.toDouble()/1.9, decodedImage.height.toDouble()/1.6);
    print(cameras);
    final camera = cameras[0];
    final imageRotation =
    InputImageRotationValue.fromRawValue(camera.sensorOrientation);
    final mask = await _segmenter.processImage(inputImage);
    print("mask ==> $mask");
    if (mask != null) {
      // TODO: Fix SegmentationPainter to rescale on top of camera feed.
      final painter = SegmentationPainter(
        mask,
        imageSize,
        imageRotation!,
      );
      _customPaint = CustomPaint(painter: painter);
    } else {
      // TODO: set _customPaint to draw on top of image
      _customPaint = null;
    }
    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}