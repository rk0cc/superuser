import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';

const win32Libs = [
  "kernel32",
  "netapi32",
  "Advapi32",
  "ntdll",
  "rpcrt4",
  "iphlpapi",
  "ws2_32",
  "msvcrt",
];

Iterable<CodeAsset> getWindowsAPIAssets(BuildInput input) sync* {
  for (final libName in win32Libs) {
    yield CodeAsset(
      package: input.packageName,
      name: libName,
      linkMode: DynamicLoadingSystem(.file("${libName.toLowerCase()}.dll")),
    );
  }
}

void main(List<String> args) async {
  await build(args, (input, output) async {
    if (!input.config.buildCodeAssets || !Platform.isWindows) {
      return;
    }

    final CodeConfig(:targetArchitecture) = input.config.code;

    output.assets.code.addAll(getWindowsAPIAssets(input));

    final builder = CBuilder.library(
      name: "superuser_plugin_windows_$targetArchitecture",
      assetName: "src/win_superuser.g.dart",
      sources: const <String>["src/superuser_plugin_windows.c"],
      libraries: win32Libs,
    );

    await builder.run(input: input, output: output);
  });
}
