import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';

void main(List<String> args) async {
  await build(args, (input, output) async {
    final CodeConfig(:targetOS) = input.config.code;

    final bool isUnixForDesktop = <OS>[
      OS.macOS,
      OS.linux,
    ].any((os) => targetOS == os);

    if (!input.config.buildCodeAssets || !isUnixForDesktop) {
      return;
    }

    final builder = CBuilder.library(
      name: "superuser_plugin",
      assetName: "src/unix_superuser.g.dart",
      sources: const <String>["src/superuser_plugin_unix.c"],
      std: "c17",
    );

    await builder.run(input: input, output: output);
  });
}
