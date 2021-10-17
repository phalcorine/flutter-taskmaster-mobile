import 'package:riverpod/riverpod.dart';

final apiBaseUrlProvider = Provider<String>((ref) {
  return 'https://phalcorine-taskmaster-api.herokuapp.com/api';
});
