import 'package:coffee_shop/core/colors/app_colors.dart';
import 'package:coffee_shop/core/textStyle/app_text_style.dart';
import 'package:coffee_shop/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LogInPage extends StatelessWidget {
  const LogInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment(0.8, 1),
            colors: <Color>[
              Color(0xff4e342e), // Deep Coffee Brown
              Color(0xff6d4c41), // Mocha
              Color(0xff8d6e63), // Latte
              Color(0xffa1887f), // Caramel
            ],
          ),
        ),
        child: const LoginForm(),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  LoginMethod _selectedMethod = LoginMethod.email;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          Navigator.pushReplacementNamed(context, '/home');
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset('assets/log/ucc 1.png'),
              // const Text('login').indieFlowerLoginStyle(),
              // 16.verticalSpace,
              _buildLoginMethodSelector(),
              16.verticalSpace,
              _buildTextField(
                _selectedMethod == LoginMethod.email
                    ? 'Email'
                    : _selectedMethod == LoginMethod.phone
                        ? 'Phone Number'
                        : 'Username',
                'Enter your ${_selectedMethod.toString().split('.').last}',
                _identifierController,
              ),
              12.verticalSpace,
              _buildTextField(
                'Password',
                'Enter your password',
                _passwordController,
                isPassword: true,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/forgot-password');
                  },
                  child: const Text('Forgot Password?')
                      .montserratRegularSize20FFFBFB(),
                ),
              ),
              20.verticalSpace,
              if (state is AuthLoading)
                const Center(child: CircularProgressIndicator())
              else
                _buildLoginButton(),
              20.verticalSpace,
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'New to Logo? ',
                      style: TextStyle(color: Colors.white70),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(context, '/signup');
                      },
                      child: const Text(
                        'Register',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Text(
                      ' Here',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoginMethodSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: LoginMethod.values.map((method) {
        return ChoiceChip(
          label: Text(
            method.toString().split('.').last.toUpperCase(),
            style: TextStyle(
              color:
                  _selectedMethod == method ? Colors.black : AppColors.ff412323,
            ),
          ),
          selected: _selectedMethod == method,
          onSelected: (selected) {
            if (selected) {
              setState(() => _selectedMethod = method);
            }
          },
        );
      }).toList(),
    );
  }

  // void _handleForgotPassword() async {
  //   try {
  //     await context.read<AuthBloc>().repository.forgotPassword(
  //           _identifierController.text,
  //           _selectedMethod,
  //         );
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Password reset email sent')),
  //     );
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text(e.toString())),
  //     );
  //   }
  // }

  Widget _buildTextField(
    String label,
    String hint,
    TextEditingController controller, {
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            enabledBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: Colors.white.withOpacity(0.5), width: 1.5),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.white, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.red, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.redAccent, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (_identifierController.text.isEmpty ||
              _passwordController.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please fill all fields')),
            );
            return;
          }

          context.read<AuthBloc>().add(
                LoginEvent(
                  _identifierController.text,
                  _passwordController.text,
                  _selectedMethod,
                ),
              );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.ff011C2A,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text('LOGIN').poppinsMediumSize20FFFFFF(),
      ),
    );
  }
}
