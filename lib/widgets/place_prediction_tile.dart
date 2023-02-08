import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utransfer_user/assistants/request_assistant.dart';
import 'package:utransfer_user/global/map_key.dart';
import 'package:utransfer_user/infoHandler/app_info.dart';
import 'package:utransfer_user/widgets/progress_dialog.dart';

import '../models/directions.dart';
import '../models/predicted_places.dart';

class PlacePredictionTileDesign extends StatelessWidget
{
  final PredictedPlaces? predictedPlaces;
  
  PlacePredictionTileDesign({this.predictedPlaces});


  getPlaceDirectionDetails(String? placeId, context) async
  {
    showDialog(
        context: context,
        builder: (BuildContext context) => ProgressDialog(
          message: "Setting Up Drop-Off, Please wait",
        )
    );

    String placeDirectionDetialsUrl = "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$mapKey";

    var responseApi = await RequestAssistant.receiveRequest(placeDirectionDetialsUrl);

    Navigator.pop(context);

    if(responseApi == "Failed")
      {
        return;
      }
    if(responseApi["status"] == "OK")
      {
        Directions directions = Directions();
        directions.locationName = responseApi["result"]["name"];
        directions.locationId = placeId;
        directions.locationLatitude = responseApi["result"]["geometry"]["location"]["lat"];
        directions.locationLongitude = responseApi["result"]["geometry"]["location"]["lng"];

        Provider.of<AppInfo>(context, listen: false).updateDropOffLocationAddress(directions);

        Navigator.pop(context, "obtainedDropoff");

          //This is for testing purpose
        print("location name =" + directions.locationName!);
        print("\nlocation Long =" + directions.locationLongitude!.toString());
        print("\nlocation Lat =" + directions.locationLatitude!.toString());
      }
  }

  @override
  Widget build(BuildContext context) 
  {
    return ElevatedButton(
        onPressed: ()
            {
              getPlaceDirectionDetails(predictedPlaces!.place_id, context);
            },
      style: ElevatedButton.styleFrom(
        primary: Colors.white70
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          children: [
             const Icon(
              Icons.add_location,
              color: Colors.black,
            ),
            const SizedBox(width: 14.0,),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8.0,),
                  Text(
                    predictedPlaces!.main_text!,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16.0,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2.0,),

                  Text(
                    predictedPlaces!.secondary_text!,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12.0,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8.0,),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
