import 'dart:async';
import 'dart:io';
import 'package:path/path.dart' as p;

import 'command.dart';

class InstallCommand extends SubiCommand {
  InstallCommand() : super(hasVerbose: true);

  @override
  String get name => 'install';

  @override
  String get description => '''Install Subiquity dependencies (sudo)''';

  @override
  Future<void> runSubi(String path) async {
    final script = p.join(path, 'subiquity', 'scripts', 'installdeps.sh');
    try {
      if (isVerbose) {
        print('Run `sudo $script`');
      }

      final process = await Process.start('sudo', [script]);
      unawaited(process.stdout.pipe(stdout));
      unawaited(process.stderr.pipe(stderr));

      exit(await process.exitCode);
    } on ProcessException catch (e) {
      print('ERROR: ${e.message}');
    }
  }
}
