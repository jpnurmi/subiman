import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import 'command.dart';

class InfoCommand extends SubiCommand {
  InfoCommand() : super(hasVerbose: true);

  @override
  String get name => 'info';

  @override
  String get description => 'Subiquity submodule info';

  @override
  Future<void> runSubi(String path) async {
    print(p.join(path, 'subiquity'));
    final git = Git(path);
    await git.submoduleStatus(recursive: true, verbose: isVerbose);
    await git.submoduleSummary(verbose: isVerbose);
  }
}

class UpdateCommand extends SubiCommand {
  UpdateCommand() : super(hasVerbose: true);

  @override
  String get name => 'update';

  @override
  String get description => 'Update Subiquity submodule';

  @override
  Future<void> runSubi(String path) async {
    print(p.join(path, 'subiquity'));
    final git = Git(path);
    await git.updateSubmodules(
      init: true,
      recursive: true,
      force: true,
      verbose: isVerbose,
    );
  }
}

class Git {
  Git(this.path);

  final String path;

  Future<void> submoduleStatus({bool recursive = false, bool verbose = false}) {
    return _runGit(
      [
        'submodule',
        'status',
        if (recursive) '--recursive',
      ],
      workingDirectory: path,
      verbose: verbose,
    );
  }

  Future<void> submoduleSummary({bool verbose = false}) {
    return _runGit(
      ['submodule', 'summary'],
      workingDirectory: path,
      verbose: verbose,
    );
  }

  Future<void> updateSubmodules({
    bool init = false,
    bool recursive = false,
    bool force = false,
    bool verbose = false,
  }) {
    return _runGit(
      [
        'submodule',
        'update',
        if (init) '--init',
        if (recursive) '--recursive',
        if (force) '--force'
      ],
      workingDirectory: path,
      verbose: verbose,
    );
  }

  Future<void> _runGit(
    List<String> args, {
    required String workingDirectory,
    bool verbose = false,
  }) async {
    if (verbose) {
      print('Run `git ${args.join(' ')}` in $workingDirectory');
    }
    try {
      final git = await Process.start(
        'git',
        args,
        workingDirectory: workingDirectory,
      );
      git.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(stdout.writeln);
      git.stderr
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(stderr.writeln);

      final exitCode = await git.exitCode;
      if (exitCode != 0) {
        exit(exitCode);
      }
    } on ProcessException catch (e) {
      print('ERROR: Unable to run git (${e.message})');
    }
  }
}
