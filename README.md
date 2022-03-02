# Subiquity Manager

Manage [Subiquity](https://github.com/canonical/subiquity) for
[Ubuntu Desktop Installer](https://github.com/canonical/ubuntu-desktop-installer)

```
Usage: subiman <command> [arguments]

Global options:
-h, --help    Print this usage information.

Available commands:
  dry-run   Dry-run Subiquity server
  http      Send HTTP request to Subiquity
  status    Subiquity submodule status
  update    Update Subiquity submodule

Run "subiman help <command>" for more information about a command.
```

# Installation
```sh
$ dart pub global activate --source git https://github.com/jpnurmi/subiman.git
Resolving dependencies...
[...]
Building package executables...
Built subiman:subiman.
Installed executable subiman.
Warning: Pub installs executables into $HOME/.pub-cache/bin, which is not on your path.
You can fix that by adding this to your shell's config file (.bashrc, .bash_profile, etc.):

  export PATH="$PATH":"$HOME/.pub-cache/bin"

Activated subiman 0.1.0 from Git repository "https://github.com/jpnurmi/subiman.git".
```

Notice the instructions above if you wish to have the `subiman` executable
conveniently available in `PATH`. Alternatively, you can run `dart run subiman`.

# Getting started

Run `subiman` within any Flutter or Dart project that has a (transitive)
dependency on `subiquity_client`.

```yaml
# pubspec.yaml
name: ubuntu_flavor_installer

dependencies:
  ubuntu_desktop_installer:
    git:
      url: https://github.com/canonical/ubuntu-desktop-installer.git
      path: packages/ubuntu_desktop_installer
      ref: bdf041ab8184f2c82015abb2da48283dfc614fc6
```

# Subiquity submodule

`subiman info` prints the location and status of the `subiquity_client/subiquity`
submodule. Typically, the submodule would be in `~/.pub-cache` where Dart fetches
package dependencies.

Initial uninitialized status:
```sh
$ subiman info
<path/to>/subiquity_client/subiquity
-90a2bd6f7a754964f1f35028ebf97aa305b29de5 subiquity
```

`subiman update` initializes the `subiquity_client/subiquity` submodule:
```sh
$ subiman update
<path/to>/subiquity_client/subiquity
Submodule path 'subiquity': checked out '90a2bd6f7a754964f1f35028ebf97aa305b29de5'
```

Current up-to-date status:
```sh
$ subiman info
<path/to>/subiquity_client/subiquity
 90a2bd6f7a754964f1f35028ebf97aa305b29de5 subiquity
```

Outdated status after updating the (transitive) `subiquity_client` dependency:
```sh
$ subiman info
<path/to>/subiquity_client/subiquity
+34b621ee6627f85b44317f415b0d78dab9553cc5 subiquity (21.12.2-98-g34b621ee)
* subiquity 90a2bd6f...34b621ee (3):
  < Merge pull request #1173 from dbungert/os-prober-arch
  < Merge pull request #1167 from dbungert/lp-1952603-nonet
  < Merge pull request #1171 from ogayot/bump-curtin-version
```

```sh
$ subiman update
<path/to>/subiquity_client/subiquity
Submodule path 'subiquity': checked out '90a2bd6f7a754964f1f35028ebf97aa305b29de5'
```

# Testing Subiquity

## Sending requests

### Status
```sh
$ subiman http /meta/status
{"state": "WAITING", "confirming_tty": "", "error": null, "cloud_init_ok": true, "interactive": true, "echo_syslog_id": "subiquity_echo.472110", "log_syslog_id": "subiquity_log.472110", "event_syslog_id": "subiquity_event.472110"}
```

### Locale
```sh
$ subiman http /locale
"en_US.UTF-8"
$ subiman http -X POST /locale \"fi_FI.UTF-8\"
null
$ subiman http /locale
"fi_FI.UTF-8"
```

### Timezone
```sh
$ subiman http /timezone
{"timezone": "Europe/Stockholm", "from_geoip": true}
$ subiman http -X POST /timezone?tz=\"Europe/Helsinki\"
null
$ subiman http /timezone
{"timezone": "Europe/Helsinki", "from_geoip": false}
```

## Dry-running

Sometimes it may be useful for testing purposes to manually run the Subiquity
server in dry-run mode:
```sh
$ subiman dry-run --socket /path/to/subiquity.sock
```
