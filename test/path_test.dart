import 'package:git_finder/path.dart';
import 'package:test/test.dart';
import 'package:path/path.dart' as p;

void main() {
  group('isSubdirectoryOf', () {
    test('returns true when child is a subdirectory of parent', () {
      expect(
        isSubdirectoryOf(
          child: '/Users/laurence/home',
          parent: '/Users/laurence',
        ),
        isTrue,
      );
    });

    test('returns true for deeply nested subdirectories', () {
      expect(
        isSubdirectoryOf(
          child: '/Users/laurence/a/b/c/d',
          parent: '/Users/laurence',
        ),
        isTrue,
      );
    });

    test('returns false when paths are the same', () {
      expect(
        isSubdirectoryOf(
          child: '/Users/laurence',
          parent: '/Users/laurence',
        ),
        isFalse,
      );
    });

    test('returns false when child is not a subdirectory', () {
      expect(
        isSubdirectoryOf(
          child: '/Users/work',
          parent: '/Users/laurence',
        ),
        isFalse,
      );
    });

    test('returns false when child is a parent of parent', () {
      expect(
        isSubdirectoryOf(
          child: '/Users',
          parent: '/Users/laurence',
        ),
        isFalse,
      );
    });

    test('handles paths with trailing slashes', () {
      expect(
        isSubdirectoryOf(
          child: '/Users/laurence/home/',
          parent: '/Users/laurence/',
        ),
        isTrue,
      );
    });

    test('handles relative path components', () {
      expect(
        isSubdirectoryOf(
          child: '/Users/laurence/../laurence/home',
          parent: '/Users/laurence',
        ),
        isTrue,
      );
    });

    test('returns false for completely different paths', () {
      expect(
        isSubdirectoryOf(
          child: '/opt/apps',
          parent: '/Users/laurence',
        ),
        isFalse,
      );
    });

    test('returns false when child has similar but different parent', () {
      expect(
        isSubdirectoryOf(
          child: '/Users/laurence2/home',
          parent: '/Users/laurence',
        ),
        isFalse,
      );
    });
  });

  group('resolvePathIntersection', () {
    test('returns empty list for empty input', () {
      expect(resolvePathIntersection([]), isEmpty);
    });

    test('returns single path unchanged', () {
      final paths = ['/Users/laurence'];
      final result = resolvePathIntersection(paths);
      expect(result.length, equals(1));
      expect(result.first, equals(p.normalize(p.absolute('/Users/laurence'))));
    });

    test('removes subdirectory when parent is present', () {
      final paths = ['/Users/laurence', '/Users/laurence/home'];
      final result = resolvePathIntersection(paths);
      expect(result.length, equals(1));
      expect(result.first, equals(p.normalize(p.absolute('/Users/laurence'))));
    });

    test('keeps both paths when neither is a subdirectory', () {
      final paths = ['/Users/laurence', '/Users/work'];
      final result = resolvePathIntersection(paths);
      expect(result.length, equals(2));
    });

    test('removes multiple subdirectories', () {
      final paths = [
        '/Users/laurence',
        '/Users/laurence/home',
        '/Users/laurence/home/documents',
        '/Users/work',
      ];
      final result = resolvePathIntersection(paths);
      expect(result.length, equals(2));
      expect(
        result,
        containsAll([
          p.normalize(p.absolute('/Users/laurence')),
          p.normalize(p.absolute('/Users/work')),
        ]),
      );
    });

    test('handles deeply nested paths', () {
      final paths = [
        '/a/b/c/d/e',
        '/a/b',
        '/a/b/c',
        '/x/y/z',
      ];
      final result = resolvePathIntersection(paths);
      expect(result.length, equals(2));
      expect(
        result,
        containsAll([
          p.normalize(p.absolute('/a/b')),
          p.normalize(p.absolute('/x/y/z')),
        ]),
      );
    });

    test('removes exact duplicates', () {
      final paths = [
        '/Users/laurence',
        '/Users/laurence',
        '/Users/laurence',
      ];
      final result = resolvePathIntersection(paths);
      expect(result.length, equals(1));
    });

    test('handles paths in random order', () {
      final paths = [
        '/Users/laurence/home/documents',
        '/Users/work',
        '/Users/laurence',
        '/Users/laurence/home',
      ];
      final result = resolvePathIntersection(paths);
      expect(result.length, equals(2));
      expect(
        result,
        containsAll([
          p.normalize(p.absolute('/Users/laurence')),
          p.normalize(p.absolute('/Users/work')),
        ]),
      );
    });

    test('handles paths with trailing slashes', () {
      final paths = [
        '/Users/laurence/',
        '/Users/laurence/home/',
      ];
      final result = resolvePathIntersection(paths);
      expect(result.length, equals(1));
    });

    test('handles relative paths by converting to absolute', () {
      final paths = [
        'test',
        'test/fixtures',
      ];
      final result = resolvePathIntersection(paths);
      expect(result.length, equals(1));
    });

    test('keeps all paths when none overlap', () {
      final paths = [
        '/opt/apps',
        '/Users/laurence',
        '/var/log',
        '/tmp/data',
      ];
      final result = resolvePathIntersection(paths);
      expect(result.length, equals(4));
    });

    test('handles complex hierarchy', () {
      final paths = [
        '/a/b/c',
        '/a/b',
        '/a/b/c/d',
        '/a',
        '/x',
        '/a/b/e',
      ];
      final result = resolvePathIntersection(paths);
      expect(result.length, equals(2));
      expect(
        result,
        containsAll([
          p.normalize(p.absolute('/a')),
          p.normalize(p.absolute('/x')),
        ]),
      );
    });
  });
}
