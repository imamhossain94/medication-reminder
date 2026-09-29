import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../utils/constants.dart';
import 'database_service.dart';

/// Progress of a single [DatabaseDownloader.fetch] call.
class DatabaseDownloadProgress {
  const DatabaseDownloadProgress({
    required this.received,
    required this.total,
    required this.sourceIndex,
    required this.mirror,
  });

  final int received;
  final int? total;
  final int sourceIndex;
  final String mirror;

  /// 0 → 1, or `null` when the mirror does not report a content length.
  double? get fraction {
    final int? t = total;
    if (t == null || t <= 0) return null;
    return (received / t).clamp(0.0, 1.0);
  }

  String get mirrorLabel {
    final Uri uri = Uri.parse(mirror);
    return uri.host;
  }
}

/// Thrown when every mirror failed.
class DatabaseDownloadException implements Exception {
  DatabaseDownloadException(this.message, {this.cause});
  final String message;
  final Object? cause;

  @override
  String toString() => message;
}

/// Downloads `medicine.db` from the public GitHub repository
/// <https://github.com/WSAyan/medicinedb> (MIT licensed).
///
/// A list of mirrors is tried in order so a single GitHub outage does not stop
/// the app from starting. The file is validated (sqlite magic header + `brand`
/// table) *before* it replaces the installed copy, and the swap itself is
/// atomic, so an interrupted download can never leave a broken database behind.
class DatabaseDownloader {
  DatabaseDownloader({Dio? dio}) : _dio = dio ?? _createDio();

  final Dio _dio;

  static const int _minValidSize = 100 * 1024; // 100 kB
  static const String _sqliteMagic = 'SQLite format 3';

  static Dio _createDio() => Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(minutes: 3),
          sendTimeout: const Duration(seconds: 20),
          followRedirects: true,
          // Let Dio raise for 4xx/5xx so we can fall through to the next mirror.
          validateStatus: (int? status) => status != null && status < 400,
          responseType: ResponseType.bytes,
        ),
      );

  /// Downloads the database and installs it at [DatabaseService.path].
  ///
  /// Returns the number of brand rows the installed file contains.
  Future<int> fetch({
    void Function(DatabaseDownloadProgress progress)? onProgress,
    CancelToken? cancelToken,
  }) async {
    final List<String> failures = <String>[];

    for (int i = 0; i < medicineDbMirrors.length; i++) {
      final String mirror = medicineDbMirrors[i];
      try {
        final File downloaded = await _downloadToTemp(mirror, i, onProgress, cancelToken);

        final String? error = await _validate(downloaded);
        if (error != null) {
          await _safeDelete(downloaded);
          failures.add('${Uri.parse(mirror).host}: $error');
          continue;
        }

        await DatabaseService.instance.close();
        await _install(downloaded);
        await DatabaseService.instance.open();
        return DatabaseService.instance.brandCount;
      } on DioException catch (e) {
        failures.add('${Uri.parse(mirror).host}: ${e.type.name}');
      } catch (e) {
        failures.add('${Uri.parse(mirror).host}: $e');
      }
    }

    throw DatabaseDownloadException(
      failures.isEmpty
          ? 'No database mirror configured.'
          : 'Could not download the medicine database.\n${failures.join('\n')}',
    );
  }

  /// Copies the validated download next to the target and swaps it in with a
  /// single `rename`, so the installed file is never a partial one.
  Future<void> _install(File downloaded) async {
    final String target = await DatabaseService.resolvePath();
    final File staging = File('$target.download');

    if (staging.existsSync()) await staging.delete();
    await downloaded.copy(staging.path);

    final File targetFile = File(target);
    if (targetFile.existsSync()) await targetFile.delete();
    await staging.rename(target);

    await _safeDelete(downloaded);
  }

  Future<File> _downloadToTemp(
    String url,
    int index,
    void Function(DatabaseDownloadProgress)? onProgress,
    CancelToken? cancelToken,
  ) async {
    final Directory tempDir = await getTemporaryDirectory();
    final File target = File(p.join(tempDir.path, 'medicine.db.part'));

    final Response<List<int>> response = await _dio.get<List<int>>(
      url,
      cancelToken: cancelToken,
      onReceiveProgress: (int received, int total) {
        onProgress?.call(DatabaseDownloadProgress(
          received: received,
          total: total <= 0 ? null : total,
          sourceIndex: index,
          mirror: url,
        ));
      },
    );

    final List<int> bytes = response.data ?? const <int>[];
    if (bytes.isEmpty) {
      throw DatabaseDownloadException('Mirror returned an empty file.');
    }

    final RandomAccessFile raf = await target.open(mode: FileMode.writeOnly);
    await raf.writeFrom(bytes);
    await raf.close();
    return target;
  }

  /// Returns `null` when the file looks good, otherwise a human readable error.
  Future<String?> _validate(File file) async {
    if (!file.existsSync()) return 'download produced no file';

    final int length = await file.length();
    if (length < _minValidSize) {
      return 'file too small (${(length / 1024).toStringAsFixed(0)} kB)';
    }

    final RandomAccessFile raf = await file.open();
    try {
      final List<int> header = await raf.read(_sqliteMagic.length);
      for (int i = 0; i < header.length; i++) {
        if (header[i] != _sqliteMagic.codeUnitAt(i)) {
          return 'not a SQLite database (mirror returned an HTML page?)';
        }
      }
    } finally {
      await raf.close();
    }
    return null;
  }

  Future<void> _safeDelete(File file) async {
    try {
      if (file.existsSync()) await file.delete();
    } catch (_) {/* ignore */}
  }
}
