# Subiquity Manager

Manage [Subiquity](https://github.com/canonical/subiquity) for
[Ubuntu Desktop Installer](https://github.com/canonical/ubuntu-desktop-installer)

```
Manage Subiquity for Ubuntu Desktop Installer

Usage: subiman <command> [arguments]

Global options:
-h, --help    Print this usage information.

Available commands:
  dry-run   Dry-run Subiquity server
  http      Send HTTP request to Subiquity
  install   Install Subiquity dependencies (sudo)

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
      ref: <sha1>
```

# Installing Subiquity dependencies

`subiman install` runs the `subiquity/scripts/installdeps.sh` script to install
all dependencies required by Subiquity. Running the script requires super user
privileges. You can pass `--verbose` to see the exact location of the script if
you prefer to run it manually.

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
