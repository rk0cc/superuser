import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:superuser/superuser.dart';

import 'style.dart';

void main() {
  runApp(ChangeNotifierProvider(
      create: (context) => ThemePreference(), child: const App()));
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemePreference pref = context.watch<ThemePreference>();

    return MaterialApp(
        title: "Superuser demo", themeMode: pref.mode, home: const Context());
  }
}

class Context extends StatelessWidget {
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
          ListTile(
              leading: const Icon(Icons.palette),
              title: const Text("Theme mode"),
              onTap: () async {
                ThemeMode? newThemeMode = await showDialog<ThemeMode>(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const ThemeModeDialog());

                if (context.mounted && newThemeMode != null) {
                  context.watch<ThemePreference>().mode = newThemeMode;
                }
              })
        ])),
        body: ListView(
            padding: const EdgeInsets.only(top: 8, left: 18, right: 18),
            shrinkWrap: true,
            children: <Widget>[
              ListTile(
                  title: const Text("Username"),
                  trailing: Text(Superuser.whoAmI)),
              ListTile(
                  title: const Text("Has superuser role"),
                  trailing: Text(Superuser.isSuperuser ? "Yes" : "No")),
              ListTile(
                  title: const Text("Run as superuser"),
                  trailing: Text(Superuser.isActivated ? "Yes" : "No"))
            ]));
  }
}

