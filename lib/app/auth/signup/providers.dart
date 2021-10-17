import 'package:riverpod/riverpod.dart';
import 'package:taskmaster_mobile/app/auth/providers/auth_service_provider.dart';
import 'package:taskmaster_mobile/app/shared/ui/models/forms.dart';

// Providers
final signupFormViewModelProvider =
    StateNotifierProvider.autoDispose<SignupFormViewModel, SignupFormModel>(
        (ref) {
  final authService = ref.watch(authServiceProvider);
  return SignupFormViewModel(authService);
});

final signupFormPasswordVisibleStateProvider = StateProvider((ref) => false);

// Model

class SignupFormModel {
  final FormControlModel fullName;
  final FormControlModel email;
  final FormControlModel password;
  final AppFormState formState;
  final String errorMessage;
  final String successMessage;

  SignupFormModel({
    required this.fullName,
    required this.email,
    required this.password,
    required this.formState,
    required this.errorMessage,
    required this.successMessage,
  });

  bool get canSubmit => fullName.isValid && email.isValid && password.isValid;

  SignupFormModel copyWith({
    FormControlModel? fullName,
    FormControlModel? email,
    FormControlModel? password,
    AppFormState? formState,
    String? errorMessage,
    String? successMessage,
  }) {
    return SignupFormModel(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      password: password ?? this.password,
      formState: formState ?? this.formState,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
    );
  }

  factory SignupFormModel.initial() {
    return SignupFormModel(
      fullName: FormControlModel.initial(),
      email: FormControlModel.initial(),
      password: FormControlModel.initial(),
      formState: AppFormState.initial,
      errorMessage: '',
      successMessage: '',
    );
  }
}

// View Model / Notifier
class SignupFormViewModel extends StateNotifier<SignupFormModel> {
  final AuthService authService;

  SignupFormViewModel(this.authService) : super(SignupFormModel.initial());

  void validateFullName(String fullName) {
    String? errorText;
    bool isValid = false;
    if (fullName.trim().isNotEmpty && fullName.trim().length >= 3) {
      isValid = true;
    } else {
      errorText = 'Full name should be at least three (3) characters...';
    }

    state = state.copyWith(
      fullName: state.fullName
          .copyWith(errorText: errorText, value: fullName, isValid: isValid),
    );
  }

  void validateEmail(String email) {
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

  void signup() async {
    state = state.copyWith(formState: AppFormState.loading);
    final request = SignupRequestDto(
        fullName: state.fullName.value,
        email: state.email.value,
        password: state.password.value);
    try {
      final response = await authService.signup(request);
      final responseText = 'Message: ${response.message}';
      // 'Full Name: ${response.fullName}. Access Token: ${response.accessToken}.';
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

  void resetForm() {
    state = SignupFormModel.initial();
  }
}
