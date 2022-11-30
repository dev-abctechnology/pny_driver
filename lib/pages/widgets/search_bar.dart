import 'dart:convert';
import 'package:dio/dio.dart';

import '../../shared/enviroment.dart';

class PlaceService {
  Dio api;

  PlaceService(this.api);

  Future getPlace(String input) async {
    if (input.isNotEmpty) {
      String url =
          "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$apiKey&language=pt-BR&components=country:br";

      Response response = await api.get(url);
      if (response.statusCode == 200) {
        var jsonData = response.data;
        var status = jsonData["status"];
        if (status == "OK") {
          var predictions = jsonData["predictions"];
          List<PlacePrediction> placePredictions = [];
          for (var i = 0; i < predictions.length; i++) {
            placePredictions.add(PlacePrediction(
                predictions[i]["place_id"], predictions[i]["description"]));
          }
          return placePredictions;
        }
      }
    }

    return null;
  }
}

class PlacePrediction {
  String placeId;
  String description;

  PlacePrediction(this.placeId, this.description);
}
