import 'dart:io';
import 'package:ace/models/ocr_model.dart';
import 'package:ace/services/ocr_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

final ocrServiceProvider = Provider<OcrService>((ref) => OcrService());

class OcrState {
  final File? selectedFile;
  final AsyncValue<OcrResult> extractedResult;

  const OcrState({this.selectedFile, required this.extractedResult});

  OcrState copyWith({
    File? selectedFile,
    AsyncValue<OcrResult>? extractedResult,
  }) =>
      OcrState(
        selectedFile: selectedFile ?? this.selectedFile,
        extractedResult: extractedResult ?? this.extractedResult,
      );

  factory OcrState.initial() => OcrState(
        selectedFile: null,
        extractedResult: AsyncValue.data(OcrResult(text: '')),
      );
}

class OcrNotifier extends StateNotifier<OcrState> {
  OcrNotifier(this._service) : super(OcrState.initial());
  final OcrService _service;


  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      state = state.copyWith(selectedFile: File(picked.path));
    }
  }

  Future<void> pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result?.files.single.path != null) {
      state = state.copyWith(selectedFile: File(result!.files.single.path!));
    }
  }

  Future<OcrResult?> extractText() async {
    if (state.selectedFile == null) return null;
    state = state.copyWith(extractedResult: const AsyncValue.loading());

    try {
      final result = await _service.uploadFile(state.selectedFile!);
      state = state.copyWith(extractedResult: AsyncValue.data(result));
      return result;
    } catch (e, st) {
      state = state.copyWith(extractedResult: AsyncValue.error(e, st));
      return null;
    }
  }
}

final ocrNotifierProvider =
    StateNotifierProvider<OcrNotifier, OcrState>((ref) {
  return OcrNotifier(ref.read(ocrServiceProvider));
});
