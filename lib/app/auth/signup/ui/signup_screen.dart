import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskmaster_mobile/app/auth/login/providers.dart';
import 'package:taskmaster_mobile/app/auth/login/ui/login_screen.dart';
import 'package:taskmaster_mobile/app/shared/ui/models/forms.dart';

import '../providers.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  static const String routeName = '/auth/signup';

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = ref.watch(signupFormViewModelProvider);
    final viewModel = ref.watch(signupFormViewModelProvider.notifier);

    final _showPassword = ref.watch(signupFormPasswordVisibleStateProvider);
    final _toggleShowPassword =
        ref.read(signupFormPasswordVisibleStateProvider.notifier);

    ref.listen(signupFormViewModelProvider, (SignupFormModel state) {
      if (state.formState == AppFormState.success) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(state.successMessage)));
        ref.read(signupFormViewModelProvider.notifier).resetForm();
        Navigator.of(context).pop();
      }

      if (state.formState == AppFormState.failure) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(state.errorMessage)));
        ref.read(signupFormViewModelProvider.notifier).refresh();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Signup to TaskMaster!'),
      ),
      body: SingleChildScrollView(
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextField(
                controller: _fullNameController,
                decoration: InputDecoration(
                  errorText: model.fullName.errorText,
                  labelText: 'Full Name',
                ),
                keyboardType: TextInputType.name,
                onChanged: viewModel.validateFullName,
              ),
              const SizedBox(
                height: 10,
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  errorText: model.email.errorText,
                  labelText: 'Email',
                ),
                keyboardType: TextInputType.emailAddress,
                onChanged: viewModel.validateEmail,
              ),
              const SizedBox(
                height: 10,
              ),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                    errorText: model.password.errorText,
                    labelText: 'Password',
                    suffixIcon: IconButton(
                      icon: Icon(_showPassword.state
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () => _toggleShowPassword.state =
                          !_toggleShowPassword.state,
                    )),
                keyboardType: TextInputType.visiblePassword,
                onChanged: viewModel.validatePassword,
                obscureText: !_showPassword.state,
              ),
              const SizedBox(
                height: 15,
              ),
              _buildSignupButton(),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                onPressed: () =>
                    Navigator.of(context).pushNamed(LoginScreen.routeName),
                child: const Text('Login to an existing account'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignupButton() {
    bool isFormSubmitting = ref.watch(signupFormViewModelProvider
        .select((model) => model.formState == AppFormState.loading));
    if (isFormSubmitting) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final canSubmit = ref
        .watch(signupFormViewModelProvider.select((model) => model.canSubmit));

    return ElevatedButton(
      onPressed: canSubmit
          ? ref.read(signupFormViewModelProvider.notifier).signup
          : null,
      child: const Text('Signup'),
    );
  }
}
