// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:pny_driver/domain/models/direction_suggestion.dart';
import 'package:pny_driver/domain/models/romaneio_custom_api_model.dart';
import 'package:pny_driver/domain/models/romaneio_model.dart';

class RomaneioGeneral {
  DirectionSuggestion directionSuggestion;
  DateTime date;
  Romaneio romaneio;
  String destination;
  List<RomaneioEntregue> romaneiosEntregues;

  RomaneioGeneral({
    required this.directionSuggestion,
    required this.date,
    required this.romaneio,
    required this.romaneiosEntregues,
    required this.destination,
  });

  RomaneioGeneral copyWith({
    DirectionSuggestion? directionSuggestion,
    DateTime? date,
    Romaneio? romaneio,
    Set<Marker>? markers,
    Set<Polyline>? polylines,
    List<RomaneioEntregue>? romaneiosEntregues,
    String? destination,
  }) {
    return RomaneioGeneral(
      directionSuggestion: directionSuggestion ?? this.directionSuggestion,
      date: date ?? this.date,
      romaneio: romaneio ?? this.romaneio,
      romaneiosEntregues: romaneiosEntregues ?? this.romaneiosEntregues,
      destination: destination ?? this.destination,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'directionSuggestion': directionSuggestion.toJson(),
      'date': date.millisecondsSinceEpoch,
      'romaneio': romaneio.toJson(),
      'romaneiosEntregues': romaneiosEntregues.map((x) => x.toMap()).toList(),
      'destination': destination,
    };
  }

  factory RomaneioGeneral.fromMap(Map<String, dynamic> map) {
    return RomaneioGeneral(
      directionSuggestion: DirectionSuggestion.fromJson(
          map['directionSuggestion'] as Map<String, dynamic>),
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      romaneio: Romaneio.fromJson(map['romaneio'] as Map<String, dynamic>),
      romaneiosEntregues: List<RomaneioEntregue>.from(
        (map['romaneiosEntregues'] as List).map<RomaneioEntregue>(
          (x) => RomaneioEntregue.fromMap(x as Map<String, dynamic>),
        ),
      ),
      destination: map['destination'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory RomaneioGeneral.fromJson(String source) =>
      RomaneioGeneral.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'directionSuggestion: $directionSuggestion, date: $date, romaneio: $romaneio, romaneiosEntregues: $romaneiosEntregues, destination: $destination';
  }

  @override
  bool operator ==(covariant RomaneioGeneral other) {
    if (identical(this, other)) return true;

    return other.directionSuggestion == directionSuggestion &&
        other.date == date &&
        other.romaneio == romaneio &&
        listEquals(other.romaneiosEntregues, romaneiosEntregues) &&
        other.destination == destination;
  }

  @override
  int get hashCode {
    return directionSuggestion.hashCode ^
        date.hashCode ^
        romaneio.hashCode ^
        romaneiosEntregues.hashCode ^
        destination.hashCode;
  }
}
