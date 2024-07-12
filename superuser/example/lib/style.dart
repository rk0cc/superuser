import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ThemePreference extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.system;

  ThemePreference();

  set mode(ThemeMode newMode) {
    _mode = newMode;
    notifyListeners();
  }

  ThemeMode get mode => _mode;
}

extension ThemeModeDisplayNameExtension on ThemeMode {
  String get displayName => switch (this) {
        ThemeMode.system => "Same as system",
        ThemeMode.light ||
        ThemeMode.dark =>
          name[0].toUpperCase() + name.substring(1)
      };
}

class ThemeModeDialog extends StatefulWidget {
  const ThemeModeDialog({super.key});

  @override
  State<ThemeModeDialog> createState() => _ThemeModeDialogState();
}

class _ThemeModeDialogState extends State<ThemeModeDialog> {
  final TextEditingController _themeTxtCtrl = TextEditingController();
  late ThemeMode _selectedMode;

  @override
  void initState() {
    super.initState();

    _selectedMode = context.read<ThemePreference>().mode;
  }

  @override
  void dispose() {
    _themeTxtCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: const Text("Setting"),
        content: SizedBox(
            width: 450,
            child: ListView(shrinkWrap: true, children: <Widget>[
              DropdownMenu<ThemeMode>(
                width: 450,
                  dropdownMenuEntries: ThemeMode.values
                      .map((e) =>
                          DropdownMenuEntry(value: e, label: e.displayName))
                      .toList(growable: false),
                  initialSelection: _selectedMode,
                  onSelected: (newVal) {
                    if (newVal != null) {
                      setState(() {
                        _selectedMode = newVal;
                      });
                    }
                  })
            ])),
        actions: <TextButton>[
          TextButton(
              onPressed: () {
                Navigator.pop<ThemeMode>(context, _selectedMode);
              },
              child: const Text("Apply")),
          TextButton(
              onPressed: () {
                Navigator.pop<ThemeMode>(context);
              },
              child: const Text("Cancel"))
        ]);
  }
}
