import 'dart:io';

import 'package:chalkdart/chalkstrings.dart';

import 'package:git_finder/git.dart';
import 'package:git_finder/git_repo_finder.dart';
import 'package:git_finder/logger.dart';
import 'package:git_finder/path.dart';

import 'sys_exit.dart';

void main(List<String> arguments) async {
  setupLogger();

  print(" Git Finder ".white.onYellow);
  print("");

  final isGitInstalled = await checkGitInstalled();

  if (!isGitInstalled) {
    const sysExitCode = SysExit.gitNotFound;
    print(sysExitCode.displayMessage.red);
    exit(sysExitCode.code);
  }

  print("found git binary!".green);
  print("");

  // Check if paths were provided as arguments
  if (arguments.isEmpty) {
    print("Usage: git_finder <path1> [path2] [path3] ...".yellow);
    print("Example: git_finder /Users/me/projects /Users/me/work".yellow);
    const sysExitCode = SysExit.noPathsProvided;
    exit(sysExitCode.code);
  }

  print("Searching in ${arguments.length} path(s)...".cyan);
  print("");

  // Resolve colliding paths to highest folder
  final optimizedSearchPaths = resolvePathIntersections(arguments);

  print("Optimized to ${optimizedSearchPaths.length} path(s) after removing subdirectories".cyan);
  print("");

  // As paths are not colliding anymore its safe to start parallel reads
  final gitRepoFinder = GitRepoFinder();

  // Execute all searches in parallel and capture successes and failures
  final results = await Future.wait(
    optimizedSearchPaths.map((path) async {
      try {
        print("Scanning: $path".blue);
        final repos = await gitRepoFinder.findRepositories(path);
        print("  ✓ Found ${repos.length} repository/repositories".green);
        return (path: path, repos: repos, error: null);
      } catch (e) {
        print("  ✗ Error: $e".red);
        return (path: path, repos: <String>[], error: e.toString());
      }
    }).toList(),
  );

  print("");

  // Separate successful and failed results
  final successful = results.where((r) => r.error == null).toList();
  final failed = results.where((r) => r.error != null).toList();

  // Flatten all successfully found repositories
  final allRepos = successful.expand((r) => r.repos).toList();

  print("=" * 50);
  print("Summary:".whiteBright);
  print("  Paths searched: ${results.length}".white);
  print("  Successful: ${successful.length}".green);
  print("  Failed: ${failed.length}".red);
  print("  Total repositories found: ${allRepos.length}".greenBright);
  print("=" * 50);
  print("");

  if (failed.isNotEmpty) {
    print("Failed paths:".red);
    for (final result in failed) {
      print("  ✗ ${result.path}".red);
      print("    ${result.error}".redBright);
    }
    print("");
  }

  if (allRepos.isNotEmpty) {
    print("Analyzing repositories...".cyan);
    print("");

    // Check each repository for uncommitted changes, unpushed commits, and remote configuration
    final repoStatuses = await Future.wait(
      allRepos.map((repo) async {
        final hasUncommitted = await hasUncommittedChanges(repo);
        final hasUnpushed = await hasUnpushedCommits(repo);
        final hasRemoteConfigured = await hasRemote(repo);
        return (
          path: repo,
          hasUncommitted: hasUncommitted,
          hasUnpushed: hasUnpushed,
          hasRemote: hasRemoteConfigured,
        );
      }).toList(),
    );

    print("Repository Status:".whiteBright);
    print("");

    for (final status in repoStatuses) {
      if (!status.hasRemote) {
        // No remote = red (critical - isolated repo)
        print("  ⚠ ${status.path}".red);
        print("    no remote configured".red);
      } else if (status.hasUnpushed) {
        // Unpushed commits = red (most critical)
        print("  ⚠ ${status.path}".red);
        print("    unpushed commits".red);
      } else if (status.hasUncommitted) {
        // Uncommitted changes = yellow
        print("  ○ ${status.path}".yellow);
        print("    uncommitted changes".yellow);
      } else {
        // All OK = green
        print("  ✓ ${status.path}".green);
        print("    clean".green);
      }
    }

    print("");

    // Summary statistics
    final noRemoteRepos = repoStatuses.where((s) => !s.hasRemote).length;
    final cleanRepos = repoStatuses.where((s) => s.hasRemote && !s.hasUncommitted && !s.hasUnpushed).length;
    final uncommittedRepos = repoStatuses.where((s) => s.hasRemote && s.hasUncommitted && !s.hasUnpushed).length;
    final unpushedRepos = repoStatuses.where((s) => s.hasRemote && s.hasUnpushed).length;

    print("Status Summary:".whiteBright);
    print("  ✓ Clean: $cleanRepos".green);
    print("  ○ Uncommitted changes: $uncommittedRepos".yellow);
    print("  ⚠ Unpushed commits: $unpushedRepos".red);
    print("  ⚠ No remote configured: $noRemoteRepos".red);
  } else {
    print("No repositories found.".yellow);
  }

  print("done!");
}
