class FormControlModel {
  final String value;
  final String? errorText;
  final bool isValid;

  FormControlModel({
    required this.value,
    required this.errorText,
    required this.isValid,
  });

  FormControlModel copyWith({
    String? value,
    String? errorText,
    bool? isValid,
  }) {
    return FormControlModel(
      value: value ?? this.value,
      errorText: errorText,
      isValid: isValid ?? this.isValid,
    );
  }

  factory FormControlModel.initial() {
    return FormControlModel(value: '', errorText: null, isValid: false);
  }
}

enum AppFormState { initial, loading, success, failure }
