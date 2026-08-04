import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/storage_service.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  final StorageService _storageService;

  ThemeCubit(this._storageService)
      : super(_storageService.isDarkMode ? ThemeMode.dark : ThemeMode.light);

  bool get isDarkMode => state == ThemeMode.dark;

  Future<void> toggleTheme() async {
    final nextMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    await _storageService.saveIsDarkMode(nextMode == ThemeMode.dark);
    emit(nextMode);
  }

  Future<void> setTheme(ThemeMode mode) async {
    await _storageService.saveIsDarkMode(mode == ThemeMode.dark);
    emit(mode);
  }
}
