import 'package:flutter/material.dart';
import 'package:superuser/superuser.dart';

void main() {
  runApp(const App());
}

String get _appTitle {
  String baseTitle = "Superuser demo";

  if (Superuser.isActivated) {
    baseTitle += " (run as superuser)";
  }

  return baseTitle;
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: _appTitle, home: const Context());
  }
}

class Context extends StatelessWidget {
  static const TextStyle _titleStyle =
      TextStyle(fontSize: 24, fontWeight: FontWeight.w400);

  static const TextStyle _valueStyle =
      TextStyle(fontSize: 18, fontWeight: FontWeight.w500);

  const Context({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Superuser")),
        drawer: Drawer(
            child: ListView(children: <Widget>[
          DrawerHeader(
              decoration:
                  BoxDecoration(color: Theme.of(context).secondaryHeaderColor),
              child: null),
          
        ])),
        body: ListView(
            padding: const EdgeInsets.only(top: 8, left: 18, right: 18),
            shrinkWrap: true,
            children: <Widget>[
              ListTile(
                  title: const Text("Username", style: _titleStyle),
                  trailing: Text(Superuser.whoAmI, style: _valueStyle)),
              ListTile(
                  title: const Text("Has superuser role", style: _titleStyle),
                  trailing: Text(Superuser.isSuperuser ? "Yes" : "No",
                      style: _valueStyle)),
              ListTile(
                  title: const Text("Run as superuser", style: _titleStyle),
                  trailing: Text(Superuser.isActivated ? "Yes" : "No",
                      style: _valueStyle))
            ]));
  }
}
