class UserModel {
  late String userID;
  late String email;
  late String userName;
  UserModel({
    required this.userID,
    required this.email,
    required this.userName,
  });
  UserModel.fromJson(Map<String, dynamic> json) {
    email = json['email'];
    userName = json['userName'];
    userID = json['userID'];
  }
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'userName': userName,
      'userID': userID,
    };
  }
}
