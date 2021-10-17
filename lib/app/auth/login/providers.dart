import 'package:riverpod/riverpod.dart';
import 'package:taskmaster_mobile/app/auth/providers/auth_service_provider.dart';
import 'package:taskmaster_mobile/app/shared/persistence/api_token_storage.dart';
import 'package:taskmaster_mobile/app/shared/ui/models/forms.dart';

// Providers
final loginFormViewModelProvider =
    StateNotifierProvider.autoDispose<LoginFormViewModel, LoginFormModel>(
        (ref) {
  final authService = ref.watch(authServiceProvider);
  final tokenStorageManager = ref.watch(apiTokenStorageProvider);
  return LoginFormViewModel(authService, tokenStorageManager);
});

final loginFormPasswordVisibleStateProvider = StateProvider((ref) => false);

// Model

class LoginFormModel {
  final FormControlModel email;
  final FormControlModel password;
  final AppFormState formState;
  final String errorMessage;
  final String successMessage;

  LoginFormModel({
    required this.email,
    required this.password,
    required this.formState,
    required this.errorMessage,
    required this.successMessage,
  });

  bool get canSubmit => email.isValid && password.isValid;

  LoginFormModel copyWith({
    FormControlModel? email,
    FormControlModel? password,
    AppFormState? formState,
    String? errorMessage,
    String? successMessage,
  }) {
    return LoginFormModel(
      email: email ?? this.email,
      password: password ?? this.password,
      formState: formState ?? this.formState,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
    );
  }

  factory LoginFormModel.initial() {
    return LoginFormModel(
      email: FormControlModel.initial(),
      password: FormControlModel.initial(),
      formState: AppFormState.initial,
      errorMessage: '',
      successMessage: '',
    );
  }
}

// View Model / Notifier
class LoginFormViewModel extends StateNotifier<LoginFormModel> {
  final TokenStorageController tokenStorageManager;
  final AuthService authService;

  LoginFormViewModel(this.authService, this.tokenStorageManager)
      : super(LoginFormModel.initial());

  void validateEmail(String email) {
    // var emailState = state.email;
    String? errorText;
    bool isValid = false;
    if (email.trim().contains("@")) {
      isValid = true;
    } else {
      errorText = 'Please provide a valid email...';
    }

    state = state.copyWith(
      email: state.email
          .copyWith(errorText: errorText, value: email, isValid: isValid),
    );
  }

  void validatePassword(String password) {
    // var emailState = state.email;
    String? errorText;
    bool isValid = false;
    if (password.trim().isNotEmpty && password.trim().length >= 8) {
      isValid = true;
    } else {
      errorText = 'Password should be at least 8 characters...';
    }

    state = state.copyWith(
      password: state.password
          .copyWith(errorText: errorText, value: password, isValid: isValid),
    );
  }

  void login() async {
    state = state.copyWith(formState: AppFormState.loading);
    final request = LoginRequestDto(
        username: state.email.value, password: state.password.value);
    try {
      final response = await authService.login(request);
      final responseText = 'Access Token: ${response.token}';
      // 'Full Name: ${response.fullName}. Access Token: ${response.accessToken}.';

      // Store the access token
      final tokenStorage = await tokenStorageManager.getTokenStorage();
      await tokenStorageManager.setTokenStorage(tokenStorage.copyWith(
        accessToken: response.token,
      ));

      state = state.copyWith(
          formState: AppFormState.success, successMessage: responseText);
    } catch (ex) {
      final responseText = 'An error occurred. ${ex.toString()}';
      state = state.copyWith(
          formState: AppFormState.failure, errorMessage: responseText);
    }
  }

  void refresh() {
    state = state.copyWith(formState: AppFormState.initial);
  }
}
