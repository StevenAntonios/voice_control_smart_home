import 'package:loading_indicator/loading_indicator.dart';
import 'package:voicecontrolsmarthome/screens/authScreens/signUp.dart';
import 'package:voicecontrolsmarthome/screens/mainLayout.dart';
import 'package:voicecontrolsmarthome/shared/cubits/auth/auth_cubit.dart';
import 'package:voicecontrolsmarthome/shared/widgets/app_widgets/awsome_snackbar.dart';

import '../../index.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({
    super.key,
  });
  static const routeName = 'SignIn';

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is LoginSuccess) {
            showSnackBarSuccess(
              context: context,
              title: 'Login Success!',
              message: 'Welcome to your smart home',
            );
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) =>  const MainLayout()),
                            (route) => false,

            );
          } else if (state is LoginFailed) {
            showSnackBarFailure(
              context: context,
              title: 'Login Failed!',
              message: 'Invalid email or password. Please try again.',
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
                    'Log In',
                    style: Constants.twentyfoursmbold,
                  ),
                  SizedBox(height: 32.h),
                  CustomTextField(
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value!.isEmpty) return 'Please enter your email';
                      if (!value.contains('@'))
                        return 'Please enter a valid email';
                      return null;
                    },
                    controller: _emailController,
                    title: 'Email',
                    hintText: 'Johndoe@example.com',
                  ),
                  SizedBox(height: 16.h),
                  CustomTextField(
                    validator: (value) {
                      if (value!.isEmpty) return 'Please enter your Password';
                      if (value.length < 5)
                        return 'Please enter a Strong password';
                      return null;
                    },
                    controller: _passwordController,
                    title: 'Password',
                    hintText: '*************',
                    keyboardType: TextInputType.text,
                    obsecureText: true,
                  ),
                  SizedBox(height: 32.h),
                  state is LoginLoading
                      ? const LoadingIndicator(
                        strokeWidth: 5,
                        
                          indicatorType: Indicator.ballPulse,
                          colors: [Colors.black, Colors.blue],
                        )
                      : CustomElevatedButton(
                          buttonName: 'Log In',
                          onTab: () {
                            if (_formKey.currentState!.validate()) {
                              cubit.login(
                                email: _emailController.text,
                                password: _passwordController.text,
                              );
                            } else {
                              showSnackBarFailure(
                                context: context,
                                title: 'Login Failed!',
                                message: 'Wrong Email Or Passord!',
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
                    auth: 'Sign Up',
                    text: 'No account?',
                    onTab: () {},
                    builder: (BuildContext context) => const SignUp(),
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
