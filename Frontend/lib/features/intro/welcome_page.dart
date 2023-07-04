import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../screen.dart';
import '../../widgets/widget.dart';

class WelcomePage extends StatefulWidget {
  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  //final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.15,
                      child: Image.asset('assets/icon/ICON_UNILINK-03.png'),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    "Bem-vindo à nova plataforma UniHub!",
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: Text(
                      "A tornar as faculdades mais acessiveis...",
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 100,
              ),

              MyTextButton(
                  buttonName: 'Register',
                  onTap: () {
                    Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (context) => RegisterPage()));
                  },
                  bgColor: Theme.of(context).primaryColor,
                  textColor: Colors.white70,
                  height: 45),
              SizedBox(height: 20),
              // Provide some space between buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already a user?',
                    style: TextStyle(fontSize: 20),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                    child: Text(
                      'Log in',
                      style: TextStyle(fontSize: 20, color: Colors.blue),
                    ),
                  ),
                ],
              ),
              /*
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: MyTextButton(
                        bgColor: Theme.of(context).primaryColor,
                        buttonName: 'Register',
                        onTap: () {
                          Navigator.push(
                              context,
                              CupertinoPageRoute(
                                  builder: (context) => RegisterPage()));
                        },
                        textColor: Colors.black87,
                        height: 60,
                      ),
                    ),
                    Expanded(
                      child: MyTextButton(
                        bgColor: Colors.transparent,
                        buttonName: 'Login',
                        onTap: () {
                          Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) => LoginPage(),
                              ));
                        },
                        textColor: Colors.white,
                        height: 60,
                      ),
                    ),
                  ],
                ),
              ),*/
            ],
          ),
        ),
      ),
    );
  }
}
