import 'package:voicecontrolsmarthome/index.dart';
import 'package:voicecontrolsmarthome/screens/appScreens/options_screen.dart';
import 'package:voicecontrolsmarthome/shared/cubits/auth/auth_cubit.dart';
import 'package:voicecontrolsmarthome/shared/widgets/app_widgets/custom_nav_bar.dart';

class MainLayout extends StatelessWidget {
  const MainLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final authCubit = context.read<AuthCubit>();

    return PersistentTabView(
      key: ValueKey(
          authCubit.currentUser?.uid), // Ensure UI rebuilds for new user
      tabs: [
        PersistentTabConfig(
          screen:  HomeScreen(),
          item: ItemConfig(
            icon: const Icon(Icons.home),
            title: "Home",
          ),
        ),
        PersistentTabConfig(
          screen: const VoiceControlScreen(),
          item: ItemConfig(
            icon: const Icon(Icons.mic),
            title: "Command",
          ),
        ),
        PersistentTabConfig(
          screen: const OptionsScreen(),
          item: ItemConfig(
            icon: const Icon(Icons.person),
            title: "Profile",
          ),
        ),
      ],
      navBarBuilder: (navBarConfig) => CustomNavBar(
        navBarConfig: navBarConfig,
      ),
    );
  }
}
