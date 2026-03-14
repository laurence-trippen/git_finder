import 'dart:io';
import 'package:logging/logging.dart';

final _log = Logger('Git');

/// Checks if Git is installed on the system (macOS, Linux, or Windows).
/// Returns true if Git is available, false otherwise.
Future<bool> checkGitInstalled() async {
  try {
    final result = await Process.run('git', ['--version']);
    if (result.exitCode == 0) {
      _log.info('Git found: ${result.stdout.toString().trim()}');
      return true;
    }
    _log.warning('Git check failed with exit code ${result.exitCode}');
    return false;
  } catch (e) {
    _log.severe('Git check failed with exception: $e');
    return false;
  }
}

/// Checks if the Git repository at [repositoryPath] has uncommitted changes.
/// Returns true if there are uncommitted changes (modified, added, deleted files), false otherwise.
///
/// Uses `git status --porcelain` to check for changes in a machine-readable format.
Future<bool> hasUncommittedChanges(String repositoryPath) async {
  try {
    final result = await Process.run(
      'git',
      ['status', '--porcelain'],
      workingDirectory: repositoryPath,
    );

    if (result.exitCode != 0) {
      final stderr = (result.stderr as String).trim();
      if (stderr.isNotEmpty) {
        _log.warning('git status failed for $repositoryPath: $stderr');
      }
      return false;
    }

    // If output is not empty, there are uncommitted changes
    final output = (result.stdout as String).trim();
    return output.isNotEmpty;
  } catch (e) {
    _log.warning('git status exception for $repositoryPath: $e');
    return false;
  }
}

/// Checks if the Git repository at [repositoryPath] has unpushed commits.
/// Returns true if there are commits that haven't been pushed to the upstream branch, false otherwise.
///
/// Uses `git rev-list @{u}..HEAD` to count commits ahead of upstream.
/// Returns false if there is no upstream branch configured.
Future<bool> hasUnpushedCommits(String repositoryPath) async {
  try {
    // Check if there are commits ahead of upstream
    final result = await Process.run(
      'git',
      ['rev-list', '@{u}..HEAD', '--count'],
      workingDirectory: repositoryPath,
    );

    if (result.exitCode != 0) {
      // No upstream branch configured or other error
      // This is expected for repos without upstream, so only log at fine level
      _log.fine('No upstream configured for $repositoryPath');
      return false;
    }

    final output = (result.stdout as String).trim();
    final count = int.tryParse(output) ?? 0;
    return count > 0;
  } catch (e) {
    _log.warning('git rev-list exception for $repositoryPath: $e');
    return false;
  }
}

/// Checks if the Git repository at [repositoryPath] has any remote configured.
/// Returns true if at least one remote exists, false otherwise.
///
/// Uses `git remote` to list all configured remotes.
Future<bool> hasRemote(String repositoryPath) async {
  try {
    final result = await Process.run(
      'git',
      ['remote'],
      workingDirectory: repositoryPath,
    );

    if (result.exitCode != 0) {
      final stderr = (result.stderr as String).trim();
      if (stderr.isNotEmpty) {
        _log.warning('git remote failed for $repositoryPath: $stderr');
      }
      return false;
    }

    // If output is not empty, there is at least one remote
    final output = (result.stdout as String).trim();
    return output.isNotEmpty;
  } catch (e) {
    _log.warning('git remote exception for $repositoryPath: $e');
    return false;
  }
}
