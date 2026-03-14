import 'dart:io';
import 'package:logging/logging.dart';

final _log = Logger('GitRepoFinder');

/// Finds Git repositories within a specified directory.
class GitRepoFinder {
  /// Searches for Git repositories in the specified [directory].
  /// Returns a list of paths to directories containing a .git folder.
  ///
  /// If [recursive] is true (default), searches in all subdirectories.
  /// If [maxDepth] is specified, limits the search depth (0 = only the given directory).
  Future<List<String>> findRepositories(
    String directory, {
    bool recursive = true,
    int? maxDepth,
  }) async {
    final repositories = <String>[];
    final dir = Directory(directory);

    if (!await dir.exists()) {
      throw DirectoryNotFoundException(directory);
    }

    await _searchDirectory(
      dir,
      repositories,
      recursive: recursive,
      currentDepth: 0,
      maxDepth: maxDepth,
    );

    return repositories;
  }

  Future<void> _searchDirectory(
    Directory dir,
    List<String> repositories, {
    required bool recursive,
    required int currentDepth,
    int? maxDepth,
  }) async {
    // Check if we've reached the maximum depth
    if (maxDepth != null && currentDepth > maxDepth) {
      return;
    }

    try {
      await for (final entity in dir.list(followLinks: false)) {
        if (entity is Directory) {
          final dirName = entity.path.split(Platform.pathSeparator).last;

          // Check if this is a .git directory
          if (dirName == '.git') {
            // Add the parent directory as a repository
            repositories.add(dir.path);
            _log.fine('Found repository: ${dir.path}');
            // Don't search inside .git directories
            continue;
          }

          // Skip hidden directories (except .git which we already handled)
          if (dirName.startsWith('.')) {
            continue;
          }

          // Recursively search subdirectories if enabled
          if (recursive) {
            await _searchDirectory(
              entity,
              repositories,
              recursive: recursive,
              currentDepth: currentDepth + 1,
              maxDepth: maxDepth,
            );
          }
        }
      }
    } catch (e) {
      // Skip directories we don't have permission to access
      _log.warning('Cannot access directory ${dir.path}: $e');
    }
  }
}

/// Exception thrown when a directory is not found.
class DirectoryNotFoundException implements Exception {
  final String directory;

  DirectoryNotFoundException(this.directory);

  @override
  String toString() => 'Directory not found: $directory';
}
