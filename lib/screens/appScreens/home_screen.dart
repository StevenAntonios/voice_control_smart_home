import 'package:voicecontrolsmarthome/index.dart';
import 'package:voicecontrolsmarthome/shared/cubits/auth/auth_cubit.dart'; // Make sure this imports your Constants & HomeItems widget.

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final authCubit = context.read<AuthCubit>();
    final username = authCubit.userModel.userName;
    final firstName = username.split(" ")[0];
    final formattedFirstName =
        firstName[0].toUpperCase() + firstName.substring(1).toLowerCase();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Home',
          style: Constants.twentyfoursmbold,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          children: [
            SizedBox(
              height: 75.h,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(0, 82, 142, 178).withOpacity(0.9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: IntrinsicWidth(
                  child: IntrinsicHeight(
                    child: Wrap(
                      alignment: WrapAlignment.center, // Centers content
                      spacing: 5, // Space between words
                      runSpacing: 5, // Space when wrapping
                      children: [
                        Text(
                          "Welcome",
                          style: TextStyle(
                            fontFamily: Constants.mainFont,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 21.sp,
                          ),
                        ),
                        Text(
                          formattedFirstName,
                          style: TextStyle(
                            fontFamily: Constants.mainFont,
                            color: Colors.orangeAccent, // Highlighted Name
                            fontWeight: FontWeight.bold,
                            fontSize: 22.sp,
                          ),
                        ),
                        Text(
                          "To Your Home!",
                          style: TextStyle(
                            fontFamily: Constants.mainFont,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 21.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            GridView.builder(
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10.w,
                mainAxisSpacing: 10.h,
                mainAxisExtent: 160.h,
              ),
              itemCount: Constants.roomName.length,
              itemBuilder: (BuildContext context, int index) {
                // Get the room map and extract its key (room ID) and value (room name)
                final Map<int, String> roomMap = Constants.roomName[index];
                final int roomId = roomMap.keys.first;
                final String roomName = roomMap.values.first;

                return HomeItems(
                  roomName: roomName,
                  roomImageUrl: Constants.roomImageUrlValues[index],
                  numberOfDevices:
                      '${Constants.numberOfDevicesValues[index].toString()} Devices',
                  ontab: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DevicesScreen(
                          roomName: roomName,
                          roomId: roomId,
                        ),
                      ),
                    );
                  },
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
