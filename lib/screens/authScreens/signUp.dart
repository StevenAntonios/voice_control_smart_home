import 'dart:developer';

import 'package:loading_indicator/loading_indicator.dart';
import 'package:voicecontrolsmarthome/index.dart';
import 'package:voicecontrolsmarthome/shared/cubits/auth/auth_cubit.dart';
import 'package:voicecontrolsmarthome/shared/widgets/app_widgets/awsome_snackbar.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is RegisterSuccess) {
            showSnackBarSuccess(
              context: context,
              title: 'Register Success!',
              message: 'Congratulations! Sign-up Successful.',
            );

            // Remove all previous screens and go to MainLayout
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const SignInPage()),
              (route) => false,
            );
          } else if (state is RegisterFailed) {
            showSnackBarFailure(
              context: context,
              title: 'Registration Failed!',
              message: state.message,
            );
          }
        },
        builder: (context, state) {
          var cubit = AuthCubit.get(context);
          return SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: 35.h),
                  SvgPicture.asset(
                    'assets/icons/house-svgrepo-com.svg',
                    height: 150.h,
                    width: 150.w,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'Create account',
                    style: Constants.twentyfoursmbold,
                  ),
                  SizedBox(height: 30.h),
                  CustomTextField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "User name cannot be empty";
                      }

                      // Split full name to extract first name
                      List<String> nameParts = value.trim().split(" ");
                      String firstName = nameParts[0];

                      // Check if first name contains only letters
                      RegExp nameRegExp = RegExp(r"^[a-zA-Z]+$");
                      if (!nameRegExp.hasMatch(firstName)) {
                        return "Enter a valid name (letters only)";
                      }

                      // Check if first name is too long
                      if (firstName.length > 12) {
                        return "First name should not exceed 10 characters";
                      }

                      // Check minimum length
                      if (firstName.length < 3) {
                        return "First name must be at least 3 characters long";
                      }

                      return null;
                    },
                    controller: _usernameController,
                    title: 'Your Full Name',
                    hintText: 'John Doe',
                    keyboardType: TextInputType.name,
                  ),
                  SizedBox(height: 16.h),
                  CustomTextField(
                    title: 'Email',
                    controller: _emailController,
                    hintText: 'Johndoe@example.com',
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      RegExp regExp = RegExp(
                          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
                      if (value == null || value.isEmpty) {
                        return "Email cannot be empty";
                      } else if (!regExp.hasMatch(value)) {
                        return "Enter a valid email";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.h),
                  CustomTextField(
                    controller: _passwordController,
                    validator: (value) {
                      if (value!.isEmpty) return 'Please enter your Password';
                      if (value.length < 5)
                        return "Please enter a strong password";
                      return null;
                    },
                    title: 'Password',
                    hintText: '*************',
                    keyboardType: TextInputType.text,
                    obsecureText: true,
                  ),
                  SizedBox(height: 16.h),
                  CustomTextField(
                    title: 'Confirm Password',
                    hintText: '*************',
                    keyboardType: TextInputType.text,
                    obsecureText: true,
                    validator: (value) {
                      if (value!.isEmpty) return 'Empty';
                      if (value != _passwordController.text)
                        return 'Passwords do not match';
                      return null;
                    },
                  ),
                  SizedBox(height: 31.h),
                  state is RegisterLoading
                      ? const LoadingIndicator(
                          strokeWidth: 5,
                          indicatorType: Indicator.ballPulse,
                          colors: [Colors.black, Colors.blue],
                        )
                      : CustomElevatedButton(
                          buttonName: 'Sign Up',
                          onTab: () {
                            if (_formKey.currentState!.validate()) {
                              cubit.register(
                                username: _usernameController.text,
                                email: _emailController.text,
                                password: _passwordController.text,
                              );
                            } else if (state is RegisterFailed) {
                              log(state.message);
                              showSnackBarFailure(
                                context: context,
                                title: 'Registeration Failed!',
                                message: state.message,
                              );
                            }
                          },
                        ),
                  SizedBox(height: 32.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 51.w),
                    child: const Divider(),
                  ),
                  CustomBottomBar(
                    text: 'Have an account?',
                    onTab: () {},
                    auth: 'Login',
                    builder: (BuildContext context) => const SignInPage(),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
