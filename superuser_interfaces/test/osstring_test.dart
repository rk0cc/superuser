@TestOn("vm && (windows || mac-os || linux)")
library;

import 'dart:io';

import 'package:superuser_interfaces/superuser_interfaces.dart'
    hide SuperuserPlatform;
import 'package:test/test.dart';

void main() {
  group("Default constructor test", () {
    late final OSString str;

    setUpAll(() {
      str = OSString("Luluka");
    });

    test("Windows", () {
      expect(str <= "LULUKA", isTrue);
      expect(str <= "Luluka", isTrue);
      expect(str <= "luluka", isFalse);
      expect(str.toCaseAppliedString(), equals("LULUKA"));
    }, skip: !Platform.isWindows);

    test("Unix", () {
      expect(str <= "LULUKA", isFalse);
      expect(str <= "Luluka", isTrue);
      expect(str <= "luluka", isFalse);
      expect(str.toCaseAppliedString(), equals("Luluka"));
    }, skip: Platform.isWindows);
  });

  group("Set behaviour", () {
    test("add element then look up by string", () {
      final OSStringsSet mujica = OSStringsSet();
      final OSString timoris = OSString.caseSensitive("timoris");

      expect(mujica.add(OSString.allCapital("Mortis")), isTrue);
      expect(mujica.add(timoris), isFalse);
      expect(mujica.lookupByString("MORTIS"), isNotNull);
      expect(mujica.lookupByString("Mortis"), isNotNull);
      expect(mujica.lookupByString("mortis"), isNull);
      expect(mujica.lookupByString("timoris"), isNull);
      expect(mujica.add(OSString("doloris", OSString.MATCH_CAPITAL)), isTrue);
      expect(mujica, hasLength(2));
      expect(
        mujica.map((str) => str.toCaseAppliedString()),
        containsAll(["MORTIS", "DOLORIS"]),
      );

      mujica.clear();

      expect(mujica.add(timoris), isTrue);
      expect(mujica.add(OSString.allSmall("amoriS")), isFalse);
      expect(
        mujica.add(
          OSString("oblivionis", OSString.MATCH_CAPITAL | OSString.MATCH_SMALL),
        ),
        isTrue,
      );
      expect(mujica.containsByString("Oblivionis"), isFalse);
      expect(mujica.containsByString("oblivionis"), isTrue);
      expect(mujica.containsByString("amoris"), isFalse);
      expect(
        mujica.map((str) => str.toCaseAppliedString()),
        allOf(hasLength(2), containsAll(["timoris", "oblivionis"])),
      );
    });

    group("batch adding policy", () {
      test("from new instance", () {
        const List<String> memberNames = [
          "rikki",
          "anon",
          "tomorin",
          "soyorin",
        ];
        final OSStringsSet mygo = OSStringsSet.of([
          OSString.allSmall("Rikki"),
          OSString.caseSensitive("raana"),
          OSString("Anon", OSString.MATCH_SMALL),
          OSString.allSmall("Tomorin"),
          OSString("Soyorin", OSString.MATCH_SMALL),
        ]);

        expect(mygo.length, equals(4));
        expect(
          mygo.map((str) => str.toCaseAppliedString()),
          orderedEquals(memberNames),
        );
        expect(
          [
            ...memberNames,
            "Rikki",
            "Anon",
            "Tomorin",
            "Soyorin",
          ].map(mygo.lookupByString),
          allOf(everyElement(isNotNull), hasLength(8)),
        );
      });

      test("from existed object", () {
        final OSStringsSet crychic = OSStringsSet.fromStrings([
          "tomori",
          "soyo",
          "taki",
        ], OSString.MATCH_CAPITAL);
        // Assertion
        expect(crychic, hasLength(3));

        crychic.addAll([
          OSString.allCapital("sakiko"),
          OSString.allCapital("mutsumi"),
          OSString.caseSensitive("mana"),
        ]);

        expect(crychic, hasLength(5));
        expect(crychic.containsByString("mana"), isFalse);
        expect(crychic.removeByString("SAKIKO"), isTrue);
        expect(
          crychic.map((str) => str.toCaseAppliedString()),
          allOf(hasLength(4), isNot(contains("SAKIKO")), contains("MUTSUMI")),
        );
      });
    });
  });
}
