import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

import '../../../core/database/database_service.dart';
import '../../../core/settings/exchange_directory_service.dart';


class LocalExchangeServer {
  LocalExchangeServer._();

  static final LocalExchangeServer instance = LocalExchangeServer._();

  static const int defaultPort = 8790;

  final ExchangeDirectoryService _exchangeDirectoryService =
  ExchangeDirectoryService();

  HttpServer? _server;

  bool get isRunning => _server != null;

  int? get port => _server?.port;

  Future<void> start({
    int port = defaultPort,
  }) async {
    if (_server != null) return;

    final router = Router();

    router.get('/ping', (Request request) {
      return Response.ok(
        jsonEncode({
          'status': 'ok',
          'app': 'ABAK Desktop Companion',
          'service': 'local_exchange',
          'port': port,
          'timestamp': DateTime.now().toIso8601String(),
        }),
        headers: {
          HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
        },
      );
    });

    router.get('/patients/search', (Request request) async {
      final query = request.url.queryParameters['q']?.trim() ?? '';

      if (query.length < 2) {
        return Response.ok(
          jsonEncode([]),
          headers: {
            HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
          },
        );
      }

      final db = await DatabaseService.database;

      final likeQuery = '%$query%';

      final rows = await db.query(
        'patients',
        columns: [
          'last_name',
          'first_name',
          'birth_date',
          'sex_code',
        ],
        where: '''
          archived_at IS NULL
          AND (
            last_name LIKE ?
            OR first_name LIKE ?
            OR birth_date LIKE ?
          )
        ''',
        whereArgs: [
          likeQuery,
          likeQuery,
          likeQuery,
        ],
        orderBy: 'last_name ASC, first_name ASC',
        limit: 20,
      );

      final results = rows.map((row) {
        final lastName = (row['last_name'] ?? '').toString();
        final firstName = (row['first_name'] ?? '').toString();
        final birthDate = (row['birth_date'] ?? '').toString();
        final sexCode = (row['sex_code'] ?? 'U').toString();

        return {
          'displayName': _buildPatientDisplayName(
            lastName: lastName,
            firstName: firstName,
            birthDate: birthDate,
          ),
          'lastName': lastName,
          'firstName': firstName,
          'birthDate': birthDate,
          'sexCode': sexCode,
        };
      }).toList();

      return Response.ok(
        jsonEncode(results),
        headers: {
          HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
        },
      );
    });

    router.post('/upload', (Request request) async {
      final contentType = request.headers[HttpHeaders.contentTypeHeader];

      final fileName = request.url.queryParameters['filename'] ??
          'incoming_${DateTime.now().millisecondsSinceEpoch}.abak';

      if (!fileName.toLowerCase().endsWith('.abak')) {
        return Response(
          HttpStatus.badRequest,
          body: jsonEncode({
            'status': 'error',
            'message': 'Seuls les fichiers .abak sont acceptés.',
          }),
          headers: {
            HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
          },
        );
      }

      final exchangeDir =
      await _exchangeDirectoryService.getExchangeDirectory();

      if (!await exchangeDir.exists()) {
        await exchangeDir.create(recursive: true);
      }

      final safeFileName = p.basename(fileName);
      final uniqueFileName = _uniqueFileName(exchangeDir, safeFileName);

      final destinationPath = p.join(
        exchangeDir.path,
        uniqueFileName,
      );

      final bytes = await request.read().fold<List<int>>(
        <int>[],
            (previous, element) => previous..addAll(element),
      );

      final file = File(destinationPath);
      await file.writeAsBytes(bytes, flush: true);

      //final importResult  =
      //await AbakImportLauncher.importArchiveFromPath(
      //  destinationPath,
      //  sourceLabel: 'local_exchange',
      //);

      return Response.ok(
        jsonEncode({
          'status': 'ok',
          'message': 'Fichier .abak reçu dans le dossier d’échange.',
          'fileName': uniqueFileName,
          'filePath': destinationPath,
          'size': bytes.length,
          'contentType': contentType,
          'timestamp': DateTime.now().toIso8601String(),
        }),
        headers: {
          HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
        },
      );
    });

    final handler = Pipeline()
        .addMiddleware(logRequests())
        .addHandler(router.call);

    _server = await shelf_io.serve(
      handler,
      InternetAddress.anyIPv4,
      port,
    );
  }

  Future<void> stop() async {
    final server = _server;

    if (server == null) return;

    await server.close(force: true);
    _server = null;
  }

  String _uniqueFileName(Directory directory, String fileName) {
    final baseName = p.basenameWithoutExtension(fileName);
    final extension = p.extension(fileName);

    var candidate = fileName;
    var index = 1;

    while (File(p.join(directory.path, candidate)).existsSync()) {
      candidate = '${baseName}_$index$extension';
      index++;
    }

    return candidate;
  }
}

String _buildPatientDisplayName({
  required String lastName,
  required String firstName,
  required String birthDate,
}) {
  final name = [
    lastName.trim(),
    firstName.trim(),
  ].where((part) => part.isNotEmpty).join(' ');

  if (birthDate.trim().isEmpty) {
    return name;
  }

  return '$name ($birthDate)';
}