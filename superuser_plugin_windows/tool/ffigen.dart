import 'dart:io';

import 'package:ffigen/ffigen.dart';

void main(List<String> args) {
  final pkgRoot = Platform.script.resolve("../");
  final headers = [pkgRoot.resolve("src/superuser_plugin_windows.h")];
  const nativeFuncNames = <String>{
    "is_admin_user",
    "is_elevated",
    "get_current_username",
    "count_associated_groups_length",
    "get_associated_groups",
  };
  const macroNames = <String>{"MAX_USERNAME_CHAR", "WIN32API_FUNC_WLEN"};
  const typedefNames = <String>{"ERRCODE", "SUPERUSER_ERRORINFO"};

  FfiGenerator(
    output: Output(dartFile: pkgRoot.resolve("lib/src/win_superuser.g.dart")),
    headers: Headers(entryPoints: headers),
    functions: Functions.includeSet(nativeFuncNames),
    macros: Macros(
      include: (declaration) => macroNames.contains(declaration.originalName),
    ),
    typedefs: Typedefs.includeSet(typedefNames),
  ).generate();
}
