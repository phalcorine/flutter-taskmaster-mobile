import 'package:http/http.dart' as http;
import 'package:riverpod/riverpod.dart';

final httpClientProvider = Provider<http.Client>((ref) {
  return http.Client();
});
