import 'package:firebase_auth/firebase_auth.dart';

import '../models/direction_details_info.dart';
import '../models/user_model.dart';




final FirebaseAuth fAuth = FirebaseAuth.instance;
User? currentFirebaseUser;
UserModel? userModelCurrentInfo;
List dList = []; //online-active drivers Information List
DirectionDetailsInfo? tripDirectionDetailsInfo;
String? chosenDriverId="";
String cloudMessagingServerToken = "key=AAAAVsIQ_WA:APA91bFvn0mQ6_iYVoW5iU13osQ_EpIs11gFXvJWxUpAH0VVdgeEZUG71DUjrZcd6lN0_LbgurvhgYzIMLSE3SPlZPuoaYiiiYfv3cNZAWQKVvxtCORLJ7x5eAg9CY0QjfvePAyLiRZG";
String userDropOffAddress = "";
String driverCarDetails = "";
String driverName = "";
String driverPhone = "";
double countRatingStars = 0.0;
String titleStarsRating = "";