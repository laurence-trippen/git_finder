import 'dart:io';

import 'package:chalkdart/chalkstrings.dart';

import 'package:git_finder/git.dart';
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
}
