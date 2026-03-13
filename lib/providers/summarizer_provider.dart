import 'package:ace/models/summarizer_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ace/services/summarizer_service.dart';

final summarizerServiceProvider = Provider<SummarizerService>(
  (_) => SummarizerService(),
);
final summarizerProvider = FutureProvider.family<SummarizedText, String>((
  ref,
  text,
) {
  return ref.read(summarizerServiceProvider).summarizeText(text);
});
