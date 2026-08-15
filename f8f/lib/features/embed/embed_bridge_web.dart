import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web/web.dart' as web;
import 'package:autoflow/features/embed/embed_api.dart';

@JS('JSON.stringify')
external String _jsonStringify(JSAny? value);

@JS('JSON.parse')
external JSAny _jsonParse(String value);

/// Registers `window.AutoFlow` and postMessage handlers for host pages.
void registerEmbedBridge(ProviderContainer container) {
  final api = EmbedApi(container);

  void postToParent(String type, Map<String, dynamic> data) {
    final payload = jsonEncode({'source': 'autoflow', 'type': type, ...data});
    web.window.parent?.postMessage(payload.toJS, '*'.toJS);
  }

  Map<String, dynamic> asMap(JSAny? value) {
    if (value == null) return {};
    try {
      final raw = _jsonStringify(value);
      final decoded = jsonDecode(raw);
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {}
    return {};
  }

  Future<JSAny?> dispatch(String method, Map<String, dynamic> args) async {
    switch (method) {
      case 'getWorkflow':
        return _jsonParse(jsonEncode(api.getWorkflow()));
      case 'setWorkflow':
        final doc = args['workflow'] is Map
            ? Map<String, dynamic>.from(args['workflow'] as Map)
            : args;
        api.setWorkflow(doc);
        postToParent('workflowSet', {'ok': true});
        return true.toJS;
      case 'setCatalog':
        api.setCatalog(
          Map<String, dynamic>.from((args['catalog'] as Map?) ?? args),
        );
        return true.toJS;
      case 'setVariables':
        api.setVariables(
          Map<String, dynamic>.from((args['variables'] as Map?) ?? args),
        );
        return true.toJS;
      case 'setSampleRecord':
        api.setSampleRecord(
          Map<String, dynamic>.from((args['record'] as Map?) ?? args),
        );
        return true.toJS;
      case 'setPreviewRecords':
        final list = args['records'] as List? ?? args['previewRecords'] as List? ?? const [];
        api.setPreviewRecords(list);
        return true.toJS;
      case 'startPreview':
        final report = await api.startPreview();
        postToParent('runComplete', {'report': report});
        return _jsonParse(jsonEncode(report));
      case 'configure':
        api.configure(
          embedChrome: args['embedChrome'] as String?,
          readOnly: args['readOnly'] as bool?,
        );
        return true.toJS;
      case 'submitInput':
        final payload = args['payload'] is Map
            ? Map<String, dynamic>.from(args['payload'] as Map)
            : Map<String, dynamic>.from(args);
        final run = args['run'] as bool? ?? true;
        final report = await api.submitInput(payload, run: run);
        postToParent('runComplete', {'report': report});
        return _jsonParse(jsonEncode(report));
      case 'snapshot':
        return _jsonParse(jsonEncode(api.snapshot()));
      default:
        return null;
    }
  }

  // Build window.AutoFlow with callable methods via JS interop.
  final autoFlow = JSObject();

  autoFlow['getWorkflow'] = (() {
    return _jsonParse(jsonEncode(api.getWorkflow()));
  }).toJS;

  autoFlow['setWorkflow'] = ((JSAny? doc) {
    api.setWorkflow(asMap(doc));
    return true;
  }).toJS;

  autoFlow['setCatalog'] = ((JSAny? doc) {
    api.setCatalog(asMap(doc));
    return true;
  }).toJS;

  autoFlow['setVariables'] = ((JSAny? doc) {
    api.setVariables(asMap(doc));
    return true;
  }).toJS;

  autoFlow['setSampleRecord'] = ((JSAny? doc) {
    api.setSampleRecord(asMap(doc));
    return true;
  }).toJS;

  autoFlow['setPreviewRecords'] = ((JSAny? doc) {
    final raw = doc?.dartify();
    if (raw is List) {
      api.setPreviewRecords(raw);
    } else {
      api.setPreviewRecords(asMap(doc)['records'] as List? ?? const []);
    }
    return true;
  }).toJS;

  autoFlow['startPreview'] = (() {
    unawaited(() async {
      final report = await api.startPreview();
      postToParent('runComplete', {'report': report});
    }());
    return true;
  }).toJS;

  autoFlow['configure'] = ((JSAny? opts) {
    final map = asMap(opts);
    api.configure(
      embedChrome: map['embedChrome'] as String?,
      readOnly: map['readOnly'] as bool?,
    );
    return true;
  }).toJS;

  autoFlow['submitInput'] = ((JSAny? opts) {
    final map = asMap(opts);
    final payload = map['payload'] is Map
        ? Map<String, dynamic>.from(map['payload'] as Map)
        : map;
    final run = map['run'] as bool? ?? true;
    unawaited(() async {
      final report = await api.submitInput(payload, run: run);
      postToParent('runComplete', {'report': report});
    }());
    return true;
  }).toJS;

  autoFlow['snapshot'] = (() {
    return _jsonParse(jsonEncode(api.snapshot()));
  }).toJS;

  autoFlow['call'] = ((JSString method, JSAny? args) {
    final m = method.toDart;
    final map = asMap(args);
    unawaited(() async {
      final result = await dispatch(m, map);
      postToParent('response', {
        'method': m,
        'result': result == null ? null : jsonDecode(_jsonStringify(result)),
      });
    }());
    return true;
  }).toJS;

  web.window.setProperty('AutoFlow'.toJS, autoFlow);

  web.window.addEventListener(
    'message',
    (web.MessageEvent event) {
      final data = event.data;
      Map<String, dynamic>? map;
      final dartified = data.dartify();
      if (dartified is String) {
        try {
          final decoded = jsonDecode(dartified);
          if (decoded is Map) map = Map<String, dynamic>.from(decoded);
        } catch (_) {}
      } else if (dartified is Map) {
        map = Map<String, dynamic>.from(dartified);
      }
      if (map == null || map['target'] != 'autoflow') return;
      final method = map['method'] as String?;
      if (method == null) return;
      final args = Map<String, dynamic>.from((map['args'] as Map?) ?? {});
      final requestId = map['requestId'];
      unawaited(() async {
        final result = await dispatch(method, args);
        postToParent('response', {
          'requestId': requestId,
          'result': result == null ? null : jsonDecode(_jsonStringify(result)),
        });
      }());
    }.toJS,
  );

  postToParent('ready', {'ok': true});
}
