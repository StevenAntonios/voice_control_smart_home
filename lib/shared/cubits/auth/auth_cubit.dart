import 'dart:developer';

import 'package:voicecontrolsmarthome/index.dart';
import 'package:voicecontrolsmarthome/models/userModel.dart';
part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());
  static AuthCubit get(context) => BlocProvider.of(context);
  final _auth = FirebaseAuth.instance;
  final _database = FirebaseFirestore.instance;
  late UserModel userModel;

 Future<User?> register({
  required String username,
  required String email,
  required String password,
}) async {
  emit(RegisterLoading());
  try {
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    UserModel user = UserModel(
      userID: userCredential.user!.uid,
      email: email,
      userName: username,
    );

    await _database.collection("users").doc(user.userID).set(user.toMap());

    emit(RegisterSuccess());
    return userCredential.user;
  } on FirebaseAuthException catch (e) {
    log("FirebaseAuthException: ${e.code}");
    if (e.code == 'email-already-in-use') {
      emit(RegisterFailed(message: 'Email is already in use.'));
    } else if (e.code == 'invalid-email') {
      emit(RegisterFailed(message: 'Invalid email format.'));
    } else if (e.code == 'weak-password') {
      emit(RegisterFailed(message: 'The password is too weak.'));
    } else {
      emit(RegisterFailed(message: 'An unexpected error occurred.'));
    }
    return null;
  } catch (e) {
    log("Unexpected Error: $e");
    emit(RegisterFailed(message: 'Registration failed. Please try again.'));
    return null;
  }
}


Future<void> login({required String email, required String password}) async {
  emit(LoginLoading());
  try {
    UserCredential userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Fetch user data from Firestore
    DocumentSnapshot userDoc = await _database.collection("users").doc(userCredential.user!.uid).get();

    if (userDoc.exists) {
      userModel = UserModel.fromJson(userDoc.data() as Map<String, dynamic>);
      emit(LoginSuccess(userModel.userName));  // Pass username to state
    } else {
      emit(LoginFailed());
    }
  } catch (e) {
    emit(LoginFailed());
    log("Login Failed: $e");
  }
}

  // Sign Out
  Future<void> signOut() async {
  await _auth.signOut();
  
  // Reset user data
  userModel = UserModel(userID: "", email: "", userName: "");
  
  emit(AuthInitial()); // Reset authentication state
}

  // Get current user
  User? get currentUser => _auth.currentUser;
}
