import 'dart:io';

import 'package:auth/account.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Next extends StatefulWidget {
  Next(this.user, {uid});
  final User user;

  @override
  _NextState createState() => _NextState();
}

class _NextState extends State<Next> {
  final date0 = DateTime.now().toLocal().toIso8601String();

  final picker = ImagePicker();
  File? _image;

  //イメージピッカー
  Future getImageFromGallery() async {
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );
    setState(() {
      _image = File(pickedFile!.path);
    });
  }

  //プロフィール写真
  String ImageURL = "";
  //画像アップロード
  Future<String> uploadImage() async {
    setState(() {
      //todo
    });
    final Reference ref = FirebaseStorage.instance.ref();
    //参照
    final TaskSnapshot storedImage =
        await ref.child('イメージインチャット/$currentUser$date0').putFile(_image!);

    ImageURL = await storedImage.ref.getDownloadURL();
    return ImageURL;
  }

  //プロフィール画像取得
  List<DocumentSnapshot> documentList2 = [];
  Future ChatImagesURL() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('posts')
        .doc(currentUser!.uid)
        .get();
    // 取得したドキュメント一覧をUIに反映
    setState(() {
      orderDocumentInfo = snapshot['image'];
    });
  }

  //ログインユーザー
  var currentUser = FirebaseAuth.instance.currentUser;

  String messageText = '';
  String orderDocumentInfo = "";

  //チャットボックスのコントローラー
  late ScrollController _scrollController;
  final TextEditingController _controller = new TextEditingController();

  //プロフィール画像取得
  List<DocumentSnapshot> documentList = [];
  Future Urlss() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .get();
    // 取得したドキュメント一覧をUIに反映
    setState(() {
      orderDocumentInfo = snapshot['ImageURL'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.indigo[100],
        appBar: AppBar(
          actions: [
            IconButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                },
                icon: Icon(
                  Icons.logout_rounded,
                  color: Colors.black,
                )),
            IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MyAccount(),
                    ));
              },
              icon: Icon(Icons.anchor),
              color: Colors.lightGreenAccent,
            )
          ],
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          backgroundColor: Colors.deepPurple,
          title: Text(
            '${currentUser!.email}',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w100),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.only(right: 0, left: 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('ユーザー${currentUser!.uid}'),
              Flexible(
                child: StreamBuilder<QuerySnapshot>(
                  // 投稿メッセージ一覧を取得（非同期処理）
                  // 投稿日時でソート

                  stream: FirebaseFirestore.instance
                      .collection('posts')
                      .orderBy('date')
                      .snapshots(),
                  builder: (context, snapshot) {
                    // データが取得できた場合
                    if (snapshot.hasData) {
                      final List<DocumentSnapshot> documents =
                          snapshot.data!.docs;
                      // 取得した投稿メッセージ一覧を元にリスト表示
                      return Padding(
                        padding: const EdgeInsets.only(
                          right: 8,
                          left: 8,
                        ),
                        child: ListView(
                          controller: _scrollController,
                          //reverse: true,
                          shrinkWrap: true,
                          children: documents.map((document) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: 20, bottom: 6),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            right: 10, left: 2, top: 0),
                                        child: CircleAvatar(
                                          backgroundColor: Colors.red,
                                          child: Text(orderDocumentInfo),
                                          backgroundImage:
                                              NetworkImage(orderDocumentInfo),
                                          // backgroundImage: NetworkImage(
                                          //  "https://firebasestorage.googleapis.com:443/v0/b/auth-e1f12.appspot.com/o/%E3%83%97%E3%83%AD%E3%83%95%E3%82%A3%E3%83%BC%E3%83%AB%E5%86%99%E7%9C%9F%2F%E9%B3%A5%E4%BA%95%E6%B3%A2%E7%90%89?alt=media&token=0acb0d36-9c9a-4a5d-8c49-1d0c45363bc7"),
                                          radius: 17,
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(document['date']),
                                          Container(
                                            constraints:
                                                BoxConstraints(maxWidth: 300),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: Colors.deepPurpleAccent,
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Column(
                                                children: [
                                                  Text(
                                                    document['text'],
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w400),
                                                  ),
                                                  Text(
                                                    document['userMail'],
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontSize: 7),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                //Image.network(orderDocumentInfo),

                                // todo /////////////

                                (document['text'] != "")
                                    ? Text(
                                        "text",
                                        style: TextStyle(fontSize: 10),
                                      )
                                    : Image.network(orderDocumentInfo),
                              ],
                            );
                          }).toList(),
                        ),
                      );
                    }

                    // データが読込中の場合
                    return Center(
                      child: Text('読込中...'),
                    );
                  },
                ),
              ),
              Material(
                color: Colors.indigo[100],
                elevation: 10,
                child: Padding(
                  padding: const EdgeInsets.only(
                      right: 0, left: 0, top: 10, bottom: 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 45,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.black,
                            onPrimary: Colors.lightGreenAccent,
                            shape: const CircleBorder(
                              side: BorderSide(
                                color: Colors.black,
                                width: 1,
                                style: BorderStyle.solid,
                              ),
                            ),
                          ),
                          child: Icon(Icons.add),
                          //icon: Icon(Icons.thumb_up),
                          onPressed: () {
                            getImageFromGallery();
                          },
                        ),
                      ),
                      SizedBox(
                        height: 47,
                        width: 300,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            //border: Border.all(color: Colors.red),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(right: 20, left: 20),
                            child: TextFormField(
                              controller: _controller,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'ここに入力',
                                hintStyle: TextStyle(color: Colors.white),
                              ),
                              keyboardType: TextInputType.multiline,
                              // 最大3行
                              maxLines: 3,
                              onChanged: (String value) {
                                messageText = value;
                              },
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.only(bottom: 0, right: 0, left: 0),
                        child: SizedBox(
                          height: 45,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Colors.black,
                              onPrimary: Colors.lightGreenAccent,
                              shape: const CircleBorder(
                                side: BorderSide(
                                  color: Colors.black,
                                  width: 1,
                                  style: BorderStyle.solid,
                                ),
                              ),
                            ),
                            child: Icon(Icons.send),
                            //icon: Icon(Icons.thumb_up),flutter
                            onPressed: () async {
                              uploadImage();
                              _controller.clear();
                              final date0 = DateTime.now()
                                  .toLocal()
                                  .toIso8601String(); // 現在の日時
                              //final email = widget.user.email; // AddPostPage のデータを参照
                              // 投稿メッセージ用ドキュメント作成
                              await FirebaseFirestore.instance
                                  .collection('posts') // コレクションID指定
                                  .doc() // ドキュメントID自動生成
                                  .set({
                                'text': messageText,
                                //'email': email,
                                'date': date0,
                                "userID": currentUser!.uid,
                                "userMail": currentUser!.email,
                                'プロフォール画像': ImageURL,
                              });

                              scrollToBottom();

                              // 1つ前の画面に戻る
                            },
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void scrollToBottom() {
    final bottomOffset = _scrollController.position.maxScrollExtent;
    _scrollController.animateTo(
      bottomOffset,
      duration: Duration(milliseconds: 1000),
      curve: Curves.easeInOut,
    );
  }

  @override
  void initState() {
    _scrollController = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
