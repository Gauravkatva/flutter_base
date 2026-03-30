/// Abstract class defining a generic local storage interface.
///
/// Provides basic CRUD operations for storing key-value pairs
/// where values are represented as `Map<String, dynamic>`.
abstract class LocalStorage {
  /// Initialize the storage backend.
  ///
  /// Must be called before any other operations.
  Future<void> init();

  /// Store a value associated with the given [key].
  ///
  /// If a value already exists for the key, it will be overwritten.
  Future<void> put(String key, Map<String, dynamic> value);

  /// Retrieve the value associated with the given [key].
  ///
  /// Returns `null` if no value exists for the key.
  Future<Map<String, dynamic>?> get(String key);

  /// Retrieve all stored key-value pairs.
  Future<List<Map<String, dynamic>>> getAll();

  /// Delete the value associated with the given [key].
  Future<void> delete(String key);

  /// Remove all stored values.
  Future<void> clear();
}
