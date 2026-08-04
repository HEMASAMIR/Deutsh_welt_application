import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/storage_service.dart';

class LanguageCubit extends Cubit<Locale> {
  final StorageService _storageService;

  LanguageCubit(this._storageService)
      : super(Locale(_storageService.language));

  void changeLanguage(String languageCode) async {
    await _storageService.saveLanguage(languageCode);
    emit(Locale(languageCode));
  }

  bool get isArabic => state.languageCode == 'ar';
}
