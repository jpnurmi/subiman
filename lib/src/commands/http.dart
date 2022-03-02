import 'dart:io';

import 'package:collection/collection.dart';
import 'package:http/http.dart';
import 'package:path/path.dart' as p;

import '../app.dart';
import '../http_unix_client.dart';
import 'command.dart';

class HttpCommand extends SubiCommand {
  HttpCommand() : super() {
    argParser.addOption(
      'request',
      abbr: 'X',
      help: 'Request method',
      valueHelp: 'method',
      defaultsTo: 'GET',
    );
    argParser.addOption(
      'socket',
      abbr: 's',
      help: 'Socket path',
      valueHelp: 'path',
    );
  }

  @override
  String get name => 'http';

  @override
  String get description => '''
Send HTTP request to Subiquity

GET:
  $command /meta/status
  $command -X GET /locale

POST:
  $command -X POST locale \\"en_UK.UTF-8\\"
  $command -X POST timezone?tz=\\"Europe/London\\"''';

  @override
  String get invocation => '${super.invocation} <URI> [data]';

  @override
  Future<void> runSubi(String path) async {
    if (argResults!.rest.isEmpty) {
      // print('ERROR: Missing URI argument');
      // printUsage();
      // return;
      usageException('Missing URI argument');
    }
    final uri = Uri.tryParse(argResults!.rest.firstOrNull ?? '');
    if (uri == null) {
      usageException('Invalid URI argument "$uri"');
    }

    final method = (argResults!['request'] as String).toUpperCase();
    final request = Request(method, Uri.http('localhost', '/').resolveUri(uri));
    request.body = argResults!.rest.skip(1).join(' ');

    final socket = resolveSocket(
      argResults!['socket'] as String? ??
          p.join(path, 'subiquity', '.subiquity', 'socket'),
    );
    try {
      await sendRequest(socket, request);
    } on SocketException catch (e) {
      print('ERROR: ${e.message} (${e.osError})');
    }
  }
}

String resolveSocket(String path, {bool verbose = false}) {
  if (path.length > 107) {
    // Use a relative path to avoid hitting AF_UNIX path length limit because
    // <path/to/ubuntu-desktop-installer>/packages/subiquity_client/subiquity/.subiquity/socket>
    // grows easily to more than 108-1 characters (char sockaddr_un::sun_path[108]).
    if (verbose) {
      print('Symlink /tmp/$kAppName.$pid.sock -> $path');
    }
    return createSymlink('/tmp/$kAppName.$pid.sock', path);
  } else if (verbose) {
    print('Open $path');
  }
  return path;
}

String createSymlink(String source, String target) {
  final symlink = Link(source);
  if (symlink.existsSync()) {
    symlink.deleteSync();
  }
  symlink.createSync(target);
  return source;
}

Future<void> sendRequest(String socket, Request request) async {
  final client = HttpUnixClient(socket);
  final response = await client.send(request);
  final body = await response.stream.bytesToString();
  if (response.statusCode != 200) {
    print('ERROR: $body');
  } else {
    print(body);
  }
  client.close();
}
