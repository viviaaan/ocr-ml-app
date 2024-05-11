import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as imageLib;
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';

class TfliteModel extends StatefulWidget {
  const TfliteModel({super.key});
  @override
  State<TfliteModel> createState() => _TfliteModelState();
}

class _TfliteModelState extends State<TfliteModel> {
  late File _image;
  late List _results;
  bool imageSelect=false;
  late Interpreter _interpreter;

  void initState (){
    super.initState();
    loadModel();
  }

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset("model.tflite");
      // print(_interpreter!.getInputTensors().first);
      print('Model loaded successfully');
      // You can optionally call imageClassification here if you want to start classification immediately after loading the model
    } catch (e) {
      print('Failed to load model: $e');
    }
  }
  void imageClassification(File image) {
    try {
      if (_interpreter == null) {
        print("Interpreter not initialized");
        return;
      }

      var imageInput = imageLib.decodeImage(image.readAsBytesSync());
      var resized = imageLib.copyResize(imageInput!, height: 224, width: 224);
      var bytes = resized.getBytes().toList();
      List<List<List<double>>> inp = List.filled(224,List.filled(224, List.filled(3, 0)));
      int idx = 0;
      var output = List.filled(1*1001, 0).reshape([1,1001]);
      for (int i = 0; i < 224; i++) {
        for (int j = 0; j < 224; j++) {
          for (int k = 0; k < 3; k++) {
            if (k + 1 < bytes.length) {
              inp[i][j][k] = bytes[idx].toDouble();
              idx++;
              if (k == 2) {
                idx++;
              }
            }
          }
        }
      }
      print(_interpreter.getInputTensors().first);

      _interpreter!.run([inp],output);
      print(output);
      print(output.shape);
      double m = 0;
      for (int i = 0; i < 1001; i++) {
        m = max(m, output[0][i]);
      }
      print(m);
      for (int i = 0; i < 1001; i++) {
        if (output[0][i] == m) {
          print(i);
        }
      }
      // print(output.indexOf(m));

      // List? recognitions = _interpreter!.getOutputTensors()[0].data.toList();
      // setState(() {
      //   _results = recognitions;
      //   _image = image;
      //   imageSelect = true;
      // }
      // );
    } catch (e) {
      print("Error running model: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("IMAGE CLASSIFICATION"),
        backgroundColor: Colors.cyan,
      ),


      body: ListView(
        children: [
        (imageSelect)?Container(
      margin: const EdgeInsets.all(10),
      child: Image.file(_image),
    ):Container(
      margin: const EdgeInsets.all(10),
      child: const Opacity(
        opacity: 0.8,
        child: Center(
          child: Text("No image selected"),
        ),
      ),
    ),
    SingleChildScrollView(
    child: Column(
    children: (imageSelect)?_results.map((result) {
    return Card(
    child: Container(
    margin: EdgeInsets.all(10),
    child: Text(
    "${result['label']} - ${result['confidence'].toStringAsFixed(2)}",
    style: const TextStyle(color: Colors.red,
    fontSize: 20),
    ),
    ),
    );
    }).toList():[],

    ),
    )
    ],
    ),
    floatingActionButton: FloatingActionButton(
    onPressed: pickImage,
    tooltip: "Pick Image",
    child: const Icon(Icons.image),
    ),
    );
  }

  void pickImage() async
  {
    final XFile? pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    File image  =  File(pickedImage!.path);
    imageClassification(image);

  }
}
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//



// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:tflite_flutter/tflite_flutter.dart';
//
// class TfliteModel extends StatefulWidget {
//   const TfliteModel({Key? key}) : super(key: key);
//
//   @override
//   _TfliteModelState createState() => _TfliteModelState();
// }
//
// class _TfliteModelState extends State<TfliteModel> {
//   late File _image;
//   late List _results;
//   bool imageSelect = false;
//   late Interpreter _interpreter;
//
//   @override
//   void initState() {
//     super.initState();
//     loadModel();
//   }
//
//   Future<void> loadModel() async {
//     try {
//       _interpreter = await Interpreter.fromAsset("assets/model.tflite");
//       print('Model loaded successfully');
//     } catch (e) {
//       print('Failed to load model: $e');
//     }
//   }
//
//   Future<void> imageClassification(File image) async {
//     try {
//       if (_interpreter == null) {
//         print("Interpreter not initialized");
//         return;
//       }
//
//       final input = image.readAsBytesSync();
//       final inputs = <String, dynamic>{};
//       inputs['image'] = input;
//
//       final outputs = [0];
//       _interpreter.run(inputs,  outputs);
//       final outputData = _interpreter.getOutputTensors()[0].data;
//       setState(() {
//         _results =outputData;
//         _image = image;
//         imageSelect = true;
//       });
//     } catch (e) {
//       print("Error running model: $e");
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Image Classification"),
//       ),
//       body: ListView(
//         children: [
//           (imageSelect)
//               ? Container(
//             margin: const EdgeInsets.all(10),
//             child: Image.file(_image),
//           )
//               : Container(
//             margin: const EdgeInsets.all(10),
//             child: const Opacity(
//               opacity: 0.8,
//               child: Center(
//                 child: Text("No image selected"),
//               ),
//             ),
//           ),
//           SingleChildScrollView(
//             child: Column(
//               children: (imageSelect)
//                   ? [
//                 Card(
//                   child: Container(
//                     margin: EdgeInsets.all(10),
//                     child: Text(
//                       _results.toString(),
//                       style: const TextStyle(
//                         color: Colors.red,
//                         fontSize: 20,
//                       ),
//                     ),
//                   ),
//                 ),
//               ]
//                   : [],
//             ),
//           )
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: pickImage,
//         tooltip: "Pick Image",
//         child: const Icon(Icons.image),
//       ),
//     );
//   }
//
//   void pickImage() async {
//     final ImagePicker _picker = ImagePicker();
//     final XFile? pickedFile = await _picker.pickImage(
//       source: ImageSource.gallery,
//     );
//     if (pickedFile != null) {
//       File image = File(pickedFile.path);
//       imageClassification(image);
//     }
//     }
//   }