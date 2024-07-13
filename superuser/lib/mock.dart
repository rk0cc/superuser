/// Replicate [SuperuserInterface] to emulate superuser condition in controllable
/// values when performing debugs or testing.
library mock;

import 'package:superuser_interfaces/superuser_interfaces.dart'
    show SuperuserInterface;

export 'package:superuser_interfaces/superuser_interfaces.dart'
    show MockSuperuser;
