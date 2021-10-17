import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskmaster_mobile/app/auth/login/providers.dart';
import 'package:taskmaster_mobile/app/auth/signup/ui/signup_screen.dart';
import 'package:taskmaster_mobile/app/shared/ui/models/forms.dart';
import 'package:taskmaster_mobile/app/tasks/list/ui/task_list_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  static const String routeName = '/auth/login';

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = ref.watch(loginFormViewModelProvider);
    final viewModel = ref.watch(loginFormViewModelProvider.notifier);

    final _showPassword = ref.watch(loginFormPasswordVisibleStateProvider);
    final _toggleShowPassword =
        ref.read(loginFormPasswordVisibleStateProvider.notifier);

    ref.listen(loginFormViewModelProvider, (LoginFormModel state) {
      if (state.formState == AppFormState.success) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(state.successMessage)));
        ref.read(loginFormViewModelProvider.notifier).refresh();
        Navigator.of(context).pushNamed(TaskListScreen.routeName);
      }

      if (state.formState == AppFormState.failure) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(state.errorMessage)));
        ref.read(loginFormViewModelProvider.notifier).refresh();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login to TaskMaster!'),
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
              _buildLoginButton(),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                onPressed: () =>
                    Navigator.of(context).pushNamed(SignupScreen.routeName),
                child: const Text('Create an account'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    bool isFormSubmitting = ref.watch(loginFormViewModelProvider
        .select((model) => model.formState == AppFormState.loading));
    if (isFormSubmitting) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final canSubmit = ref
        .watch(loginFormViewModelProvider.select((model) => model.canSubmit));

    return ElevatedButton(
      onPressed: canSubmit
          ? ref.read(loginFormViewModelProvider.notifier).login
          : null,
      child: const Text('Login'),
    );
  }
}
