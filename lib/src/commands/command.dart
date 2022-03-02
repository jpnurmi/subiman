import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:collection/collection.dart';
import 'package:package_config/package_config.dart';

import '../app.dart';

abstract class SubiCommand extends Command<void> {
  SubiCommand({bool? hasVerbose}) {
    if (hasVerbose == true) {
      argParser.addFlag('verbose', abbr: 'v', help: 'Verbose output.');
    }
  }

  String get command => '$kAppName $name';

  bool get isVerbose {
    try {
      return argResults?['verbose'] == true;
    } on ArgumentError catch (_) {
      return false;
    }
  }

  Future<void> runSubi(String path);

  @override
  Future<void> run() async {
    try {
      final path = await findPackage('subiquity_client', verbose: isVerbose);
      await runSubi(path);
    } on DependencyException catch (e) {
      print(
        'ERROR: ${e.message}. Run `$command` within any Flutter or Dart project that has a (transitive) dependency on `subiquity_client`.',
      );
    } on UsageException catch (e) {
      print('ERROR: ${e.message}.\n');
      printUsage();
    }
  }
}

class DependencyException implements Exception {
  DependencyException(this.message);

  final String message;

  @override
  String toString() => message;
}

Future<String> findPackage(String name, {bool verbose = false}) async {
  final config = await findPackageConfig(Directory.current);
  if (config == null) {
    throw DependencyException('`pubspec.yaml` was not found');
  }

  final package = config.packages.firstWhereOrNull((p) => p.name == name);
  if (package == null) {
    throw DependencyException('Missing `$name` dependency');
  }

  if (verbose) {
    print('Found $name in ${package.root.path}');
  }
  return package.root.path;
}
