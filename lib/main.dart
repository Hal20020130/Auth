import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'next.dart';

void main2() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyAuthPage(),
    );
  }
}

class MyAuthPage extends StatefulWidget {
  @override
  _MyAuthPageState createState() => _MyAuthPageState();
}

class _MyAuthPageState extends State<MyAuthPage> {
  // 入力されたメールアドレス
  String newUserEmail = "";
  // 入力されたパスワード
  String newUserPassword = "";
  // 登録・ログインに関する情報を表示
  String infoText = "";

  //プロフィール写真
  String ImageURL = "";
  //ユーザーの名前
  String UserName = "";
  // 入力されたメールアドレス（ログイン）
  String loginUserEmail = "";
  // 入力されたパスワード（ログイン）
  String loginUserPassword = "";
  // 登録・ログインに関する情報を表示

  File? _image;
  final picker = ImagePicker();
  Future getImageFromGallery() async {
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );
    setState(() {
      _image = File(pickedFile!.path);
    });
  }

  //画像選択
  Future<String> uploadImage() async {
    final Reference ref = FirebaseStorage.instance.ref();
    //参照
    final TaskSnapshot storedImage =
        await ref.child('プロフィール写真/$UserName').putFile(_image!);

    ImageURL = await storedImage.ref.getDownloadURL();
    return ImageURL;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurpleAccent[100],
      appBar: AppBar(
        backgroundColor: Colors.black,
        bottomOpacity: 10,
        actions: [
          IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.add_shopping_cart_outlined,
                color: Colors.white,
              ))
        ],
        title: Text(
          "認証",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
        ),
      ),
      body: Center(
        child: Container(
          height: 1000,
          //color: Colors.black12,
          padding: EdgeInsets.only(left: 32, right: 32, bottom: 0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                InkWell(
                  onTap: () async {
                    await getImageFromGallery();
                  },
                  child: _image != null
                      ? Padding(
                          padding: const EdgeInsets.only(bottom: 8, top: 30),
                          child: CircleAvatar(
                            backgroundImage: FileImage(_image!),
                            radius: 100,
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CircleAvatar(
                            backgroundColor: Colors.deepPurple,
                            child: Icon(
                              Icons.add_photo_alternate,
                              size: 100,
                            ),
                            radius: 100,
                          ),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.black87,
                      onPrimary: Colors.cyanAccent,
                      shadowColor: Colors.cyanAccent,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () async {
                      await uploadImage();

                      //await getImageFromGallery();
                    },
                    //onPressed: getImageFromGallery, //ギャラリーから画像を取得
                    child: Icon(Icons.storage),
                    //child: Text("ss")),
                  ),
                ),
                TextFormField(
                  // テキスト入力のラベルを設定
                  decoration: InputDecoration(
                      hoverColor: Colors.white,
                      fillColor: Colors.white,
                      focusColor: Colors.white,
                      labelText: "名前",
                      labelStyle: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w900)),
                  onChanged: (String value) {
                    setState(() {
                      UserName = value;
                    });
                  },
                ),
                TextFormField(
                  // テキスト入力のラベルを設定
                  decoration: InputDecoration(
                      labelText: "メールアドレス",
                      labelStyle: TextStyle(
                          color: Colors.cyanAccent,
                          fontWeight: FontWeight.w900)),
                  onChanged: (String value) {
                    setState(() {
                      newUserEmail = value;
                    });
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(
                      labelText: "パスワード",
                      labelStyle: TextStyle(
                          color: Colors.cyanAccent,
                          fontWeight: FontWeight.w900)),
                  // パスワードが見えないようにする
                  obscureText: true,
                  onChanged: (String value) {
                    setState(() {
                      newUserPassword = value;
                    });
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shadowColor: Colors.cyanAccent,
                    shape: const StadiumBorder(),
                    primary: Colors.black87,
                    elevation: 2,
                  ),
                  onPressed: () async {
                    try {
                      /*await Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) {
                          return Home();
                        }),
                      );*/
                      // メール/パスワードでユーザー登録
                      final FirebaseAuth auth = FirebaseAuth.instance;
                      final UserCredential result =
                          await auth.createUserWithEmailAndPassword(
                        email: newUserEmail,
                        password: newUserPassword,
                      );

                      // 登録したユーザー情報
                      final User user = result.user!;
                      var currentUser = FirebaseAuth.instance.currentUser;
                      if (mounted) {
                        await FirebaseFirestore.instance
                            .collection('users') // コレクションID
                            .doc(currentUser!.uid) // ドキュメントID
                            .set({
                          '名前': UserName,
                          'ImageURL': ImageURL,
                          'メールアドレス': newUserEmail,
                          "パスワード": newUserPassword,
                        }); // ←これを追加！！
                        setState(() {
                          infoText = "登録OK：${user.email}";
                        });
                      }

                      //todo 画面遷移
                    } catch (e) {
                      if (mounted) {
                        // ←これを追加！！
                        setState(() {
                          infoText = "登録OK：${e.toString()}";
                        });
                      }
                      // 登録に失敗した場合
                    }
                  },
                  child: Text(
                    "ユーザー登録",
                    style: TextStyle(
                        fontWeight: FontWeight.w600, color: Colors.cyanAccent),
                  ),
                ),
                const SizedBox(height: 8),
                Text(infoText),
                const SizedBox(height: 60),
                TextFormField(
                  // テキスト入力のラベルを設定
                  decoration: InputDecoration(
                      labelText: "メールアドレス",
                      labelStyle: TextStyle(
                          color: const Color(0xFF020202),
                          fontWeight: FontWeight.w900)),
                  onChanged: (String value) {
                    if (mounted) {
                      // ←これを追加！！
                      setState(() {
                        loginUserEmail = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 8),
                TextFormField(
                  decoration: InputDecoration(
                      labelText: "パスワード（６文字以上）",
                      labelStyle: TextStyle(
                          color: const Color(0xFF020202),
                          fontWeight: FontWeight.w900)),
                  // パスワードが見えないようにする
                  obscureText: true,
                  onChanged: (String value) {
                    if (mounted) {
                      // ←これを追加！！
                      setState(() {
                        loginUserPassword = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: const StadiumBorder(),
                    primary: Colors.white,
                    elevation: 2,
                  ),
                  onPressed: () async {
                    try {
                      final FirebaseAuth auth = FirebaseAuth.instance;
                      final UserCredential result =
                          await auth.signInWithEmailAndPassword(
                        email: loginUserEmail,
                        password: loginUserPassword,
                      );
                      final User user = result.user!;

                      // メール/パスワードでログイン

                      // ログインに成功した場合

                      if (mounted) {
                        // ←これを追加！！
                        setState(() {
                          infoText = "ログインOK：${user.email}";
                        });
                      }
                      await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Next(user),
                          ));
                    } catch (e) {
                      // ログインに失敗した場合
                      if (mounted) {
                        // ←これを追加！！
                        setState(() {
                          infoText = "ログインNG：${e.toString()}";
                        });
                      }
                    }
                  },
                  child: Text(
                    "ログイン",
                    style: TextStyle(
                        fontWeight: FontWeight.w900, color: Colors.deepPurple),
                  ),
                ),
                const SizedBox(height: 8),
                Text(infoText),
                const SizedBox(height: 70),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
