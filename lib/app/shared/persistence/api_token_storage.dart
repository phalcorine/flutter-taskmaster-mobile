import 'package:riverpod/riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final apiTokenStorageProvider = Provider<TokenStorageController>((ref) {
  return TokenStorageController();
});

class TokenStorageModel {
  final String accessToken;
  final String refreshToken;

  TokenStorageModel({
    required this.accessToken,
    required this.refreshToken,
  });

  TokenStorageModel copyWith({
    String? accessToken,
    String? refreshToken,
  }) {
    return TokenStorageModel(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
    );
  }
}

class TokenStorageController {
  Future<TokenStorageModel> getTokenStorage() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final accessToken = preferences.getString('pref_key_access_token') ?? '';
    final refreshToken = preferences.getString('pref_key_refresh_token') ?? '';

    return TokenStorageModel(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  Future<void> setTokenStorage(TokenStorageModel tokenStorage) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString('pref_key_access_token', tokenStorage.accessToken);
    preferences.setString('pref_key_refresh_token', tokenStorage.refreshToken);
  }
}
