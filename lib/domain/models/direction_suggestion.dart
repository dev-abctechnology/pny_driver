class DirectionSuggestion {
  late final List<GeocodedWaypoints> geocodedWaypoints;
  late final List<Routes> routes;
  late final String status;

  DirectionSuggestion(
      {required this.geocodedWaypoints,
      required this.routes,
      required this.status});

  DirectionSuggestion.fromJson(Map<String, dynamic> json) {
    if (json['geocoded_waypoints'] != null) {
      geocodedWaypoints = <GeocodedWaypoints>[];
      json['geocoded_waypoints'].forEach((v) {
        geocodedWaypoints.add(GeocodedWaypoints.fromJson(v));
      });
    }
    if (json['routes'] != null) {
      routes = <Routes>[];
      json['routes'].forEach((v) {
        routes.add(Routes.fromJson(v));
      });
    }
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['geocoded_waypoints'] =
        geocodedWaypoints.map((v) => v.toJson()).toList();
    data['routes'] = routes.map((v) => v.toJson()).toList();
    data['status'] = status;
    return data;
  }
}

class GeocodedWaypoints {
  late final String geocoderStatus;
  late final String placeId;
  late final List<String> types;

  GeocodedWaypoints(
      {required this.geocoderStatus,
      required this.placeId,
      required this.types});

  GeocodedWaypoints.fromJson(Map<String, dynamic> json) {
    geocoderStatus = json['geocoder_status'];
    placeId = json['place_id'];
    types = json['types'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['geocoder_status'] = geocoderStatus;
    data['place_id'] = placeId;
    data['types'] = types;
    return data;
  }
}

class Routes {
  late final Bounds bounds;
  late final String copyrights;
  late final List<Legs> legs;
  late final GooglePolyLine overviewGooglePolyLine;
  late final String summary;

  late final List<int> waypointOrder;

  Routes(
      {required this.bounds,
      required this.copyrights,
      required this.legs,
      required this.overviewGooglePolyLine,
      required this.summary,
      required this.waypointOrder});

  Routes.fromJson(Map<String, dynamic> json) {
    bounds = (json['bounds'] != null ? Bounds.fromJson(json['bounds']) : null)!;
    copyrights = json['copyrights'];
    if (json['legs'] != null) {
      legs = <Legs>[];
      json['legs'].forEach((v) {
        legs.add(Legs.fromJson(v));
      });
    }
    overviewGooglePolyLine = (json['overview_polyline'] != null
        ? GooglePolyLine.fromJson(json['overview_polyline'])
        : null)!;
    summary = json['summary'];

    waypointOrder = json['waypoint_order'].cast<int>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['bounds'] = bounds.toJson();
    data['copyrights'] = copyrights;
    data['legs'] = legs.map((v) => v.toJson()).toList();
    data['overview_polyline'] = overviewGooglePolyLine.toJson();
    data['summary'] = summary;

    data['waypoint_order'] = waypointOrder;
    return data;
  }
}

class Bounds {
  late final Northeast northeast;
  late final Northeast southwest;

  Bounds({required this.northeast, required this.southwest});

  Bounds.fromJson(Map<String, dynamic> json) {
    northeast = (json['northeast'] != null
        ? Northeast.fromJson(json['northeast'])
        : null)!;
    southwest = (json['southwest'] != null
        ? Northeast.fromJson(json['southwest'])
        : null)!;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['northeast'] = northeast.toJson();
    data['southwest'] = southwest.toJson();
    return data;
  }
}

class Northeast {
  late final double lat;
  late final double lng;

  Northeast({required this.lat, required this.lng});

  Northeast.fromJson(Map<String, dynamic> json) {
    lat = json['lat'];
    lng = json['lng'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['lat'] = lat;
    data['lng'] = lng;
    return data;
  }
}

class Legs {
  late final Distance distance;
  late final Distance duration;
  late final String endAddress;
  late final Northeast endLocation;
  late final String startAddress;
  late final Northeast startLocation;
  late final List<Steps> steps;

  Legs(
      {required this.distance,
      required this.duration,
      required this.endAddress,
      required this.endLocation,
      required this.startAddress,
      required this.startLocation,
      required this.steps});

  Legs.fromJson(Map<String, dynamic> json) {
    distance = (json['distance'] != null
        ? Distance.fromJson(json['distance'])
        : null)!;
    duration = (json['duration'] != null
        ? Distance.fromJson(json['duration'])
        : null)!;
    endAddress = json['end_address'];
    endLocation = (json['end_location'] != null
        ? Northeast.fromJson(json['end_location'])
        : null)!;
    startAddress = json['start_address'];
    startLocation = (json['start_location'] != null
        ? Northeast.fromJson(json['start_location'])
        : null)!;
    if (json['steps'] != null) {
      steps = <Steps>[];
      json['steps'].forEach((v) {
        steps.add(Steps.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['distance'] = distance.toJson();
    data['duration'] = duration.toJson();
    data['end_address'] = endAddress;
    data['end_location'] = endLocation.toJson();
    data['start_address'] = startAddress;
    data['start_location'] = startLocation.toJson();
    data['steps'] = steps.map((v) => v.toJson()).toList();
    return data;
  }
}

class Distance {
  late final String text;
  late final int value;

  Distance({required this.text, required this.value});

  Distance.fromJson(Map<String, dynamic> json) {
    text = json['text'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['text'] = text;
    data['value'] = value;
    return data;
  }
}

class Steps {
  late final Distance distance;
  late final Distance duration;
  late final Northeast endLocation;
  late final String htmlInstructions;
  late final GooglePolyLine polyline;
  late final Northeast startLocation;
  late final String travelMode;

  Steps(
      {required this.distance,
      required this.duration,
      required this.endLocation,
      required this.htmlInstructions,
      required this.polyline,
      required this.startLocation,
      required this.travelMode});

  Steps.fromJson(Map<String, dynamic> json) {
    distance = (json['distance'] != null
        ? Distance.fromJson(json['distance'])
        : null)!;
    duration = (json['duration'] != null
        ? Distance.fromJson(json['duration'])
        : null)!;
    endLocation = (json['end_location'] != null
        ? Northeast.fromJson(json['end_location'])
        : null)!;
    htmlInstructions = json['html_instructions'];
    polyline = (json['polyline'] != null
        ? GooglePolyLine.fromJson(json['polyline'])
        : null)!;
    startLocation = (json['start_location'] != null
        ? Northeast.fromJson(json['start_location'])
        : null)!;
    travelMode = json['travel_mode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['distance'] = distance.toJson();
    data['duration'] = duration.toJson();
    data['end_location'] = endLocation.toJson();
    data['html_instructions'] = htmlInstructions;
    data['polyline'] = polyline.toJson();
    data['start_location'] = startLocation.toJson();
    data['travel_mode'] = travelMode;
    return data;
  }
}

class GooglePolyLine {
  late final String points;

  GooglePolyLine({required this.points});

  GooglePolyLine.fromJson(Map<String, dynamic> json) {
    points = json['points'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['points'] = points;
    return data;
  }
}
