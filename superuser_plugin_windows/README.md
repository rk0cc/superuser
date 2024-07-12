# Superuser detection for Windows

Win32 API implementation of detecting superuser.

## Conditions

|Property name in `SuperuserInterface`|<p align="center">Conditions of returning `true`</p>|
|:---:|:---|
|`isSuperuser`|A program is executed by a user who is a group member of **Administrators**|
|`isActivated`|A program invoked with "Run as administrator"|

### License

BSD-3
