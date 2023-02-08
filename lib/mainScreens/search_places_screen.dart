import 'package:flutter/material.dart';
import 'package:utransfer_user/assistants/request_assistant.dart';
import 'package:utransfer_user/global/map_key.dart';
import 'package:utransfer_user/models/predicted_places.dart';
import 'package:utransfer_user/widgets/place_prediction_tile.dart';

class SearchPlacesScreen extends StatefulWidget
{


  @override
  _SearchPlacesScreenState createState() => _SearchPlacesScreenState();
}

class _SearchPlacesScreenState extends State<SearchPlacesScreen>
{
  List<PredictedPlaces> placePredictedList = [];

  void findPlaceAutoCompleteSearch(String inputText) async
  {
    if(inputText.length > 1)
      {
        String urlAutoCompleteSearch = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$inputText&key=$mapKey&components=country:GR";

       var responseAutoCompleteSearch = await RequestAssistant.receiveRequest(urlAutoCompleteSearch);

       if(responseAutoCompleteSearch == "Failed")
         {
           return;
         }
       if(responseAutoCompleteSearch["status"] == "OK")
         {
           var placePredictions = responseAutoCompleteSearch["predictions"];

           var placePredictionsList = (placePredictions as List).map((jsonData) => PredictedPlaces.fromJson(jsonData)).toList();

           setState(() {
             placePredictedList = placePredictionsList;
           });

         }
      }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Search place UI
          Container(
            height: 180,
            decoration: const BoxDecoration(
              color: Colors.lightBlueAccent,
              boxShadow: [
                BoxShadow(
                  color: Colors.white,
                  blurRadius: 8,
                  spreadRadius: 0.5,
                  offset: Offset(
                    0.7,
                    0.7
                  ),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                children: [

                  const SizedBox(height: 25.0,),

                  Stack(
                    children: [
                      GestureDetector(
                        onTap: ()
                          {
                            Navigator.pop(context);
                          },
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.black,
                        ),
                      ),

                      const Center(
                        child: Text(
                          "Search and Set DropOff Location",
                          style: TextStyle(
                            fontSize: 18.0,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16.0,),

                  Row(
                    children: [

                      const Icon(
                        Icons.adjust_sharp,
                        color: Colors.black,
                      ),

                      const SizedBox(width: 18.0,),

                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            onChanged: (valueTyped)
                            {
                              findPlaceAutoCompleteSearch(valueTyped);
                            },
                            decoration: const InputDecoration(
                              hintText: "Search here...",
                              fillColor: Colors.white,
                              filled: true,
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.only(
                                left: 11.0,
                                top: 8.0,
                                bottom: 8.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          //display place predictions result
            (placePredictedList.length > 0)
              ? Expanded(
                child: ListView.separated(
               itemCount: placePredictedList.length,
                physics: ClampingScrollPhysics(),
               itemBuilder: (context, index)
              {
                return PlacePredictionTileDesign(
                  predictedPlaces: placePredictedList[index],
                );
              },
              separatorBuilder: (BuildContext context, int index)
              {
                return const Divider(
                  height: 1.0,
                  color: Colors.black,
                  thickness: 1,
                );
              },
            ),
            
          )
              : Container(),
        ],
      ),
    );
  }
}
