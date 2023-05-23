import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

import 'opencamera.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  cameras = await availableCameras();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // home: HomePage(),
      home: openCamera(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String defaultImageUrl =
      'https://cdn.pixabay.com/photo/2016/03/23/15/00/ice-cream-1274894_1280.jpg';
  String selctFile = '';
  late XFile? file;
  //This modal shows image selection either from gallery or camera
  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      //backgroundColor: Colors.transparent,
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Container(
            height: MediaQuery.of(context).size.height * 0.15,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
            ),
            child: Wrap(
              children: <Widget>[
                SizedBox(
                  height: 10,
                ),
                ListTile(
                    leading: const Icon(
                      Icons.photo_library,
                    ),
                    title: const Text(
                      'Gallery',
                      style: TextStyle(),
                    ),
                    onTap: () {
                      _selectFile(true);
                      Navigator.of(context).pop();
                    }),
                ListTile(
                  leading: const Icon(
                    Icons.photo_camera,
                  ),
                  title: const Text(
                    'Camera',
                    style: TextStyle(),
                  ),
                  onTap: () {
                    _selectFile(false);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // _selectFile(bool isPickingImage) async {
  //   FilePickerResult fileResult =
  //       await FilePicker.platform.pickFiles(type: FileType.any);

  //   if (fileResult != null) {
  //     print(fileResult);

  //     File file = File(fileResult.files.single.path);
  //     setState(() {
  //       if (isPickingImage) {
  //         selctFile = fileResult.files.first.name;
  //         selectedBookImageInBytes = file.readAsBytesSync();
  //       } else {
  //         bookName = fileResult.files.first.name;
  //         selectedBookPdfInBytes = file.readAsBytesSync();
  //       }
  //     });
  //   }
  //   print('LENGTH OF SELECTED IMAGE ${selectedBookImageInBytes.length}');
  // }

  _selectFile(bool imageFrom) async {
    file = await ImagePicker().pickImage(
      source: imageFrom ? ImageSource.gallery : ImageSource.camera,
    );
    if (file != null) {
      setState(() {
        selctFile = file!.name;
      });
    }
    print(file?.name);
  }

  // _uploadFile() async {
  //   try {
  //     firebase_storage.UploadTask uploadTask;
  //     firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
  //         .ref()
  //         .child('product')
  //         .child('/' + file!.name);

  //     ref.putFile(File(file!.path));
  //     await uploadTask.whenComplete(() => null);
  //   } catch (e) {}
  // }

  _uploadFile() async {
    try {
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('product')
          .child('/' + file!.name);
      print("file = ${file!.name}");

      firebase_storage.UploadTask uploadTask = ref.putFile(File(file!.path));
      await uploadTask.whenComplete(() => null);
      String imageurl = await ref.getDownloadURL();
      print("upload image url " + imageurl);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text("upload img firebase"),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: size.height * .02,
              ),
              Container(
                height: size.height * .2,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: selctFile.isEmpty
                    ? Image.network(
                        defaultImageUrl,
                        fit: BoxFit.cover,
                      )
                    : Image.file(
                        File(file!.path),
                        fit: BoxFit.fill,
                      ),
              ),
              SizedBox(
                height: size.height * .02,
              ),
              SizedBox(
                height: size.height * .05,
                child: ElevatedButton.icon(
                    onPressed: () {
                      _showPicker(context);
                    },
                    icon: Icon(Icons.camera),
                    label: Text(
                      "choose image",
                      style: TextStyle(),
                    )),
              ),
              SizedBox(
                height: size.height * .05,
                child: ElevatedButton(
                    onPressed: () {
                      _uploadFile();
                    },
                    child: Text("upload")),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
