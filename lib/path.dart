import 'dart:io';
import 'package:path/path.dart' as p;

/// Resolves path intersections by removing redundant subdirectory paths.
///
/// Given a list of paths, this function returns a filtered list where
/// no path is a subdirectory of another path in the list.
///
/// Example:
/// ```dart
/// final paths = ['/Users/laurence', '/Users/laurence/home', '/Users/work'];
/// final resolved = resolvePathIntersection(paths);
/// // Result: ['/Users/laurence', '/Users/work']
/// ```
///
/// The function is cross-platform compatible (works with Windows and Unix paths).
List<String> resolvePathIntersection(List<String> paths) {
  if (paths.isEmpty) {
    return [];
  }

  // Normalize all paths to absolute paths
  final normalizedPaths = paths.map((path) {
    return p.normalize(p.absolute(path));
  }).toSet().toList(); // Use Set to remove exact duplicates

  // Sort paths by length (shorter paths first)
  // This ensures parent directories are processed before their children
  normalizedPaths.sort((a, b) => a.length.compareTo(b.length));

  final result = <String>[];

  for (final path in normalizedPaths) {
    var isSubdirectory = false;

    // Check if this path is a subdirectory of any path already in the result
    for (final existingPath in result) {
      if (isSubdirectoryOf(child: path, parent: existingPath)) {
        isSubdirectory = true;
        break;
      }
    }

    // Only add if it's not a subdirectory of an existing path
    if (!isSubdirectory) {
      result.add(path);
    }
  }

  return result;
}

/// Checks if [child] is a subdirectory of [parent].
/// Works cross-platform (Windows and Unix).
bool isSubdirectoryOf({
  required String child,
  required String parent,
 }) {
  // Normalize both paths
  final normalizedChild = p.normalize(child);
  final normalizedParent = p.normalize(parent);

  // A path cannot be a subdirectory of itself
  if (normalizedChild == normalizedParent) {
    return false;
  }

  // Split paths into components
  final childParts = p.split(normalizedChild);
  final parentParts = p.split(normalizedParent);

  // If parent has more components than child, child cannot be a subdirectory
  if (parentParts.length >= childParts.length) {
    return false;
  }

  // Check if all parent components match the child's components
  // Case-insensitive on Windows, case-sensitive on Unix
  for (var i = 0; i < parentParts.length; i++) {
    final childPart = childParts[i];
    final parentPart = parentParts[i];

    // On Windows, compare case-insensitively
    final match = Platform.isWindows
        ? childPart.toLowerCase() == parentPart.toLowerCase()
        : childPart == parentPart;

    if (!match) {
      return false;
    }
  }

  return true;
}
