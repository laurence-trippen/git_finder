enum SysExit {
  // Git Errors (200)
  gitNotFound(code: 200, displayMessage: "git not found!"),

  // Argument Errors (100)
  noPathsProvided(code: 100, displayMessage: "No paths provided!");

  const SysExit({
    required this.code,
    required this.displayMessage,
  });

  final int code;
  final String displayMessage;
}
