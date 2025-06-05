import 'package:voicecontrolsmarthome/index.dart';

class CustomBottomBar extends StatelessWidget {
  const CustomBottomBar({
    super.key,
    required this.text,
    this.onTab,
    required this.auth,
    required this.builder,
  });
  final String text;
  final VoidCallback? onTab;
  final String auth;
 final Widget Function(BuildContext) builder;
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(
        text,
        style: Constants.forteenmid,
      ),
      TextButton(
        child: Text(
          auth,
          style: Constants.forteensmbold,
        ),
        onPressed: () {
          print('hsfskfs ');
          Navigator.push(
              context, MaterialPageRoute(builder: builder));
          onTab;
        },
      )
    ]);
  }
}
