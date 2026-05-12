import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';

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
      std: "c17",
      flags: ["/nologo", "Advapi32.lib"],
    );

    await builder.run(input: input, output: output);
  });
}
