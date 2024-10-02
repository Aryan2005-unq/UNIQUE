import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image to 3D Model',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ImageTo3DModelScreen(),
    );
  }
}

class ImageTo3DModelScreen extends StatefulWidget {
  @override
  _ImageTo3DModelScreenState createState() => _ImageTo3DModelScreenState();
}

class _ImageTo3DModelScreenState extends State<ImageTo3DModelScreen> {
  File? _image;
  String? _modelUrl;
  bool _isLoading = false;
  final picker = ImagePicker();

  Future pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<String> uploadImageToFirebase(File imageFile) async {
    String fileName = basename(imageFile.path);
    Reference storageRef = FirebaseStorage.instance.ref().child('uploads/$fileName');
    UploadTask uploadTask = storageRef.putFile(imageFile);
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<void> generate3DModel(String imageUrl) async {
    setState(() {
      _isLoading = true;
    });

    const String apiUrl = 'https://api.meshy.ai/v1/image-to-3d';
    const String apiKey = 'YOUR_API_KEY'; // Replace with your actual API key

    Map<String, dynamic> body = {
      "image_url": imageUrl,
      "enable_pbr": true,
      "ai_model": "meshy-4",
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final taskId = responseData['result'];

        // Now you can poll the task status to get the model URL
        await getModelUrl(taskId);
      } else {
        print('Failed to generate model: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> getModelUrl(String taskId) async {
    const String apiUrl = 'https://api.meshy.ai/v1/image-to-3d/';
    const String apiKey = 'YOUR_API_KEY'; // Replace with your actual API key

    try {
      final response = await http.get(
        Uri.parse('$apiUrl$taskId'),
        headers: {
          'Authorization': 'Bearer $apiKey',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          _modelUrl = responseData['model_urls']['glb'];
        });
      } else {
        print('Failed to retrieve model URL: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image to 3D Model'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _image == null
                ? Text('No image selected.')
                : Image.file(_image!, height: 150, width: 150),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () async {
                      if (_image != null) {
                        String imageUrl = await uploadImageToFirebase(_image!);
                        await generate3DModel(imageUrl);
                      }
                    },
                    child: Text('Generate 3D Model'),
                  ),
            SizedBox(height: 20),
            _modelUrl != null
                ? Text('Model URL: $_modelUrl')
                : Text('No model generated yet.'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: pickImage,
        child: Icon(Icons.add_a_photo),
      ),
    );
  }
}
