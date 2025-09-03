import 'dart:io';
import 'package:ace/services/upload_notes_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

final ocrServiceProvider = Provider<OcrService>((ref) => OcrService());

class OcrState {
  final File? selectedFile;
  final AsyncValue<String> extractedText;

  OcrState({
    this.selectedFile,
    required this.extractedText,
  });

  OcrState copyWith({
    File? selectedFile,
    AsyncValue<String>? extractedText,
  }) {
    return OcrState(
      selectedFile: selectedFile ?? this.selectedFile,
      extractedText: extractedText ?? this.extractedText,
    );
  }

  factory OcrState.initial() {
    return OcrState(
      selectedFile: null,
      extractedText: const AsyncValue.data(''),
    );
  }
}

class OcrNotifier extends StateNotifier<OcrState> {
  OcrNotifier(this._service) : super(OcrState.initial());
  final OcrService _service;

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      state = state.copyWith(selectedFile: File(picked.path));
    }
  }

  Future<void> pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.files.single.path != null) {
      state = state.copyWith(selectedFile: File(result.files.single.path!));
    }
  }

  // Future<void> extractText() async {
  //   if (state.selectedFile == null) return;
  //   state = state.copyWith(extractedText: const AsyncValue.loading());
  //   try {
  //     final text = await _service.uploadFile(state.selectedFile!);
  //     state = state.copyWith(extractedText: AsyncValue.data(text));
  //   } catch (e, st) {
  //     state = state.copyWith(extractedText: AsyncValue.error(e, st));
  //   }
  // }
  Future<String> extractText() async {
  state = state.copyWith(extractedText: const AsyncValue.loading());
  try {
    final text = await  _service.uploadFile(state.selectedFile!);
    state = state.copyWith(extractedText: AsyncValue.data(text));
    return text; // ✅ Now returns the text
  } catch (e, st) {
    state = state.copyWith(extractedText: AsyncValue.error(e, st));
    return ""; // Return empty string on error
  }
}

}

final ocrNotifierProvider =
    StateNotifierProvider<OcrNotifier, OcrState>((ref) {
  return OcrNotifier(ref.read(ocrServiceProvider));
});
