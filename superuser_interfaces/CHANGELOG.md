## 4.1.0

* Enforce platform detection in interface library
* Fix incorrect year range of license
* Update description

## 4.0.0

* New type: `OSString` and `OSStringsSet`
    * These types are applied into `whoAmI` and `groups` getter to align character matching
      staregy in running platforms.
* Directly provide function name of native API when `SuperuserProcessError` is going to
  throw when errors occur in FFI.
* Cease Flutter dependencies
* Increase minimum Dart SDK to `3.10.0` for implementing FFI via hook.

## 3.0.0+1

* Fix repository link unreachable problem as the default branch renamed.

## 3.0.0

* Change Dart SDK constraint to `^3.8.0`

## 2.2.0

* Change Dart SDK constraint to `^3.6.0` for applying monorepo support.

## 2.1.0

* Add user groups getter.

## 2.0.0

* Mark `SuperuserInterface` final
* Add `SuperuserPlatform` for handling fetching properties.
* Add `SuperuserProcessError` to indicate error occured when fetching properties.

## 1.0.0

* Include features
    * User with superuser right
    * Execute under superuser
    * Obtain username
