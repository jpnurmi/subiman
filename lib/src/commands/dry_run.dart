import 'dart:async';
import 'dart:io';
import 'package:args/args.dart';
import 'package:path/path.dart' as p;

import 'command.dart';

class DryRunCommand extends SubiCommand {
  @override
  ArgParser get argParser => _argParser;
  final _argParser = ArgParser.allowAnything();

  @override
  String get name => 'dry-run';

  @override
  String get description => '''Dry-run Subiquity server''';

  @override
  Future<void> runSubi(String path) async {
    final cwd = p.join(path, 'subiquity');
    final args = List.of(argResults!.arguments);
    final isVerbose = args.remove('--verbose');
    try {
      args.insertAll(0, ['-m', 'subiquity.cmd.server', '--dry-run']);

      if (isVerbose) {
        print('Run `python3 ${args.join(' ')}` in $cwd');
      }

      final pythonPath = (Platform.environment['PYTHONPATH'] ?? '').split(':');
      pythonPath.add(cwd);
      pythonPath.add(p.join(cwd, 'curtin'));
      pythonPath.add(p.join(cwd, 'probert'));

      final python = await Process.start(
        'python3',
        args,
        workingDirectory: cwd,
        environment: {'PYTHONPATH': pythonPath.join(':')},
      );

      unawaited(python.stdout.pipe(stdout));
      unawaited(python.stderr.pipe(stderr));

      exit(await python.exitCode);
    } on ProcessException catch (e) {
      print('ERROR: Unable to run python3 (${e.message})');
    }
  }
}
