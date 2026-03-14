import 'dart:io';

/// Checks if Git is installed on the system (macOS, Linux, or Windows).
/// Returns true if Git is available, false otherwise.
Future<bool> checkGitInstalled() async {
  try {
    final result = await Process.run('git', ['--version']);
    return result.exitCode == 0;
  } catch (e) {
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
      return false;
    }

    // If output is not empty, there are uncommitted changes
    final output = (result.stdout as String).trim();
    return output.isNotEmpty;
  } catch (e) {
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
      return false;
    }

    final output = (result.stdout as String).trim();
    final count = int.tryParse(output) ?? 0;
    return count > 0;
  } catch (e) {
    return false;
  }
}
