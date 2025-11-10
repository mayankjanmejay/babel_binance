import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final appwriteServiceProvider = Provider((ref) => AppwriteService());

class AppwriteService {
  Client? _client;
  Account? _account;
  Databases? _databases;
  Storage? _storage;

  final _storage = const FlutterSecureStorage();

  // Configuration keys
  static const String _endpointKey = 'appwrite_endpoint';
  static const String _projectIdKey = 'appwrite_project_id';
  static const String _apiKeyKey = 'appwrite_api_key';

  bool get isConfigured => _client != null;

  Client? get client => _client;
  Account? get account => _account;
  Databases? get databases => _databases;
  Storage? get storage => _storage;

  /// Initialize Appwrite with saved configuration
  Future<bool> initialize() async {
    final endpoint = await _storage.read(key: _endpointKey);
    final projectId = await _storage.read(key: _projectIdKey);

    if (endpoint != null && projectId != null) {
      await configure(endpoint: endpoint, projectId: projectId);
      return true;
    }

    return false;
  }

  /// Configure Appwrite client
  Future<void> configure({
    required String endpoint,
    required String projectId,
    String? apiKey,
  }) async {
    _client = Client()
        .setEndpoint(endpoint)
        .setProject(projectId);

    if (apiKey != null) {
      _client!.setKey(apiKey);
    }

    _account = Account(_client!);
    _databases = Databases(_client!);
    _storage = Storage(_client!);

    // Save configuration
    await _storage.write(key: _endpointKey, value: endpoint);
    await _storage.write(key: _projectIdKey, value: projectId);
    if (apiKey != null) {
      await _storage.write(key: _apiKeyKey, value: apiKey);
    }
  }

  /// Get current configuration
  Future<Map<String, String?>> getConfiguration() async {
    return {
      'endpoint': await _storage.read(key: _endpointKey),
      'projectId': await _storage.read(key: _projectIdKey),
      'apiKey': await _storage.read(key: _apiKeyKey),
    };
  }

  /// Clear configuration
  Future<void> clearConfiguration() async {
    await _storage.delete(key: _endpointKey);
    await _storage.delete(key: _projectIdKey);
    await _storage.delete(key: _apiKeyKey);
    _client = null;
    _account = null;
    _databases = null;
    _storage = null;
  }

  // User Management
  Future<User> createUser({
    required String email,
    required String password,
    required String name,
  }) async {
    if (_account == null) throw Exception('Appwrite not configured');
    return await _account!.create(
      userId: ID.unique(),
      email: email,
      password: password,
      name: name,
    );
  }

  Future<Session> createEmailSession({
    required String email,
    required String password,
  }) async {
    if (_account == null) throw Exception('Appwrite not configured');
    return await _account!.createEmailSession(
      email: email,
      password: password,
    );
  }

  Future<User?> getCurrentUser() async {
    if (_account == null) return null;
    try {
      return await _account!.get();
    } catch (e) {
      return null;
    }
  }

  Future<void> logout() async {
    if (_account == null) throw Exception('Appwrite not configured');
    await _account!.deleteSession(sessionId: 'current');
  }

  // Database Management
  Future<Database> createDatabase({
    required String databaseId,
    required String name,
  }) async {
    if (_databases == null) throw Exception('Appwrite not configured');
    return await _databases!.create(
      databaseId: databaseId,
      name: name,
    );
  }

  Future<Collection> createCollection({
    required String databaseId,
    required String collectionId,
    required String name,
    List<String>? permissions,
    bool? documentSecurity,
  }) async {
    if (_databases == null) throw Exception('Appwrite not configured');
    return await _databases!.createCollection(
      databaseId: databaseId,
      collectionId: collectionId,
      name: name,
      permissions: permissions,
      documentSecurity: documentSecurity,
    );
  }

  Future<void> createStringAttribute({
    required String databaseId,
    required String collectionId,
    required String key,
    required int size,
    required bool required,
    String? defaultValue,
  }) async {
    if (_databases == null) throw Exception('Appwrite not configured');
    await _databases!.createStringAttribute(
      databaseId: databaseId,
      collectionId: collectionId,
      key: key,
      size: size,
      xrequired: required,
      xdefault: defaultValue,
    );
  }

  Future<void> createIntegerAttribute({
    required String databaseId,
    required String collectionId,
    required String key,
    required bool required,
    int? min,
    int? max,
    int? defaultValue,
  }) async {
    if (_databases == null) throw Exception('Appwrite not configured');
    await _databases!.createIntegerAttribute(
      databaseId: databaseId,
      collectionId: collectionId,
      key: key,
      xrequired: required,
      min: min,
      max: max,
      xdefault: defaultValue,
    );
  }

  Future<void> createBooleanAttribute({
    required String databaseId,
    required String collectionId,
    required String key,
    required bool required,
    bool? defaultValue,
  }) async {
    if (_databases == null) throw Exception('Appwrite not configured');
    await _databases!.createBooleanAttribute(
      databaseId: databaseId,
      collectionId: collectionId,
      key: key,
      xrequired: required,
      xdefault: defaultValue,
    );
  }

  Future<void> createDatetimeAttribute({
    required String databaseId,
    required String collectionId,
    required String key,
    required bool required,
    String? defaultValue,
  }) async {
    if (_databases == null) throw Exception('Appwrite not configured');
    await _databases!.createDatetimeAttribute(
      databaseId: databaseId,
      collectionId: collectionId,
      key: key,
      xrequired: required,
      xdefault: defaultValue,
    );
  }

  // Storage Management
  Future<Bucket> createBucket({
    required String bucketId,
    required String name,
    List<String>? permissions,
    bool? fileSecurity,
    bool? enabled,
    int? maximumFileSize,
    List<String>? allowedFileExtensions,
  }) async {
    if (_storage == null) throw Exception('Appwrite not configured');
    return await _storage!.createBucket(
      bucketId: bucketId,
      name: name,
      permissions: permissions,
      fileSecurity: fileSecurity,
      enabled: enabled,
      maximumFileSize: maximumFileSize,
      allowedFileExtensions: allowedFileExtensions,
    );
  }

  // Auto-push database structure
  Future<void> pushDatabaseStructure({
    required Map<String, dynamic> structure,
  }) async {
    if (_databases == null) throw Exception('Appwrite not configured');

    final databaseId = structure['databaseId'] as String;
    final databaseName = structure['name'] as String;
    final collections = structure['collections'] as List<dynamic>;

    // Create database
    try {
      await createDatabase(databaseId: databaseId, name: databaseName);
    } catch (e) {
      // Database might already exist
    }

    // Create collections and attributes
    for (final collection in collections) {
      final collectionId = collection['collectionId'] as String;
      final collectionName = collection['name'] as String;
      final attributes = collection['attributes'] as List<dynamic>?;

      try {
        await createCollection(
          databaseId: databaseId,
          collectionId: collectionId,
          name: collectionName,
          documentSecurity: true,
        );

        // Wait for collection to be ready
        await Future.delayed(const Duration(milliseconds: 500));

        // Create attributes
        if (attributes != null) {
          for (final attr in attributes) {
            final type = attr['type'] as String;
            final key = attr['key'] as String;
            final required = attr['required'] as bool? ?? false;

            switch (type) {
              case 'string':
                await createStringAttribute(
                  databaseId: databaseId,
                  collectionId: collectionId,
                  key: key,
                  size: attr['size'] as int? ?? 255,
                  required: required,
                  defaultValue: attr['default'] as String?,
                );
                break;
              case 'integer':
                await createIntegerAttribute(
                  databaseId: databaseId,
                  collectionId: collectionId,
                  key: key,
                  required: required,
                  defaultValue: attr['default'] as int?,
                );
                break;
              case 'boolean':
                await createBooleanAttribute(
                  databaseId: databaseId,
                  collectionId: collectionId,
                  key: key,
                  required: required,
                  defaultValue: attr['default'] as bool?,
                );
                break;
              case 'datetime':
                await createDatetimeAttribute(
                  databaseId: databaseId,
                  collectionId: collectionId,
                  key: key,
                  required: required,
                  defaultValue: attr['default'] as String?,
                );
                break;
            }

            // Wait between attribute creation
            await Future.delayed(const Duration(milliseconds: 300));
          }
        }
      } catch (e) {
        // Collection might already exist
        print('Error creating collection $collectionId: $e');
      }
    }
  }
}
