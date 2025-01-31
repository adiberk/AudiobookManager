class DurationFormatter {
  static String format(Duration? duration) {
    if (duration == null) return '--:--';
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return '${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds';
  }

  static Duration? parse(String formattedDuration) {
    try {
      List<String> parts = formattedDuration.split(':');
      if (parts.length != 3) return null; // Ensure valid format

      int hours = int.parse(parts[0]);
      int minutes = int.parse(parts[1]);
      int seconds = int.parse(parts[2]);

      return Duration(hours: hours, minutes: minutes, seconds: seconds);
    } catch (e) {
      return null; // Return null if parsing fails
    }
  }
}
