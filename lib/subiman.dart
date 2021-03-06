import 'package:args/command_runner.dart';

import 'src/app.dart';
import 'src/commands/dry_run.dart';
import 'src/commands/http.dart';
import 'src/commands/install.dart';

class SubiquityManager {
  Future<void> run(Iterable<String> args) async {
    final runner = CommandRunner<void>(kAppName, kAppDescription);
    runner.addCommand(DryRunCommand());
    runner.addCommand(HttpCommand());
    runner.addCommand(InstallCommand());
    try {
      await runner.run(args);
    } on UsageException catch (e) {
      print('ERROR: ${e.message}\n');
      print(runner.usage);
    }
  }
}
