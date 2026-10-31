import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/locale_provider.dart';
import '../providers/theme_provider.dart'; // ADDED
import '../localization/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));

    final localeProvider = context.watch<LocaleProvider>();
    final themeProvider = context.watch<ThemeProvider>(); // ADDED

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        title: Text(
          loc.getString('settings') ?? 'Settings',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ============================================================
          // LANGUAGE SECTION (unchanged)
          // ============================================================
          Card(
            color: theme.cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                  color: theme.dividerColor.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    textDirection: Directionality.of(context),
                    children: [
                      Icon(Icons.language,
                          color: theme.colorScheme.onSurface),
                      const SizedBox(width: 12),
                      Text(
                        loc.getString('language') ?? 'Language',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildLanguageTile(
                  context,
                  title: loc.getString('english') ?? 'English',
                  code: 'en',
                  isSelected: localeProvider.locale.languageCode == 'en',
                ),
                _buildLanguageTile(
                  context,
                  title: loc.getString('pashto') ?? 'Pashto',
                  code: 'ps',
                  isSelected: localeProvider.locale.languageCode == 'ps',
                ),
                _buildLanguageTile(
                  context,
                  title: loc.getString('dari') ?? 'Dari',
                  code: 'fa',
                  isSelected: localeProvider.locale.languageCode == 'fa',
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ============================================================
          // ✅ NEW: APPEARANCE / THEME MODE SECTION
          // ============================================================
          Card(
            color: theme.cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                  color: theme.dividerColor.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    textDirection: Directionality.of(context),
                    children: [
                      Icon(Icons.palette_outlined,
                          color: theme.colorScheme.onSurface),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          loc.getString('appearance') ?? 'Appearance',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Row(
                    textDirection: Directionality.of(context),
                    children: [
                      Expanded(
                        child: Text(
                          loc.getString('theme_mode') ?? 'Theme Mode',
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.hintColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Three-way toggle
                Padding(
                  padding:
                      const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: SegmentedButton<ThemeMode>(
                    style: SegmentedButton.styleFrom(
                      backgroundColor: theme.scaffoldBackgroundColor,
                      foregroundColor: theme.colorScheme.onSurface,
                      selectedBackgroundColor:
                          theme.brightness == Brightness.dark
                              ? const Color(0xFFE0E0E0)
                              : const Color(0xFF102C4A),
                      selectedForegroundColor:
                          theme.brightness == Brightness.dark
                              ? Colors.black
                              : Colors.white,
                      side: BorderSide(color: theme.dividerColor),
                    ),
                    segments: [
                      ButtonSegment<ThemeMode>(
                        value: ThemeMode.light,
                        icon: const Icon(Icons.light_mode_outlined,
                            size: 18),
                        label: Text(
                            loc.getString('theme_light') ?? 'Light'),
                      ),
                      ButtonSegment<ThemeMode>(
                        value: ThemeMode.dark,
                        icon: const Icon(Icons.dark_mode_outlined,
                            size: 18),
                        label: Text(
                            loc.getString('theme_dark') ?? 'Dark'),
                      ),
                      ButtonSegment<ThemeMode>(
                        value: ThemeMode.system,
                        icon: const Icon(Icons.brightness_auto_outlined,
                            size: 18),
                        label: Text(
                            loc.getString('theme_system') ?? 'System'),
                      ),
                    ],
                    selected: {themeProvider.themeMode},
                    onSelectionChanged: (selection) {
                      themeProvider.setThemeMode(selection.first);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageTile(
    BuildContext context, {
    required String title,
    required String code,
    required bool isSelected,
  }) {
    final theme = Theme.of(context);
    return ListTile(
      title: Text(
        title,
        style: TextStyle(color: theme.colorScheme.onSurface),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: Colors.green)
          : Icon(Icons.circle_outlined, color: theme.hintColor),
      onTap: () {
        context.read<LocaleProvider>().setLocale(code);
      },
    );
  }
}