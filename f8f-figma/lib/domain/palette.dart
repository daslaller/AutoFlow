import 'package:autoflow/domain/catalog.dart';
import 'package:autoflow/domain/models.dart';

/// Back-compat palette list derived from the default catalog.
List<NodeDef> get kPalette =>
    buildDefaultCatalog().types.map((t) => t.asDef).toList();

Map<String, List<ConfigField>> get kConfigFields {
  final map = <String, List<ConfigField>>{};
  for (final t in buildDefaultCatalog().types) {
    map[t.id] = t.fields
        .map(
          (f) => ConfigField(
            label: f.label,
            placeholder: f.placeholder,
            key: f.key,
          ),
        )
        .toList();
  }
  return map;
}

NodeDef? findPaletteDef(String id) {
  final t = buildDefaultCatalog().find(id);
  return t?.asDef;
}

List<ConfigField> configFieldsFor(String defId) =>
    kConfigFields[defId] ?? const [];

List<FieldDef> fieldDefsFor(String defId, [NodeCatalog? catalog]) {
  final cat = catalog ?? buildDefaultCatalog();
  return cat.find(defId)?.fields ?? const [];
}
