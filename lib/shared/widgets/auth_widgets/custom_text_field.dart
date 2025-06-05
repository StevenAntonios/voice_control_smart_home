
import 'package:voicecontrolsmarthome/index.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField(
      {super.key,
      required this.title,
      required this.hintText,
      this.validator,
      required this.keyboardType,
      this.obsecureText = false,
      this.onChanged,
      this.controller});
  final String title;
  final String hintText;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final TextInputType keyboardType;
  final bool? obsecureText;
  final FormFieldValidator<String>? onChanged;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 51.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 8.w,
          ),
          Text(
            title,
            style: Constants.titleColor,
          ),
          SizedBox(
            height: 8.h,
          ),
          Container(
            height: 46.h,
            decoration: BoxDecoration(
              color: Color(0xffD3D3D3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black),
              boxShadow: [
                BoxShadow(
                  blurRadius: 4,
                ),
              ],
            ),
            child: TextFormField(
              controller: controller,
              onChanged: onChanged,
              keyboardType: keyboardType,
              obscureText: obsecureText!,
              validator: validator,
              decoration: InputDecoration(
                //Set the error text color
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.red),
                ),
                contentPadding: EdgeInsets.fromLTRB(16, 12, 16, 14),
                hintText: hintText,
                hintStyle: Constants.hintStyle,
              ),
            ),
          )
        ],
      ),
    );
  }
}
