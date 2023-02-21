import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:utransfer_user/assistants/request_assistant.dart';
import 'package:utransfer_user/global/global.dart';
import 'package:utransfer_user/global/map_key.dart';
import 'package:utransfer_user/infoHandler/app_info.dart';
import 'package:utransfer_user/models/direction_details_info.dart';
import 'package:utransfer_user/models/directions.dart';
import 'package:utransfer_user/models/trips_history_model.dart';
import 'package:utransfer_user/models/user_model.dart';
import 'package:http/http.dart' as http;

class AssistantMethods
{
  static Future<String> searchAddressForGeographicCoOrdinated(Position position, context) async
  {
    String apiUrl = "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey";
    String humanReadableAddress = "";

    var requestResponse = await RequestAssistant.receiveRequest(apiUrl);
    if(requestResponse != "Failed")
      {
        humanReadableAddress = requestResponse["results"][0]["formatted_address"];

        Directions userPickUpAddress = Directions();
        userPickUpAddress.locationLatitude = position.latitude;
        userPickUpAddress.locationLongitude = position.longitude;
        userPickUpAddress.locationName = humanReadableAddress;

        Provider.of<AppInfo>(context, listen: false).updatePickUpLocationAddress(userPickUpAddress);
      }


    return humanReadableAddress;
  }


  static void readCurrentOnlineUserInfo() async
  {
    currentFirebaseUser = fAuth.currentUser;

    DatabaseReference userRef = FirebaseDatabase.instance
        .ref()
        .child("users")
        .child(currentFirebaseUser!.uid);

    userRef.once().then((snap)
    {
      if(snap.snapshot.value != null)
        {
          userModelCurrentInfo = UserModel.fromSnapshot(snap.snapshot);
          //This is only for testing purpose
          //print("name = " + userModelCurrentInfo!.name.toString());
          //print("email = " + userModelCurrentInfo!.email.toString());
        }
    });
  }

  static Future<DirectionDetailsInfo?> obtainOriginToDestinationDirectionDetails(LatLng originPosition, LatLng destinationPosition) async
  {
    String urlOriginToDestinationDirectionDetails = "https://maps.googleapis.com/maps/api/directions/json?origin=${originPosition.latitude},${originPosition.longitude}&destination=${destinationPosition.latitude},${destinationPosition.longitude}&key=$mapKey";

    var responseDirectionApi = await RequestAssistant.receiveRequest(urlOriginToDestinationDirectionDetails);

    if(responseDirectionApi == "Failed")
      {
        return null;
      }

    DirectionDetailsInfo directionDetailsInfo = DirectionDetailsInfo();
    directionDetailsInfo.e_points = responseDirectionApi["routes"][0]["overview_polyline"]["points"];

    directionDetailsInfo.distance_text = responseDirectionApi["routes"][0]["legs"][0]["distance"]["text"];
    directionDetailsInfo.distance_value = responseDirectionApi["routes"][0]["legs"][0]["distance"]["value"];

    directionDetailsInfo.duration_text = responseDirectionApi["routes"][0]["legs"][0]["duration"]["text"];
    directionDetailsInfo.duration_value = responseDirectionApi["routes"][0]["legs"][0]["duration"]["value"];

    return directionDetailsInfo;
  }
  static double calculateFareAmountFromOriginToDestination(DirectionDetailsInfo directionDetailsInfo)
  {
    double timeTraveledFareAmountPerMinute = (directionDetailsInfo.duration_value! / 60) * 0.1;
    double distanceTraveledFareAmountPerKilometer = (directionDetailsInfo.duration_value! / 1000) * 0.1;

    //USD
    double totalFareAmount = timeTraveledFareAmountPerMinute + distanceTraveledFareAmountPerKilometer;

    return double.parse(totalFareAmount.toStringAsFixed(1));
  }

  static sentNotificationToDriverNow(String deviceRegistrationToken, String userRideRequestId, context)  async
  {
    String destinationAddress = userDropOffAddress;
    //var destinationAddress = Provider.of<AppInfo>(context, listen: false).userDropOffLocation;

    Map<String, String> headerNotification =
    {
      'Content-Type': 'application/json',
      'Authorization': cloudMessagingServerToken,
    };

    Map bodyNotification =
    {
      "body":"Destination Address: \n$destinationAddress.",
      "title":"New Trip Request"
    };

    Map dataMap =
    {
      "click_action": "FLUTTER_NOTIFICATION_CLICK",
      "id": "1",
      "status": "done",
      "rideRequestId": userRideRequestId
    };

    Map officialNotificationFormat =
    {
      "notification": bodyNotification,
      "data": dataMap,
      "priority": "high",
      "to": deviceRegistrationToken,
    };

    var responseNotification = http.post(
      Uri.parse("https://fcm.googleapis.com/fcm/send"),
      headers: headerNotification,
      body: jsonEncode(officialNotificationFormat),
    );

  }

  //retrieve the trip keys for online user
//trip key = ride request key
  static void readTripsKeysForOnlineUser(context)
  {
  FirebaseDatabase.instance.ref()
      .child("All Ride Requests")
      .orderByChild("userName")
      .equalTo(userModelCurrentInfo!.name)
      .once()
      .then((snap)
  {
    if(snap.snapshot.value != null)
      {
        Map keysTripsId = snap.snapshot.value as Map;
        int overAllTripsCounter = keysTripsId.length;

        //Count total trips and share it with Provider
        Provider.of<AppInfo>(context, listen: false).updateOverAllTripsCounter(overAllTripsCounter);

        //Share trip keys with Provider
        List<String> tripsKeyList = [];
        keysTripsId.forEach((key, value)
        {
          tripsKeyList.add(key);
        });
        Provider.of<AppInfo>(context, listen: false).updateOverAllTripsKeys(tripsKeyList);

        //get trips key data - read trips complete information
        readTripsHistoryInformation(context);

      }
  });
}

  static void readTripsHistoryInformation(context)
  {
    var tripsAllKeys =  Provider.of<AppInfo>(context, listen: false).historyTripsKeysList;

    for(String eachKey in tripsAllKeys)
      {
        FirebaseDatabase.instance.ref()
            .child("All Ride Requests")
            .child(eachKey)
            .once()
            .then((snap)
        {
          var eachTripHistory =  TripsHistoryModel.fromSnapshot(snap.snapshot);

          if((snap.snapshot.value as Map)["status"] == "ended")
            {
              //Update-add each history to OverAllTrips History Data List
              Provider.of<AppInfo>(context, listen: false).updateOverAllTripsHistoryInformation(eachTripHistory);
            }

        });

      }
  }
}