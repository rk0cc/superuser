import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';

Future<bool> get isDebian async =>
    Platform.isLinux && await File("/etc/debian_version").exists();

void main(List<String> args) async {
  await build(args, (input, output) async {
    if (!input.config.buildCodeAssets ||
        !(Platform.isLinux || Platform.isMacOS)) {
      return;
    }

    final CodeConfig(:targetOS, :targetArchitecture) = input.config.code;

    final builder = CBuilder.library(
      name: "superuser_plugin_${targetOS}_$targetArchitecture",
      assetName: "src/unix_superuser.g.dart",
      sources: const <String>["src/superuser_plugin_unix.c"],
      defines: <String, String?>{
        if (await isDebian) "DEFAULT_UNIX_SUDO_GP": "\"sudo\"",
      },
      std: "c17",
    );

    await builder.run(input: input, output: output);
  });
}
