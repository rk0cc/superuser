# Superuser detection for UNIX system.

UNIX's C API implementation of detecting superuser.

## Conditions

|Property name in `SuperuserInterface`|<p align="center">Conditions of returning `true`</p>|
|:---:|:---|
|`isSuperuser`|A program is executed by a user who is `root` or a group member that can call `sudo` command|
|`isActivated`|A program is executed under `root` identity|


### License

BSD-3