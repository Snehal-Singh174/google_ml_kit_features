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
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  String? _text;

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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _customPaint!=null?
                _customPaint!
                : const Text('No data Found'),
            Text(_text ?? ''),
            IconButton(onPressed: () async {
              var file =
                  await ImagePicker.platform.pickImage(source: ImageSource.camera);
              final InputImage inputImage = InputImage.fromFile(File(file!.path));
              processImage(inputImage);
            }, icon: const Icon(Icons.camera))
          ],
        ),
      ),
    );
  }

  Future<void> processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    setState(() {
      _text = '';
    });
    final mask = await _segmenter.processImage(inputImage);
    if (inputImage.inputImageData?.size != null &&
        inputImage.inputImageData?.imageRotation != null &&
        mask != null) {
      // TODO: Fix SegmentationPainter to rescale on top of camera feed.
      final painter = SegmentationPainter(
        mask,
        inputImage.inputImageData!.size,
        inputImage.inputImageData!.imageRotation,
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