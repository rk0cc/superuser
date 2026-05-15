# Superuser detection for Dart CLI or Flutter desktop application

Superuser is a special user, who granted as much as possible to access system files for maintenance purpose. Different systems has different names to refer superuser (e.g. `root` in various UNIX system and `Administrator` in Windows). 

Although `pub.dev` has numerous of packages to detect superuser, they are designed for Flutter app for Android and some packages added iOS support already. Hence, these package may become bulky because of unnessary callbacks along with detection only.

Instead, `superuser` package offers superuser detection in Dart CLI or Flutter desktop and two replicated identification command from UNIX (`whoami` and `group`) for additional verification if necessary.

## Limitations

This package only tested using informations given on **local machines** only. Although it can run in domain joined machine since `4.0.0`, only local scope can be extracted that any entities related with Activity Directory or LDAP are omitted.

For UNIX (or POSIX for more accuracely), Since `/etc/sudoers` only accessible via `visudo` only that it minimize chance of malfunction due to misconfiguration, but forbidden of read access makes impossible to programmically determine the executor is in corresponded group that it is granted to elevate.
Therefore, except the program is invoked by `root` itself, condition of classifying user has admin right is determined by inspecting a group, which related to `sudo` commands in **DEFAULT** setting:

|Group name|Applied UNIX based platform (and distro)|
|:---:|:---|
|`sudo`|Linux in Debian-based (i.e. Debian, Ubuntu)|
|`admin`|Darwin (macOS&ast;)|
|`wheel`|Default group for most UNIX platforms (i.e. FreeBSD, Fedora, OpenSUSE, etc...)|

<sup>&ast;&colon; Although <code>wheel</code> group still exists because of inheritance of FreeBSD, most users created with admin right from macOS setting <b>ONLY</b> assigned <code>admin</code> group only.</sup>

If any non-default groups can invoke `sudo` due to modification of `/etc/sudoers` file, inspecting `Superuser.groups` is the most preferred workaround solution:

```dart
const Set<String> additionalSudoGpNames = <String>{
    "circle",
    "ring"
};

bool get isAdditionalAdminGroups =>
    additionalSudoGpNames.any(Superuser.groups.containsByString);
```

## Implementations

### Production

`lld` must be installed in the Linux already before build:

```bash
# Debian based
sudo apt install lld

# Fedora based
sudo dnf install lld
```

### Testing or simulating with mock interface

For testing, `MockSuperuser` must be binded already before performing widget test:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:superuser/instance.dart';
import 'package:superuser/mock.dart';

void main() {
    setUpAll(() {
        // Bind mock instance here
        SuperuserInstance.bindInstance(
            MockSuperuser(whoAmI: "reonaw"),
        );
    });
    // Do any testes below
}
```

If using for debug simulation, mock interface must be binded before `runApp`:

```dart
import 'package:flutter/widgets.dart';
import 'package:superuser/instance.dart';
import 'package:superuser/mock.dart';

void main() {
    SuperuserInstance.bindInstance(
        MockSuperuser(
            whoAmI: "hiderik",
            isSuperuser: true,
            isActivated: true,
        ),
    );

    runApp(const YourApp());
}
```

To alter string detection staregy, it is possible to achieve by applying `matchingFlag`:

```dart
import 'package:flutter/widgets.dart';
import 'package:superuser/instance.dart';
import 'package:superuser/mock.dart';

void main() {
    // Either `yuunagit` or `YUUNAGIT` can be matched by using `OSString.<=` operation in `whoami`.
    SuperuserInstance.bindInstance(
        MockSuperuser(
            whoAmI: "yuunagit",
            matchingFlag: OSString.MATCH_CAPITAL,
        ),
    );

    runApp(const YourApp());
}
```

Value of `matchingFlag` has been mentioned in [OSString's constructor method](https://pub.dev/documentation/superuser_interfaces/latest/interfaces/OSString/OSString.html) already.

## Demo

Demo application of `superuser` has been available in [release page](https://github.com/rk0cc/superuser/releases) in Windows and Linux application.

These demo animations are for reference only, conditions and contents may be differ without notice.

### Open without superuser right

![Open demo application oridinary](https://github.com/user-attachments/assets/5b973019-c6d6-4466-9f60-01c86b06c1c8)

### Open with superuser right

![Open demo application with superuser right](https://github.com/user-attachments/assets/9df848b1-b7ff-4568-b961-347ec42cbbd6)

## License

BSD-3
