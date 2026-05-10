import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';

const win32Libs = ["netapi32", "Advapi32"];

void main(List<String> args) async {
  await build(args, (input, output) async {
    if (!input.config.buildCodeAssets || !Platform.isWindows) {
      return;
    }

    final CodeConfig(:targetArchitecture) = input.config.code;

    final builder = CBuilder.library(
      name: "superuser_plugin_windows_$targetArchitecture",
      assetName: "src/win_superuser.g.dart",
      sources: const <String>["src/superuser_plugin_windows.c"],
      libraries: win32Libs,
      flags: ["/std:c17", "/nologo"],
    );

    await builder.run(input: input, output: output);
  });
}
