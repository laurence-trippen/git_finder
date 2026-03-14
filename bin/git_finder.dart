import 'dart:io';

import 'package:chalkdart/chalkstrings.dart';

import 'package:git_finder/git.dart';
import 'package:git_finder/git_repo_finder.dart';
import 'package:git_finder/logger.dart';

import 'sys_exit.dart';

void main(List<String> arguments) async {
  setupLogger();

  print(" Git Finder ".white.onYellow);
  print("");

  final isGitInstalled  = await checkGitInstalled();

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

  final gitRepoFinder = GitRepoFinder();
  final allRepos = <String>[];

  // Search each provided path
  for (final path in arguments) {
    print("Scanning: $path".blue);

    try {
      final repos = await gitRepoFinder.findRepositories(path);
      allRepos.addAll(repos);
      print("  Found ${repos.length} repository/repositories".green);
    } catch (e) {
      print("  Error: $e".red);
    }
    print("");
  }

  print("="*50);
  print("Total: ${allRepos.length} repositories found".greenBright);
  print("="*50);
  print("");

  for (final repo in allRepos) {
    print(repo);
  }

  print("done!");
}
