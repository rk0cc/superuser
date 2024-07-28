import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:superuser/superuser.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

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
    return MaterialApp(title: _appTitle, home: const Context());
  }
}

class Context extends StatelessWidget {
  static const TextStyle _titleStyle =
      TextStyle(fontSize: 24, fontWeight: FontWeight.w400);

  static const TextStyle _valueStyle =
      TextStyle(fontSize: 18, fontWeight: FontWeight.w500);

  const Context({super.key});

  void _launchWebsite(Uri url) async {
    if (await url_launcher.canLaunchUrl(url)) {
      await url_launcher.launchUrl(url,
          mode: url_launcher.LaunchMode.externalApplication);
    }
  }

  List<Color> _getStatusGradients(bool enabled) {
    Iterable<Color> gradientsGenerator(int transCounts) sync* {
      assert(transCounts > 0);

      for (int c = 0; c < transCounts; c++) {
        yield Colors.transparent;
      }

      yield (enabled ? Colors.greenAccent[400] : Colors.redAccent[400])!;
    }

    return gradientsGenerator(2).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    void onDisplayingGroups() async {
      await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            List<String> gpList = Superuser.groups.toList(growable: false);

            return AlertDialog(
                title: const Text("Groups"),
                content:
                    Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                  Text("Total joined groups: ${gpList.length}"),
                  SizedBox(
                      width: 400,
                      height: 275,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: gpList.length,
                          itemBuilder: (context, index) =>
                              ListTile(title: Text(gpList[index]))))
                ]), actions: <TextButton>[
                  TextButton(onPressed: () {
                    Navigator.pop(context);
                  }, child: const Text("OK"))
                ],);
          });
    }

    return Scaffold(
        appBar: AppBar(title: const Text("Superuser")),
        drawer: Drawer(
            child: ListView(children: <Widget>[
          DrawerHeader(
              decoration:
                  BoxDecoration(color: Theme.of(context).secondaryHeaderColor),
              child: Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () {
                            Navigator.pop<void>(context);
                          })))),
          ListTile(
              leading: const Icon(FontAwesomeIcons.github, color: Colors.black),
              title: const Text("GitHub repository"),
              onTap: () {
                _launchWebsite(Uri.https("github.com", "/rk0cc/superuser"));
              }),
          ListTile(
              leading: const FlutterLogo(style: FlutterLogoStyle.markOnly),
              title: const Text("pub.dev"),
              onTap: () {
                _launchWebsite(Uri.https("pub.dev", "/packages/superuser"));
              }),
          const Padding(
              padding: EdgeInsets.symmetric(vertical: 4), child: Divider()),
          ListTile(
              leading:
                  Icon(FontAwesomeIcons.dollarSign, color: Colors.amber[400]),
              title: const Text("Donate"),
              onTap: () {
                _launchWebsite(Uri.https("github.com", "/sponsors/rk0cc"));
              })
        ])),
        body: ListView(
            padding: const EdgeInsets.only(top: 8, left: 18, right: 18),
            shrinkWrap: true,
            children: <Widget>[
              ListTile(
                  title: const Text("Username", style: _titleStyle),
                  trailing: Text(Superuser.whoAmI, style: _valueStyle)),
              const Divider(),
              Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: _getStatusGradients(Superuser.isSuperuser))),
                  child: ListTile(
                      title:
                          const Text("Has superuser role", style: _titleStyle),
                      trailing: Text(Superuser.isSuperuser ? "Yes" : "No",
                          style: _valueStyle))),
              const Divider(),
              Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: _getStatusGradients(Superuser.isActivated))),
                  child: ListTile(
                      title: const Text("Run as superuser", style: _titleStyle),
                      trailing: Text(Superuser.isActivated ? "Yes" : "No",
                          style: _valueStyle))),
              const Divider(),
              ListTile(
                  title: const Text("Group"),
                  trailing: ElevatedButton(
                      onPressed: onDisplayingGroups,
                      child: const Text("List all joined groups")))
            ]));
  }
}
