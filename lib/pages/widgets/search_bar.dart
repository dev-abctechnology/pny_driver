import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../shared/enviroment.dart';

class PlaceService {
  static const _baseUrl =
      'https://maps.googleapis.com/maps/api/place/autocomplete/json';
  static final String _apiKey = apiKey;

  final Dio _api;

  PlaceService(this._api);

  Future<List<PlacePrediction>> getPlace({required String searchText}) async {
    try {
      final url =
          '$_baseUrl?input=$searchText&key=$_apiKey&language=pt-BR&components=country:br';

      final response = await _api.get(url);
      if (response.statusCode == 200) {
        final jsonData = response.data;
        final status = jsonData['status'];

        if (status == 'OK') {
          final predictions = jsonData['predictions'] as List<dynamic>;
          final placePredictions = predictions
              .map((prediction) => PlacePrediction.fromJson(prediction))
              .toList();

          return placePredictions;
        }
      }
    } on DioError catch (e) {
      // Handle network errors
      debugPrint('Error fetching place predictions: $e');
    }

    return [];
  }
}

class PlacePrediction {
  final String placeId;
  final String description;

  PlacePrediction({required this.placeId, required this.description});

  factory PlacePrediction.fromJson(Map<String, dynamic> json) {
    return PlacePrediction(
      placeId: json['place_id'] as String,
      description: json['description'] as String,
    );
  }
}
