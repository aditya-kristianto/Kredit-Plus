import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

class AddItemsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return AddItemsPageState();
  }
}

class AddItemsPageState extends State<AddItemsPage> {
  final formKey = GlobalKey<FormState>();

  bool isAdmin = false;
  bool isInputItemMode = false;
  String name, supplier;
  int quantity;

  @override
  void initState() {
    super.initState();

    FirebaseAuth.instance.currentUser().then((user) {
      checkIsAdmin(user.uid);
    });
  }

  @override
  void dispose() {
    this.formKey.currentState != null ?? this.formKey.currentState.dispose();
    this.isAdmin = false;
    this.isInputItemMode = false;
    this.name = '';
    this.supplier = '';
    this.quantity = 0;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: ()async {
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(this.isInputItemMode ? 'Add Items' : 'Items'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: () {
                FirebaseAuth.instance.signOut().catchError((error) {
                  Fluttertoast.showToast(
                      msg: 'Failed to sign out.',
                      toastLength: Toast.LENGTH_LONG,
                      gravity: ToastGravity.TOP,
                      timeInSecForIos: 2,
                      backgroundColor: Colors.redAccent,
                      textColor: Colors.white,
                      fontSize: 13.0);
                }).whenComplete(() {
                  Navigator.pushReplacementNamed(context, '/login');
                });
              },
            ),
          ],
        ),
        body: SafeArea(
          child: Center(
            child: this.isInputItemMode ? drawAddItemForm() : drawItemList(),
          ),
        ),
        floatingActionButton: this.isInputItemMode
            ? null
            : (this.isAdmin
                ? FloatingActionButton(
                    onPressed: () {
                      setState(() {
                        this.isInputItemMode = true;
                      });
                    },
                    tooltip: 'Increment',
                    child: Icon(Icons.add),
                  )
                : null)));
  }

  void showDatePicker() {
    DatePicker.showDatePicker(context,
        showTitleActions: true,
        minTime: DateTime(2018, 3, 5),
        maxTime: DateTime(2019, 6, 7), onChanged: (date) {
      print('change $date');
    }, onConfirm: (date) {
      print('confirm $date');
    }, currentTime: DateTime.now(), locale: LocaleType.zh);
  }

  void checkIsAdmin(String uid) {
    Firestore.instance
        .collection('users')
        .where('uid', isEqualTo: uid)
        .snapshots()
        .listen((data) {
      setState(() {
        this.isAdmin = data.documents[0]['is_admin'];
      });
    });
  }

  void submitForm() {
    Firestore.instance.collection('items').add({
      'name': this.name,
      'supplier': this.supplier,
      'quantity': this.quantity,
      'created_at': FieldValue.serverTimestamp()
    }).then((result) {
      setState(() {
        this.isInputItemMode = false;
      });

      return Fluttertoast.showToast(
          msg: 'Add new item data success.',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          timeInSecForIos: 3,
          backgroundColor: Colors.blueAccent,
          textColor: Colors.white,
          fontSize: 13.0);
    }).catchError((error) {
      return Fluttertoast.showToast(
          msg: 'Add new item data failed.',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          timeInSecForIos: 2,
          backgroundColor: Colors.redAccent,
          textColor: Colors.white,
          fontSize: 13.0);
    });
  }

  Widget drawAddItemForm() {
    return SingleChildScrollView(
      child: Container(
        width: 0.9 * MediaQuery.of(context).size.width,
        child: Form(
          key: formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter item name';
                  }

                  setState(() {
                    this.name = value;
                  });

                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter item quantity';
                  }

                  setState(() {
                    this.quantity = int.tryParse(value);
                  });

                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Supplier'),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter item supplier';
                  }

                  setState(() {
                    this.supplier = value;
                  });

                  return null;
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  RaisedButton(
                    onPressed: () {
                      if (formKey.currentState.validate()) {
                        submitForm();
                      }
                    },
                    child: Text('Submit'),
                  ),
                  RaisedButton(
                    onPressed: () {
                      setState(() {
                        this.isInputItemMode = false;
                      });
                    },
                    child: Text('Cancel'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget drawItemList() {
    return Container(
      width: 0.9 * MediaQuery.of(context).size.width,
      child: StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection('items')
            .orderBy('name', descending: false)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) return Text('Error: ${snapshot.error}');
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return new Text('Loading...');
            default:
              return ListView(
                children:
                    snapshot.data.documents.map((DocumentSnapshot document) {
                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(5)
                    ),
                    margin: EdgeInsets.only(top: 5.0, bottom: 5.0),
                    padding: EdgeInsets.all(5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(document['created_at'] != null
                            ? document['created_at'].toDate().toString()
                            : ''),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(document['name'] != null
                                ? document['name']
                                : ''),
                            Text(document['quantity'] != null
                                ? document['quantity'].toString()
                                : '')
                          ],
                        ),
                        Text(document['supplier'] != null
                            ? document['supplier']
                            : '')
                      ],
                    ),
                  );
                }).toList(),
              );
          }
        },
      ),
    );
  }
}
