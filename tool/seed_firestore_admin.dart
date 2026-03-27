import 'dart:convert';
import 'dart:io';

import 'package:abroadready/core/firestore/schemas/firestore_collections_schema.dart';
import 'package:abroadready/core/firestore/schemas/university_program_schema.dart';
import 'package:abroadready/core/firestore/schemas/university_schema.dart';
import 'package:csv/csv.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;

const _firestoreScope = 'https://www.googleapis.com/auth/datastore';

Future<void> main(List<String> args) async {
  final parsedArgs = _parseArgs(args);
  final csvPath = parsedArgs['path'] ?? 'data/data.csv';
  final serviceAccountPath = parsedArgs['service-account'];
  final projectIdArg = parsedArgs['project'];
  final reset = parsedArgs.containsKey('reset');

  if (serviceAccountPath == null || serviceAccountPath.isEmpty) {
    stderr.writeln(
      'Missing required argument: --service-account=/absolute/path/key.json',
    );
    exitCode = 2;
    return;
  }

  final serviceAccountFile = File(serviceAccountPath);
  if (!await serviceAccountFile.exists()) {
    stderr.writeln('Service account file not found: $serviceAccountPath');
    exitCode = 2;
    return;
  }

  final credentialsJson =
      jsonDecode(await serviceAccountFile.readAsString())
          as Map<String, dynamic>;
  final credentials = ServiceAccountCredentials.fromJson(credentialsJson);
  final projectId = projectIdArg ?? (credentialsJson['project_id'] as String?);

  if (projectId == null || projectId.isEmpty) {
    stderr.writeln(
      'Project id missing. Provide --project=<firebase-project-id> or use a '
      'service account json containing project_id.',
    );
    exitCode = 2;
    return;
  }

  final rows = await _readCsvRows(csvPath);
  if (rows.isEmpty) {
    stdout.writeln('No CSV rows found at $csvPath');
    return;
  }

  final parsed = _parseEntities(rows);
  stdout.writeln(
    'Parsed ${parsed.universities.length} universities and '
    '${parsed.programs.length} programs from $csvPath',
  );

  final client = await clientViaServiceAccount(credentials, [_firestoreScope]);
  try {
    final api = _FirestoreRestClient(client, projectId);

    final hasDatabase = await api.hasDefaultDatabase();
    if (!hasDatabase) {
      stderr.writeln(
        'Firestore database (default) does not exist for project "$projectId".\n'
        'Create it once in Firebase Console: Build > Firestore Database > '
        'Create database.',
      );
      exitCode = 2;
      return;
    }

    if (reset) {
      stdout.writeln('Reset mode enabled. Deleting existing documents...');
      await api.deleteCollection(FirestoreCollections.programs);
      await api.deleteCollection(FirestoreCollections.universities);
    }

    await api.commitDocuments(
      collectionPath: FirestoreCollections.universities,
      documents: parsed.universities.values
          .map((entity) => _DocumentWrite(id: entity.id, data: entity.toMap()))
          .toList(growable: false),
    );

    await api.commitDocuments(
      collectionPath: FirestoreCollections.programs,
      documents: parsed.programs
          .map((entity) => _DocumentWrite(id: entity.id, data: entity.toMap()))
          .toList(growable: false),
    );

    stdout.writeln('Firestore seeding completed successfully.');
  } finally {
    client.close();
  }
}

Map<String, String> _parseArgs(List<String> args) {
  final parsed = <String, String>{};

  for (final arg in args) {
    if (arg == '--reset') {
      parsed['reset'] = 'true';
      continue;
    }

    if (!arg.startsWith('--') || !arg.contains('=')) {
      continue;
    }

    final index = arg.indexOf('=');
    final key = arg.substring(2, index).trim();
    final value = arg.substring(index + 1).trim();

    if (key.isNotEmpty) {
      parsed[key] = value;
    }
  }

  return parsed;
}

Future<List<Map<String, String>>> _readCsvRows(String csvPath) async {
  final file = File(csvPath);
  if (!await file.exists()) {
    throw ArgumentError('CSV file not found: $csvPath');
  }

  final content = await file.readAsString();
  final csvRows = const CsvToListConverter(
    eol: '\n',
    shouldParseNumbers: false,
  ).convert(content);

  if (csvRows.isEmpty) {
    return const [];
  }

  final headers = csvRows.first.map((cell) => '$cell'.trim()).toList();
  final records = <Map<String, String>>[];

  for (var i = 1; i < csvRows.length; i++) {
    final row = csvRows[i];
    if (row.isEmpty) {
      continue;
    }

    final map = <String, String>{};
    for (var j = 0; j < headers.length; j++) {
      final key = headers[j];
      final value = j < row.length ? '${row[j]}'.trim() : '';
      map[key] = value;
    }

    if ((map['university_id'] ?? '').isEmpty) {
      continue;
    }

    records.add(map);
  }

  return records;
}

_ParsedEntities _parseEntities(List<Map<String, String>> rows) {
  final universities = <String, UniversityEntity>{};
  final programs = <UniversityProgramEntity>[];

  for (final row in rows) {
    final university = UniversityEntity.fromCsvRow(row);
    universities[university.id] = university;

    final program = UniversityProgramEntity.fromCsvRow(row);
    programs.add(program);
  }

  return _ParsedEntities(universities: universities, programs: programs);
}

class _ParsedEntities {
  const _ParsedEntities({required this.universities, required this.programs});

  final Map<String, UniversityEntity> universities;
  final List<UniversityProgramEntity> programs;
}

class _DocumentWrite {
  const _DocumentWrite({required this.id, required this.data});

  final String id;
  final Map<String, dynamic> data;
}

class _FirestoreRestClient {
  _FirestoreRestClient(this._client, this._projectId);

  final http.Client _client;
  final String _projectId;

  Uri get _baseUri => Uri.parse(
    'https://firestore.googleapis.com/v1/projects/$_projectId/databases/(default)/documents',
  );

  Future<bool> hasDefaultDatabase() async {
    final uri = Uri.parse(
      'https://firestore.googleapis.com/v1/projects/$_projectId/databases/(default)',
    );
    final response = await _client.get(uri);

    if (response.statusCode == 404) {
      return false;
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError(
        'Failed to inspect Firestore database: '
        '${response.statusCode} ${response.body}',
      );
    }

    return true;
  }

  Future<void> commitDocuments({
    required String collectionPath,
    required List<_DocumentWrite> documents,
  }) async {
    const writesPerBatch = 200;
    var processed = 0;

    while (processed < documents.length) {
      final end = (processed + writesPerBatch > documents.length)
          ? documents.length
          : processed + writesPerBatch;
      final chunk = documents.sublist(processed, end);

      final writes = chunk
          .map((doc) {
            final documentName =
                'projects/$_projectId/databases/(default)/documents/$collectionPath/${doc.id}';

            return {
              'update': {
                'name': documentName,
                'fields': _toFirestoreFields(doc.data),
              },
            };
          })
          .toList(growable: false);

      final response = await _client.post(
        _baseUri.replace(path: '${_baseUri.path}:commit'),
        headers: {'content-type': 'application/json'},
        body: jsonEncode({'writes': writes}),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw StateError(
          'Commit failed for $collectionPath: ${response.statusCode} ${response.body}',
        );
      }

      processed = end;
      stdout.writeln(
        'Committed $processed/${documents.length} docs to $collectionPath',
      );
    }
  }

  Future<void> deleteCollection(String collectionPath) async {
    var pageToken = '';
    var deleted = 0;

    while (true) {
      final queryParams = <String, String>{'pageSize': '300'};
      if (pageToken.isNotEmpty) {
        queryParams['pageToken'] = pageToken;
      }

      final listUri = _baseUri.replace(
        path: '${_baseUri.path}/$collectionPath',
        queryParameters: queryParams,
      );

      final listResponse = await _client.get(listUri);
      if (listResponse.statusCode == 404) {
        return;
      }

      if (listResponse.statusCode < 200 || listResponse.statusCode >= 300) {
        throw StateError(
          'Failed to list $collectionPath: '
          '${listResponse.statusCode} ${listResponse.body}',
        );
      }

      final payload = jsonDecode(listResponse.body) as Map<String, dynamic>;
      final docs = (payload['documents'] as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>();

      for (final doc in docs) {
        final name = doc['name'] as String;
        final deleteUri = Uri.parse(
          'https://firestore.googleapis.com/v1/$name',
        );
        final deleteResponse = await _client.delete(deleteUri);

        if (deleteResponse.statusCode < 200 ||
            deleteResponse.statusCode >= 300) {
          throw StateError(
            'Failed to delete $name: '
            '${deleteResponse.statusCode} ${deleteResponse.body}',
          );
        }

        deleted++;
      }

      pageToken = payload['nextPageToken'] as String? ?? '';
      if (pageToken.isEmpty) {
        break;
      }
    }

    stdout.writeln('Deleted $deleted docs from $collectionPath');
  }
}

Map<String, dynamic> _toFirestoreFields(Map<String, dynamic> data) {
  final fields = <String, dynamic>{};

  data.forEach((key, value) {
    fields[key] = _toFirestoreValue(value);
  });

  return fields;
}

Map<String, dynamic> _toFirestoreValue(dynamic value) {
  if (value == null) {
    return {'nullValue': null};
  }

  if (value is String) {
    return {'stringValue': value};
  }

  if (value is bool) {
    return {'booleanValue': value};
  }

  if (value is int) {
    return {'integerValue': value.toString()};
  }

  if (value is double) {
    return {'doubleValue': value};
  }

  if (value is DateTime) {
    return {'timestampValue': value.toUtc().toIso8601String()};
  }

  if (value is List) {
    return {
      'arrayValue': {
        'values': value.map(_toFirestoreValue).toList(growable: false),
      },
    };
  }

  if (value is Map<String, dynamic>) {
    return {
      'mapValue': {'fields': _toFirestoreFields(value)},
    };
  }

  return {'stringValue': value.toString()};
}
