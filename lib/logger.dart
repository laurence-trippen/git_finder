import 'package:logging/logging.dart';


bool _isSetup = false;

void setupLogger() {
  if (_isSetup) return;

  const loggerLength = 23;

  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    final loggerName = "[${record.loggerName}]".padRight(loggerLength);
    final level = record.level.name.toUpperCase().padRight(7);
    final time = record.time.toString().split('.').first; // Remove microseconds

    print("$loggerName $level $time ${record.message}");

    final shouldPrintStrackTrace = record.level == Level.SEVERE;
    if (shouldPrintStrackTrace) {
      print(record.stackTrace);
    }
  });

  _isSetup = true;
}
