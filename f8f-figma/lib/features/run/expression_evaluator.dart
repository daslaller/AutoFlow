/// Tiny safe expression evaluator for preview (not a full language).
/// Supports: {{path}} lookups, == != comparisons, && ||, truthiness.
class ExpressionEvaluator {
  dynamic lookup(Map<String, dynamic> ctx, String path) {
    final parts = path.replaceAll('{{', '').replaceAll('}}', '').trim().split('.');
    dynamic cur = ctx;
    for (final p in parts) {
      if (cur is Map && cur.containsKey(p)) {
        cur = cur[p];
      } else {
        return null;
      }
    }
    return cur;
  }

  String interpolate(String template, Map<String, dynamic> ctx) {
    return template.replaceAllMapped(RegExp(r'\{\{([^}]+)\}\}'), (m) {
      final v = lookup(ctx, m.group(1)!.trim());
      return v?.toString() ?? '';
    });
  }

  /// Evaluate simple conditions like: {{ticket.status}} == "intake"
  bool evaluateCondition(String expr, Map<String, dynamic> ctx) {
    final trimmed = expr.trim();
    if (trimmed.isEmpty) return true;

    // OR
    if (trimmed.contains('||')) {
      return trimmed.split('||').any((p) => evaluateCondition(p.trim(), ctx));
    }
    // AND
    if (trimmed.contains('&&')) {
      return trimmed.split('&&').every((p) => evaluateCondition(p.trim(), ctx));
    }

    final ops = ['===', '!==', '==', '!=', '>=', '<=', '>', '<'];
    for (final op in ops) {
      final idx = trimmed.indexOf(op);
      if (idx > 0) {
        final left = _value(trimmed.substring(0, idx).trim(), ctx);
        final right = _value(trimmed.substring(idx + op.length).trim(), ctx);
        return switch (op) {
          '==' || '===' => '$left' == '$right',
          '!=' || '!==' => '$left' != '$right',
          '>' => _num(left) > _num(right),
          '<' => _num(left) < _num(right),
          '>=' => _num(left) >= _num(right),
          '<=' => _num(left) <= _num(right),
          _ => false,
        };
      }
    }

    final v = _value(trimmed, ctx);
    if (v is bool) return v;
    if (v == null) return false;
    if (v is num) return v != 0;
    return '$v'.isNotEmpty && '$v' != 'false';
  }

  dynamic _value(String raw, Map<String, dynamic> ctx) {
    if ((raw.startsWith('"') && raw.endsWith('"')) ||
        (raw.startsWith("'") && raw.endsWith("'"))) {
      return raw.substring(1, raw.length - 1);
    }
    if (raw.startsWith('{{') || raw.contains('.')) {
      return lookup(ctx, raw);
    }
    if (raw == 'true') return true;
    if (raw == 'false') return false;
    final n = num.tryParse(raw);
    if (n != null) return n;
    return lookup(ctx, raw) ?? raw;
  }

  double _num(dynamic v) {
    if (v is num) return v.toDouble();
    return double.tryParse('$v') ?? 0;
  }

  /// Expression "code" for preview: interpolate and return map.
  Map<String, dynamic> runExpression(
    String source,
    Map<String, dynamic> ctx,
  ) {
    final out = interpolate(source, ctx);
    return {'result': out, 'ctx': ctx};
  }
}
