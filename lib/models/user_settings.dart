import 'package:audiobook_manager/providers/theme_provider.dart';
import 'package:uuid/uuid.dart';

class UserSettings {
  final String id;
  final ThemeSelection selectedTheme;

  UserSettings({
    String? id,
    this.selectedTheme = ThemeSelection.system,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
        'id': id,
        'theme': selectedTheme.name,
      };

  factory UserSettings.fromJson(Map<String, dynamic> json) => UserSettings(
        id: json['id'],
        selectedTheme: ThemeSelection.values.firstWhere(
          (theme) => theme.name == json['theme'],
          orElse: () => ThemeSelection.system,
        ),
      );

  // Create a copy of the audiobook with modified properties
  UserSettings copyWith({
    ThemeSelection? selectedTheme,
  }) {
    return UserSettings(
      id: id, // Keep the same ID
      selectedTheme: selectedTheme ?? this.selectedTheme,
    );
  }
}
