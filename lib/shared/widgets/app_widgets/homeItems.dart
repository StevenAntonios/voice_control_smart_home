import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

class HomeItems extends StatelessWidget {
  const HomeItems({
    super.key,
    required this.roomName,
    required this.roomImageUrl,
    required this.numberOfDevices,
    required this.ontab,
  });
  final String roomName;
  final String roomImageUrl;
  final String numberOfDevices;
  final VoidCallback ontab;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ontab,
      child: Container(
        height: 160.h,
        width: 180.w,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                blurRadius: 5,
                spreadRadius: 5,
                color: Colors.grey.withOpacity(0.5),
              )
            ]),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Text(
              roomName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24.sp,
              ),
            ),
            SizedBox(
              height: 10.h,
            ),
            SvgPicture.asset(
              roomImageUrl,
              height: 65.h,
              width: 70.w,
            ),
            SizedBox(
              height: 10.h,
            ),
            Text(
              numberOfDevices,
              style: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 22.sp,
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
