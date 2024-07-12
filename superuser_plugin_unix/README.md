# Superuser detection for UNIX system.

UNIX's C API implementation of detecting superuser.

## Conditions

<table>
  <tr>
    <th><p align="center">Property name in <code>SuperuserInterface</code></p></th>
    <th><p align="center">Conditions of returning <code>true</code></p></th>
  </tr>
  <tr>
    <td><p align="center"><code>isSuperuser</code></p></td>
    <td rowspan="2">Run the program using `root` identity (e.g. call with <code>sudo</code>)</td>
  </tr>
  <tr>
    <td><p align="center"><code>isActivated</code></p></td>
  </tr>
</table>

### License

BSD-3