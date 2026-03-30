import 'dart:convert';

import 'package:my_appp/domain/data/local/local_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// [LocalStorage] implementation backed by SharedPreferences.
///
/// Stores key-value pairs where values are JSON-encoded strings.
/// Keys are namespaced with a configurable [prefix] to avoid collisions.
class SharedPrefsStorage implements LocalStorage {
  /// Creates a new [SharedPrefsStorage] with the given key [prefix].
  ///
  /// The [prefix] is prepended to all keys to namespace entries
  /// and avoid collisions with other SharedPreferences data.
  SharedPrefsStorage({this.prefix = 'app_storage_'});

  /// Prefix applied to all keys for namespacing.
  final String prefix;

  SharedPreferences? _prefs;

  SharedPreferences get _sharedPrefs {
    if (_prefs == null) {
      throw StateError(
        'SharedPreferences not initialized. '
        'Call init() before performing operations.',
      );
    }
    return _prefs!;
  }

  /// Returns the namespaced key.
  String _prefixedKey(String key) => '$prefix$key';

  @override
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  Future<void> put(String key, Map<String, dynamic> value) async {
    final jsonString = jsonEncode(value);
    await _sharedPrefs.setString(_prefixedKey(key), jsonString);
  }

  @override
  Future<Map<String, dynamic>?> get(String key) async {
    final jsonString = _sharedPrefs.getString(_prefixedKey(key));
    if (jsonString == null) return null;
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  @override
  Future<List<Map<String, dynamic>>> getAll() async {
    final allKeys = _sharedPrefs
        .getKeys()
        .where((k) => k.startsWith(prefix))
        .toList();

    return allKeys.map((key) {
      final jsonString = _sharedPrefs.getString(key)!;
      return jsonDecode(jsonString) as Map<String, dynamic>;
    }).toList();
  }

  @override
  Future<void> delete(String key) async {
    await _sharedPrefs.remove(_prefixedKey(key));
  }

  @override
  Future<void> clear() async {
    final allKeys = _sharedPrefs
        .getKeys()
        .where((k) => k.startsWith(prefix))
        .toList();

    for (final key in allKeys) {
      await _sharedPrefs.remove(key);
    }
  }
}
