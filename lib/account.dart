import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'listview.dart';

class MyAccount extends StatefulWidget {
  @override
  Account createState() => Account();
}

class Account extends State<MyAccount> {
  List<DocumentSnapshot> documentList = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple,
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SampleList(),
                    ));
              },
              icon: Icon(Icons.anchor_rounded))
        ],
        backgroundColor: Colors.black,
        title: Text(
          "Images",
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: Center(
        child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('images')
                .orderBy('image')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final List<DocumentSnapshot> documents = snapshot.data!.docs;

                return ListView(
                  children: documents.map((document) {
                    return Column(
                      //mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // todo /////////////
                        SizedBox(
                          width: 300,
                          child: Card(
                            color: Colors.lightGreenAccent,
                            child: ListTile(
                              title: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.network(document['image'])),
                              leading: IconButton(
                                icon: Icon(Icons.add_sharp),
                                onPressed: () {},
                              ),

                              //subtitle: Text(document['email']),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                );
              }
              return Center(
                child: Text("Loading"),
              );
            }),
      ),
    );
    // TODO: implement build
  }
}
