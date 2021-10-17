import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:riverpod/riverpod.dart';
import 'package:taskmaster_mobile/app/shared/exception/app_http_exception.dart';
import 'package:taskmaster_mobile/app/shared/providers/api_server.dart';
import 'package:taskmaster_mobile/app/shared/providers/http.dart';
import 'package:taskmaster_mobile/app/shared/static/http_status.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  final baseUrl = ref.watch(apiBaseUrlProvider);
  final httpClient = ref.watch(httpClientProvider);
  return AuthService(
    baseUrl: baseUrl,
    httpClient: httpClient,
  );
});

class AuthService {
  final http.Client httpClient;
  final String baseUrl;

  AuthService({
    required this.httpClient,
    required this.baseUrl,
  });

  Future<LoginResponseDto> login(LoginRequestDto dto) async {
    try {
      final url = Uri.parse('$baseUrl/auth/login');
      final response = await httpClient.post(
        url,
        body: dto.toJson(),
        headers: {
          "Content-Type": "application/json",
        },
      );

      print('Login URL: ');
      print(url);
      print('Login Response Status: ');
      print(response.statusCode);
      print(response.request?.url);
      print(dto.toJson());
      print('Login Response: ');
      print(response.body);
      print('Login Response Bytes: ');
      print(response.bodyBytes);
      if (HttpStatus.fromCode(response.statusCode).isOk) {
        print('Proper response');
        return LoginResponseDto.fromJson(response.body);
      } else {
        throw AppException.fromHttpResponse(response);
      }
    } on AppException {
      rethrow;
    } catch (ex) {
      throw AppException(message: ex.toString());
    }
  }

  Future<SignupResponseDto> signup(SignupRequestDto dto) async {
    try {
      final url = Uri.parse('$baseUrl/auth/signup');
      final response = await httpClient.post(
        url,
        body: dto.toJson(),
        headers: {
          "Content-Type": "application/json",
        },
      );

      print('Signup Response: ');
      print(response.body);
      print('Signup Response Bytes: ');
      print(response.bodyBytes);
      if (HttpStatus.fromCode(response.statusCode).isOk) {
        return SignupResponseDto.fromJson(response.body);
      } else {
        throw AppException.fromHttpResponse(response);
      }
    } on AppException {
      rethrow;
    } catch (ex) {
      throw AppException(message: ex.toString());
    }
  }
}

// Models

class LoginRequestDto {
  final String username;
  final String password;

  LoginRequestDto({
    required this.username,
    required this.password,
  });

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'password': password,
    };
  }

  factory LoginRequestDto.fromMap(Map<String, dynamic> map) {
    return LoginRequestDto(
      username: map['username'],
      password: map['password'],
    );
  }

  String toJson() => json.encode(toMap());

  factory LoginRequestDto.fromJson(String source) =>
      LoginRequestDto.fromMap(json.decode(source));
}

class LoginResponseDto {
  final String token;

  LoginResponseDto({
    required this.token,
  });

  Map<String, dynamic> toMap() {
    return {
      'token': token,
    };
  }

  factory LoginResponseDto.fromMap(Map<String, dynamic> map) {
    return LoginResponseDto(
      token: map['token'],
    );
  }

  String toJson() => json.encode(toMap());

  factory LoginResponseDto.fromJson(String source) =>
      LoginResponseDto.fromMap(json.decode(source));
}

class SignupRequestDto {
  final String fullName;
  final String email;
  final String password;

  SignupRequestDto({
    required this.fullName,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'email': email,
      'password': password,
    };
  }

  factory SignupRequestDto.fromMap(Map<String, dynamic> map) {
    return SignupRequestDto(
      fullName: map['fullName'],
      email: map['email'],
      password: map['password'],
    );
  }

  String toJson() => json.encode(toMap());

  factory SignupRequestDto.fromJson(String source) =>
      SignupRequestDto.fromMap(json.decode(source));
}

class SignupResponseDto {
  final String message;

  SignupResponseDto({
    required this.message,
  });

  Map<String, dynamic> toMap() {
    return {
      'message': message,
    };
  }

  factory SignupResponseDto.fromMap(Map<String, dynamic> map) {
    return SignupResponseDto(
      message: map['message'],
    );
  }

  String toJson() => json.encode(toMap());

  factory SignupResponseDto.fromJson(String source) =>
      SignupResponseDto.fromMap(json.decode(source));
}
