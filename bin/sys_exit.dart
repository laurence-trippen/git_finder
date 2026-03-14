enum SysExit {
  // Git Errors (200)
  gitNotFound(code: 200, displayMessage: "git not found!");

  const SysExit({
    required this.code,
    required this.displayMessage,
  });

  final int code;
  final String displayMessage;
}
