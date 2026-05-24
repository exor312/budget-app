import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:budget_app/core/theme/theme_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ThemeModel', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    test('defaults to system theme when no preference saved', () async {
      final model = ThemeModel();
      await model.load();
      expect(model.themeMode, ThemeMode.system);
      expect(model.isInitialized, isTrue);
    });

    test('loads saved light preference from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({'theme_mode': 'light'});
      final model = ThemeModel();
      await model.load();
      expect(model.themeMode, ThemeMode.light);
    });

    test('loads saved dark preference from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({'theme_mode': 'dark'});
      final model = ThemeModel();
      await model.load();
      expect(model.themeMode, ThemeMode.dark);
    });

    test('loads saved system preference from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({'theme_mode': 'system'});
      final model = ThemeModel();
      await model.load();
      expect(model.themeMode, ThemeMode.system);
    });

    test('setThemeMode persists light mode and notifies listeners', () async {
      final model = ThemeModel();
      await model.load();

      var notified = false;
      model.addListener(() => notified = true);

      await model.setThemeMode(ThemeMode.light);

      expect(model.themeMode, ThemeMode.light);
      expect(notified, isTrue);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('theme_mode'), 'light');
    });

    test('setThemeMode persists dark mode', () async {
      final model = ThemeModel();
      await model.load();

      await model.setThemeMode(ThemeMode.dark);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('theme_mode'), 'dark');
    });

    test('setThemeMode persists system mode', () async {
      final model = ThemeModel();
      await model.load();
      // First set to a different mode so system is a change
      await model.setThemeMode(ThemeMode.dark);
      await model.setThemeMode(ThemeMode.system);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('theme_mode'), 'system');
    });

    test('setThemeMode does not notify when mode unchanged', () async {
      final model = ThemeModel();
      await model.load();
      await model.setThemeMode(ThemeMode.dark);

      var notified = false;
      model.addListener(() => notified = true);

      await model.setThemeMode(ThemeMode.dark);

      expect(notified, isFalse);
    });

    test('toggleBrightness switches from light to dark', () async {
      final model = ThemeModel();
      await model.load();
      await model.setThemeMode(ThemeMode.light);

      await model.toggleBrightness();

      expect(model.themeMode, ThemeMode.dark);
    });

    test('toggleBrightness switches from dark to light', () async {
      final model = ThemeModel();
      await model.load();
      await model.setThemeMode(ThemeMode.dark);

      await model.toggleBrightness();

      expect(model.themeMode, ThemeMode.light);
    });

    test('toggleBrightness switches from system to light', () async {
      final model = ThemeModel();
      await model.load();

      await model.toggleBrightness();

      expect(model.themeMode, ThemeMode.light);
    });
  });
}
