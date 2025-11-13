/// Log severity levels
enum LogLevel {
  /// Detailed diagnostic information
  debug(0),

  /// Informational messages
  info(1),

  /// Warning messages
  warn(2),

  /// Error messages
  error(3),

  /// Fatal error messages
  fatal(4),

  /// No logging
  none(999);

  final int severity;
  const LogLevel(this.severity);

  bool operator >=(LogLevel other) => severity >= other.severity;
  bool operator <=(LogLevel other) => severity <= other.severity;
  bool operator >(LogLevel other) => severity > other.severity;
  bool operator <(LogLevel other) => severity < other.severity;
}
