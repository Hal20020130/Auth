import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SampleList extends StatefulWidget {
  @override
  _SampleListState createState() => _SampleListState();
}

class _SampleListState extends State<SampleList> {
  List<Color> colorList = [Colors.cyan, Colors.deepOrange, Colors.indigo];
  late ScrollController _scrollController;
  List<DocumentSnapshot> documentList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text(
            "sss",
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: Center(
          child: ListView.builder(
            itemCount: 20,
            controller: _scrollController,
            itemBuilder: (BuildContext context, int index) {
              return Column(
                children: [
                  Container(
                    child: IconButton(
                        onPressed: () {
                          scrollToBottom();
                          print("object");
                        },
                        icon: Icon(Icons.anchor)),
                    height: 80,
                    color: colorList[index % colorList.length],
                  ),
                ],
              );
            },
          ),
        ));
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
