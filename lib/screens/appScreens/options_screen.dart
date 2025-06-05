import 'package:voicecontrolsmarthome/index.dart';
import 'package:voicecontrolsmarthome/shared/cubits/auth/auth_cubit.dart';

class OptionsScreen extends StatelessWidget {
  const OptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get user data from AuthCubit
    final authCubit = context.read<AuthCubit>();
    final fullName = authCubit.userModel.userName;
    final email = authCubit.userModel.email;

    // Extract first name
    final firstName = fullName.split(" ")[0];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Profile",
          style: Constants.twentyfoursmbold,
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Avatar
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.blueAccent,
                  child: Text(
                    firstName[0], // Show first letter of username
                    style: TextStyle(fontSize: 40.sp, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Display Username
            Text(
              "Hello, $firstName!",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Display Email
            Text(
              email,
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 40),

            // Sign Out Button
            ElevatedButton(
              onPressed: () async {
                await authCubit.signOut(); // Ensure sign out completes
                // Navigator.pushAndRemoveUntil(
                //   context,
                //   MaterialPageRoute(builder: (context) => const SignInPage()),
                //   (route) =>
                //       false, // Removes all previous routes including PersistentTabView
                // );
                Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (BuildContext context) {
                      return const SignInPage();
                    },
                  ),
                  (_) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "Sign Out",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
