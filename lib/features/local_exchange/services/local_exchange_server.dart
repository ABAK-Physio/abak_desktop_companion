import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../../import_export/abak_import_launcher.dart';
import '../../../core/database/database_service.dart';

class LocalExchangeServer {
  LocalExchangeServer._();

  static final LocalExchangeServer instance =
  LocalExchangeServer._();

  static const int defaultPort = 8790;

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

      final appSupportDir = await getApplicationSupportDirectory();

      final incomingDir = Directory(
        p.join(appSupportDir.path, 'incoming_abak'),
      );

      if (!await incomingDir.exists()) {
        await incomingDir.create(recursive: true);
      }

      final safeFileName = p.basename(fileName);

      final destinationPath = p.join(
        incomingDir.path,
        safeFileName,
      );

      final bytes = await request.read().fold<List<int>>(
        <int>[],
            (previous, element) => previous..addAll(element),
      );

      final file = File(destinationPath);
      await file.writeAsBytes(bytes, flush: true);
      final importResult =
      await AbakImportLauncher.importArchiveFromPath(destinationPath);

      return Response.ok(
        jsonEncode({
          'status': importResult['status'],
          'message': importResult['message'],
          'fileName': safeFileName,
          'filePath': destinationPath,
          'size': bytes.length,
          'contentType': contentType,
          'import': importResult,
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