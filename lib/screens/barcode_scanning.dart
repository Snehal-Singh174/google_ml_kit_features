import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';


class BarcodeScanning extends StatefulWidget {
  const BarcodeScanning({super.key, required this.title});

  final String title;

  @override
  State<BarcodeScanning> createState() => _BarcodeScanningState();
}

class _BarcodeScanningState extends State<BarcodeScanning> {
  String? text;

  final List<BarcodeFormat> formats = [BarcodeFormat.all,];

  final id = DateTime.now().microsecondsSinceEpoch.toString();

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
                      setState(() {
                        text = 'processing...';
                      });
                      var barCodeScanner = GoogleMlKit.vision.barcodeScanner();
                      final visionImage = InputImage.fromFilePath(file!.path);

                      var barcodeText= await barCodeScanner.processImage(visionImage);

                      for(Barcode barcode in barcodeText){
                        setState(() {
                          text = barcode.displayValue!;
                        });

                      }
                    } catch (e) {
                      log(e.toString());
                      setState(() {
                        text = e.toString();
                      });
                    }
                  }, icon: const Icon(Icons.camera_alt, size: 50, color: Colors.blue,)),
                  IconButton(onPressed: () async{
                    try {
                      var file =
                          await ImagePicker.platform.pickImage(source: ImageSource.gallery);
                      setState(() {
                        text = 'processing...';
                      });
                      final barcodeScanner = BarcodeScanner(formats: formats);
                      final InputImage inputImage = InputImage.fromFile(File(file!.path));
                      final List<Barcode> barcodes = await barcodeScanner.processImage(inputImage);

                      setState(()  {
                        text = barcodes.first.displayValue.toString();
                      });
                    } catch (e) {
                      log(e.toString());
                      setState(() {
                        text = e.toString();
                      });
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
