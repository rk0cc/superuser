# Superuser detection for Flutter desktop application

Superuser is a special user, who granted as much as possible to access system files for maintenance purpose. Different systems has different names to refer superuser (e.g. `root` in various UNIX system and `Administrator` in Windows). 

Although `pub.dev` has numerous of packages to detect superuser, they are designed for Android and some packages added iOS support already. Hence, these package may become bulky because of unnessary callbacks along with detection.

Instead, `superuser` package offers superuser detection in Flutter desktop as well as return username who opened an application.

## Implementations

### Production

No additional setup needed.

### Testing or simulating with mock interface

For testing, `MockSuperuser` must be binded already before performing widget test:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:superuser/instance.dart';
import 'package:superuser/mock.dart';

void main() {
    setUpAll(() {
        // Bind mock instance here
        SuperuserInstance.bindInstance(const MockSuperuser(whoAmI: "reonaw"));
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
    SuperuserInstance.bindInstance(const MockSuperuser(whoAmI: "hiderik", isSuperuser: true, isActivated: true));

    runApp(const YourApp());
}
```

## Demo

Demo application of `superuser` has been available in [release page](https://github.com/rk0cc/superuser/releases) in Windows and Linux application.

### Open without superuser right

![Open demo application oridinary](https://github.com/user-attachments/assets/5b973019-c6d6-4466-9f60-01c86b06c1c8)

### Open with superuser right

![Open demo application with superuser right](https://github.com/user-attachments/assets/9df848b1-b7ff-4568-b961-347ec42cbbd6)

## License

BSD-3
