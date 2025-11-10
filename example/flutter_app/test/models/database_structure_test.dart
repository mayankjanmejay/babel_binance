import 'package:flutter_test/flutter_test.dart';
import 'package:babel_binance_example/src/models/database_structure.dart';

void main() {
  group('DatabaseStructure Tests', () {
    test('getDefaultStructure returns valid structure', () {
      final structure = DatabaseStructure.getDefaultStructure();

      expect(structure['databaseId'], 'babel_binance_db');
      expect(structure['name'], 'Babel Binance Database');
      expect(structure['collections'], isA<List>());
      expect(structure['collections'].length, greaterThan(0));
    });

    test('default structure contains required collections', () {
      final structure = DatabaseStructure.getDefaultStructure();
      final collections = structure['collections'] as List;

      final collectionIds = collections.map((c) => c['collectionId']).toList();

      expect(collectionIds, contains('users'));
      expect(collectionIds, contains('trades'));
      expect(collectionIds, contains('portfolios'));
      expect(collectionIds, contains('watchlist'));
      expect(collectionIds, contains('analytics'));
    });

    test('users collection has required attributes', () {
      final structure = DatabaseStructure.getDefaultStructure();
      final collections = structure['collections'] as List;
      final usersCollection = collections.firstWhere(
        (c) => c['collectionId'] == 'users',
      );

      expect(usersCollection['name'], 'Users');
      expect(usersCollection['attributes'], isA<List>());

      final attributes = usersCollection['attributes'] as List;
      final attributeKeys = attributes.map((a) => a['key']).toList();

      expect(attributeKeys, contains('displayName'));
      expect(attributeKeys, contains('bio'));
      expect(attributeKeys, contains('avatar'));
      expect(attributeKeys, contains('preferences'));
    });

    test('getCustomStructure creates custom structure', () {
      final customStructure = DatabaseStructure.getCustomStructure(
        databaseId: 'custom_db',
        databaseName: 'Custom Database',
        collections: [
          {
            'collectionId': 'custom_collection',
            'name': 'Custom Collection',
            'attributes': [],
          },
        ],
      );

      expect(customStructure['databaseId'], 'custom_db');
      expect(customStructure['name'], 'Custom Database');
      expect(customStructure['collections'].length, 1);
    });
  });
}
