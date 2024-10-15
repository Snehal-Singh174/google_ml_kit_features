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

  final imageLabeler =
      ImageLabeler(options: ImageLabelerOptions(confidenceThreshold: 0.5));

  final ImagePicker picker = ImagePicker();

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
              _file != null
                  ? SingleChildScrollView(
                      child: SizedBox(
                      height: (MediaQuery.of(context).size.height - 222),
                      child: _buildBody(_file),
                    ))
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
                            var file = await picker.pickImage(
                                source: ImageSource.camera);
                            final InputImage inputImage =
                                InputImage.fromFile(File(file!.path));
                            final List<ImageLabel> labels =
                                await imageLabeler.processImage(inputImage);

                            setState(() {
                              _file = File(file.path);
                              imageLabels = labels;
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
                            var file = await picker.pickImage(
                                source: ImageSource.gallery);
                            final InputImage inputImage =
                                InputImage.fromFile(File(file!.path));
                            final List<ImageLabel> labels =
                                await imageLabeler.processImage(inputImage);

                            setState(() {
                              _file = File(file.path);
                              imageLabels = labels;
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
        ));
  }

  Widget _buildBody(File? file) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[displaySelectedFile(file), _buildList(imageLabels)],
      ),
    );
  }

  Widget _buildList(List<ImageLabel> labels) {
    if (labels.isEmpty) {
      return const SizedBox();
    }
    return Expanded(
      child: ListView.builder(
          scrollDirection: Axis.vertical,
          padding: const EdgeInsets.all(1.0),
          itemCount: labels.length,
          itemBuilder: (context, i) {
            return _buildRow(labels[i].label, labels[i].confidence.toString(),
                labels[i].index.toString());
          }),
    );
  }

  Widget displaySelectedFile(File? file) {
    return SizedBox(
      child: file == null
          ? const Center(
              child: Text(
              'Sorry nothing selected!!',
              style: TextStyle(fontSize: 20),
            ))
          : Container(
              margin: const EdgeInsets.all(20),
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: FileImage(file, scale: 1), fit: BoxFit.cover),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(width: 2.5, color: Colors.blue)),
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
