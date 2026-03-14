import 'dart:io';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;

bool _isSetup = false;
IOSink? _logFileSink;

void setupLogger({bool enableFileLogging = true}) {
  if (_isSetup) return;

  const loggerLength = 23;

  // Setup file logging if enabled
  if (enableFileLogging) {
    try {
      // Create logs directory if it doesn't exist
      final logsDir = Directory('logs');
      if (!logsDir.existsSync()) {
        logsDir.createSync(recursive: true);
      }

      // Create log file with timestamp
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.').first;
      final logFilePath = p.join('logs', 'git_finder_$timestamp.log');
      final logFile = File(logFilePath);

      _logFileSink = logFile.openWrite(mode: FileMode.append);
      print('Logging to: $logFilePath');
    } catch (e) {
      print('Warning: Could not setup file logging: $e');
    }
  }

  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    final loggerName = "[${record.loggerName}]".padRight(loggerLength);
    final level = record.level.name.toUpperCase().padRight(7);
    final time = record.time.toString().split('.').first; // Remove microseconds
    final logMessage = "$loggerName $level $time ${record.message}";

    // Write to file if enabled
    if (_logFileSink != null) {
      _logFileSink!.writeln(logMessage);
      if (record.level == Level.SEVERE && record.stackTrace != null) {
        _logFileSink!.writeln(record.stackTrace);
      }
    }

    // Only print to console for WARNING and above (not DEBUG, INFO, etc.)
    if (record.level >= Level.WARNING) {
      print(logMessage);

      final shouldPrintStackTrace = record.level == Level.SEVERE;
      if (shouldPrintStackTrace && record.stackTrace != null) {
        print(record.stackTrace);
      }
    }
  });

  _isSetup = true;
}

/// Closes the log file sink. Should be called before application exit.
Future<void> closeLogger() async {
  if (_logFileSink != null) {
    await _logFileSink!.flush();
    await _logFileSink!.close();
    _logFileSink = null;
  }
}
