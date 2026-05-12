import 'dart:io';

import 'package:ffigen/ffigen.dart';

void main(List<String> args) {
  final pkgRoot = Platform.script.resolve("../");
  final headers = [pkgRoot.resolve("src/superuser_plugin_unix.h")];
  const nativeFuncNames = <String>{
    "get_uname",
    "get_current_user_group",
    "get_group_name_by_gid",
    "is_root",
    "is_sudo_group",
    "flush_group",
  };
  const macroNames = <String>{"MAX_UNIX_FUNCNAME_LEN"};
  const structNames = <String>{"_SUPERUSER_ERRINFO"};
  final typedefNames = <String>{
    "gid_t",
    "ERRCODE",
    ...structNames.map((s) => s.substring(1)),
  };

  FfiGenerator(
    output: Output(dartFile: pkgRoot.resolve("lib/src/unix_superuser.g.dart")),
    headers: Headers(entryPoints: headers),
    functions: Functions.includeSet(nativeFuncNames),
    macros: Macros(
      include: (declaration) => macroNames.contains(declaration.originalName),
    ),
    typedefs: Typedefs.includeSet(typedefNames),
    structs: Structs(
      include: (declaration) => structNames.contains(declaration.originalName),
    ),
  ).generate();
}
