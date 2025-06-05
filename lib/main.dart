import 'dart:developer';

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:voicecontrolsmarthome/screens/mainLayout.dart';
import 'package:voicecontrolsmarthome/shared/cubits/auth/auth_cubit.dart';
import 'package:voicecontrolsmarthome/shared/cubits/devicesstatus/devices_status_cubit.dart';
import 'package:voicecontrolsmarthome/shared/cubits/voicecontrol/voice_control_cubit.dart';

import 'firebase_options.dart';
import 'index.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    log(' ✅ Firebase initialized successfully!');
  } catch (e) {
    log('❌ Firebase initialization failed: $e');
  }
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity, // Secure Play Integrity
    appleProvider: AppleProvider.deviceCheck, // Secure iOS DeviceCheck
    webProvider: ReCaptchaV3Provider(
        'your-recaptcha-site-key'), // Secure reCAPTCHA v3 for Web
  );
  await FirebaseAuth.instance.signOut();
  await DioHelper.initializeDio();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthCubit(),
        ),
        BlocProvider(
          create: (context) => DeviceControlCubit(),
        ),
        BlocProvider(
          create: (context) => VoiceControlCubit(),
        ),
      ],
      child: ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Voice Control Smart Home',
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            home: FirebaseAuth.instance.currentUser != null
                ?  const MainLayout()
                : const SignInPage(),
          );
        },
      ),
    );
  }
}
