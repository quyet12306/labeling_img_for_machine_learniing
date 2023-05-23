import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class ChooseSauBenh extends StatefulWidget {
  ChooseSauBenh(
    this.file, {
    super.key,
    this.loaicay,
  });
  XFile file;
  final String? loaicay;
  @override
  State<ChooseSauBenh> createState() => _ChooseSauBenhState();
}

class _ChooseSauBenhState extends State<ChooseSauBenh> {
  // list sau benh tung loai

  List<List<String>> optioncay = [
    ["sương mai", "thán thư", "chảy nhựa", "héo thân", "phấn trắng"],
    [
      "đạo ôn",
      "khô vằn",
      "vàng lùn",
    ],
    ["sương mai", "mất màu", "nứt quả", "sém mép lá"],
    ["vàng lá", "chảy mủ", "ghẻ nhám", "loét khuẩn", "thán thư"]
  ];
  // list options
  List<String> options = ["Dưa lưới", "Lúa", "Vải", "Bưởi"];
  // flag of loai sau benh
  int _flag_cay = 0;
  // ham check loai sau benh cho cay

  int? hamcheckLoaiCay(loaicay) {
    for (int i = 0; i < options.length; i++) {
      if (loaicay == options[i]) {
        return _flag_cay = i;
      }
    }
  }

  // upload file img
  // _uploadFile(String foldername, String imgname) async {
  //   try {
  //     firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
  //         .ref()
  //         .child(foldername)
  //         .child('/' + imgname)
  //         .child('/' + widget.file.name);

  //     firebase_storage.UploadTask uploadTask =
  //         ref.putFile(File(widget.file.path));
  //     await uploadTask.whenComplete(() => null);
  //     String imageurl = await ref.getDownloadURL();
  //     print("upload image url " + imageurl);
  //   } catch (e) {
  //     print(e);
  //   }
  // }
  _uploadFile(String foldername, String imgname) async {
    try {
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child(foldername)
          .child(imgname);

      // Lấy danh sách các file trong folder `imgname`
      firebase_storage.ListResult result = await ref.listAll();
      int count = result.items.length;

      // Tính toán số thứ tự của file mới
      String num = (count + 1).toString().padLeft(3, '0');

      // Đổi tên file mới thành `imgname_xxx`

      String oldfilename = widget.file.name;
      String duoifile = oldfilename.split(".").last;
      String tenfile = oldfilename.split(".").first;
      String newFilename = '$imgname' + '_$num';
      tenfile = newFilename;

      ref = ref.child(tenfile + "." + duoifile);

      firebase_storage.UploadTask uploadTask =
          ref.putFile(File(widget.file.path));
      await uploadTask.whenComplete(() => null);
      String imageurl = await ref.getDownloadURL();
      print("upload image url " + imageurl);
    } catch (e) {
      print(e);
    }
  }
  // ham add them nut

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    File picture = File(widget.file.path);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Chon sau benh cho ${widget.loaicay ?? ""}",
          style: TextStyle(
              color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
              size: 30,
            )),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: size.width,
              height: size.height * .60,
              // decoration: BoxDecoration(color: Colors.greenAccent),
              child: Center(
                // child: Text(
                //   "picture".toUpperCase(),
                //   style: TextStyle(
                //       color: Colors.black,
                //       fontSize: 30,
                //       fontWeight: FontWeight.w500),
                // ),
                child: Image.file(picture),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              width: size.width,
              child: Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: List.generate(
                    optioncay[hamcheckLoaiCay(widget.loaicay) ?? 0].length,
                    (index) {
                  // return Chip(
                  //   label: Text(optioncay[hamcheckLoaiCay(widget.loaicay)??0][index]),
                  // );
                  return InkWell(
                    onTap: () {
                      var loaicay = widget.loaicay;
                      var loaibenh =
                          optioncay[hamcheckLoaiCay(widget.loaicay) ?? 0]
                              [index];
                      print("loai cay = ${loaicay}");
                      print("loai benh = ${loaibenh}");
                      print("file path = ${widget.file.path}");
                      print("file name= ${widget.file.name}");
                      _uploadFile(loaicay.toString(), loaibenh.toString());
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                      ),
                      constraints: BoxConstraints(
                        minWidth: 50,
                        maxWidth: 200,
                      ),
                      child: Text(
                        optioncay[hamcheckLoaiCay(widget.loaicay) ?? 0][index],
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 25,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              width: size.width,
              height: size.height * .05,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InkWell(
                    onTap: () {},
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          color: Colors.red,
                          border: Border.all(
                              width: 2, color: Colors.black.withOpacity(.2))),
                      width: size.width * .40,
                      height: size.height * .05,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.delete,
                            color: Colors.black,
                            size: 20,
                          ),
                          Text(
                            "delete".toUpperCase(),
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.w400),
                          )
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {},
                    child: Container(
                        width: size.width * .40,
                        height: size.height * .05,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                            border: Border.all(
                                width: 2, color: Colors.black.withOpacity(.2))),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_circle_outline,
                              color: Colors.black,
                              size: 20,
                            ),
                            Text(
                              "add new sick".toUpperCase(),
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400),
                            )
                          ],
                        )),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
