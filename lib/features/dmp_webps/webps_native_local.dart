import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

/// Local test bridge only: no caller-supplied host, URL, INS or CPS parameter.
class LocalBrowserControl extends ChangeNotifier {
  LocalBrowserControl({this.realWebPs = false});
  final bool realWebPs;
  static final shared = LocalBrowserControl();
  static final webPs = LocalBrowserControl(realWebPs: true);
  int? _port;
  String? _token;
  Timer? _poll;
  bool busy = true, pending = false, connected = false;
  String message = 'Sélectionnez le fichier de connexion du service local.';
  String? target;
  Future<void> connect(String config) async {
    if (pending || connected) return;
    final data = jsonDecode(config) as Map<String, dynamic>;
    if ((realWebPs && data['mode'] != 'webps-dv1') ||
        (!realWebPs && data['mode'] == 'webps-dv1')) {
      throw const FormatException(
        'Fichier de connexion destiné à un autre mode.',
      );
    }
    final port = data['port'];
    final token = data['token'];
    if (port is! int ||
        port < 1024 ||
        port > 65535 ||
        token is! String ||
        !RegExp(r'^[a-f0-9]{64}$').hasMatch(token)) {
      throw const FormatException('Fichier de connexion locale invalide.');
    }
    _port = port;
    _token = token;
    await _request('/state');
    _poll ??= Timer.periodic(const Duration(seconds: 1), (_) {
      if (!pending) unawaited(_request('/state'));
    });
  }

  Future<void> open(bool patient, {bool confirmed = false}) async {
    if (realWebPs && !confirmed) return;
    if (!connected || busy || pending) return;
    busy = true;
    await _request(patient ? '/open/patient' : '/open/dashboard', post: true);
  }

  Future<void> close() async {
    if (!connected || pending || !busy) return;
    await _request('/close', post: true);
  }

  Future<void> _request(String path, {bool post = false}) async {
    if (pending || _port == null) return;
    pending = true;
    notifyListeners();
    final client = HttpClient()..findProxy = (_) => 'DIRECT';
    try {
      final responseData = await (() async {
        final uri = Uri(
          scheme: 'http',
          host: '127.0.0.1',
          port: _port,
          path: path,
        );
        final request = await client.openUrl(post ? 'POST' : 'GET', uri);
        request.followRedirects = false;
        request.headers.set('Authorization', 'Bearer $_token');
        if (realWebPs && post && path.startsWith('/open/')) {
          request.headers.set('X-ABAK-Confirmation', 'MICHEL_DV1');
        }
        final response = await request.close();
        if (response.statusCode != 200) {
          throw const FormatException('Service indisponible');
        }
        final data =
            jsonDecode(await utf8.decoder.bind(response).join())
                as Map<String, dynamic>;
        if ((realWebPs && data['mode'] != 'webps-dv1') ||
            (!realWebPs && data['mode'] == 'webps-dv1')) {
          throw const FormatException('Mode du service incorrect');
        }
        if (data['busy'] is! bool || data['message'] is! String) {
          throw const FormatException('Réponse locale invalide');
        }
        return data;
      })().timeout(const Duration(seconds: 25));
      busy = responseData['busy'] as bool;
      message = responseData['message'] as String;
      target = responseData['target'] as String?;
      connected = true;
    } catch (_) {
      busy = true;
      message = 'État du navigateur non confirmé : nouveaux accès bloqués.';
    } finally {
      client.close(force: true);
      pending = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }
}
