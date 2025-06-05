import 'package:voicecontrolsmarthome/index.dart';

class CustomElevatedButton extends StatelessWidget {
  const CustomElevatedButton({
    super.key,
    required this.buttonName,
    required this.onTab,
  });
  final String buttonName;
  final VoidCallback onTab;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTab,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 51.0.w),
        child: Container(
          height: 46.h,
          width: 288.w,
          decoration: BoxDecoration(
            color: Constants.mainColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              buttonName,
              style: Constants.eighteenmid,
            ),
          ),
        ),
      ),
    );
  }
}
