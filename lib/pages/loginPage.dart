import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  final String title = 'Kredit Plus';

  @override
  State<StatefulWidget> createState() {
    return LoginPageState();
  }
}

class LoginPageState extends State<LoginPage> {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();

  String username, password;
  bool isObscureText = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title != null ? widget.title : ''),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
      child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 0.9 * MediaQuery.of(context).size.width,
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Email'),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter email';
                          }

                          setState(() {
                            this.username = value;
                          });

                          return null;
                        },
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Password',
                          suffixIcon: IconButton(
                            icon: Icon(
                              // Based on passwordVisible state choose the icon
                              this.isObscureText
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Theme.of(context).primaryColorDark,
                            ),
                            onPressed: () {
                              // Update the state i.e. toogle the state of passwordVisible variable
                              setState(() {
                                this.isObscureText = !this.isObscureText;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter password';
                          }

                          setState(() {
                            this.password = value;
                          });

                          return null;
                        },
                        obscureText: this.isObscureText,
                      ),
                      RaisedButton(
                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            _handleSignIn().then((FirebaseUser user) {
                              Navigator.pushReplacementNamed(
                                  context, '/items-add');
                            }).catchError((e) => print(e));
                          }
                        },
                        child: Text('Login'),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ), //
        ),// This trailing comma makes auto-formatting nicer for build methods.
      ),
    );
  }

  Future<FirebaseUser> _handleSignIn() async {
    await firebaseAuth
        .signInWithEmailAndPassword(
            email: this.username, password: this.password)
        .catchError((e) {
      print(e);
    });

    return firebaseAuth.currentUser();
  }
}
