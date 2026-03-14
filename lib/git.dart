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
