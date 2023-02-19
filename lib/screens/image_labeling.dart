import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';


class ImageLabeling extends StatefulWidget {
  const ImageLabeling({super.key, required this.title});

  final String title;

  @override
  State<ImageLabeling> createState() => _ImageLabelingState();
}

class _ImageLabelingState extends State<ImageLabeling> {
  File? _file;

  var imageLabels = <ImageLabel>[];

  /// The options for the image labeler.
  final ImageLabelerOptions options = ImageLabelerOptions(confidenceThreshold: 0.5);

  final id = DateTime.now().microsecondsSinceEpoch.toString();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title,),
      ),
      body: _buildBody(_file),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            var file =
            await ImagePicker.platform.pickImage(source: ImageSource.gallery);
            final imageLabeler = ImageLabeler(options: options);
            final InputImage inputImage = InputImage.fromFile(File(file!.path));
            final List<ImageLabel> labels = await imageLabeler.processImage(inputImage);

            setState(()  {
              _file = File(file.path);
              imageLabels = labels;

            });
          } catch (e) {
            log(e.toString());
          }
        },
        child: const Icon(Icons.select_all),
      ),
    );
  }

  Widget _buildBody(File? file) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[displaySelectedFile(file), _buildList(imageLabels)],
    );
  }

  Widget _buildList(List<ImageLabel> labels) {
    if (labels.isEmpty ) {
      return const SizedBox();
    }
    return Expanded(
      child:  ListView.builder(
          padding: const EdgeInsets.all(1.0),
          itemCount: labels.length,
          itemBuilder: (context, i) {
            return _buildRow(labels[i].label, labels[i].confidence.toString(), labels[i].index.toString());
          }),
    );
  }

  Widget displaySelectedFile(File? file) {
    return  SizedBox(
      child: file == null
          ?  const Center(child: Text('Sorry nothing selected!!', style: TextStyle(fontSize: 20),))
          :  Container(
        margin: const EdgeInsets.all(30),
        height: 200,
        width: 200,
        decoration: BoxDecoration(
          image: DecorationImage(image: FileImage(file, scale: 1), fit: BoxFit.cover),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(width: 2.5, color: Colors.blue)
        ),
      ),
    );
  }

  //Display labels
  Widget _buildRow(String label, String confidence, String entityID) {
    return ListTile(
      title: Text(
        "\nLabel: $label \nConfidence: $confidence \nEntityID: $entityID",
        style: const TextStyle(fontSize: 20),
      ),
      dense: true,
    );
  }

}
