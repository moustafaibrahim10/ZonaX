import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/zone_entity.dart';

part 'zone_model.g.dart'; 

@JsonSerializable()
class ZoneModel extends ZoneEntity {
  
  const ZoneModel({
    required String id,
    @JsonKey(name: 'latitude') required double lat,    // بنقوله خد latitude من الـ JSON وحطها في lat
    @JsonKey(name: 'longitude') required double lng,   // بنقوله خد longitude من الـ JSON وحطها في lng
    @JsonKey(name: 'intensity') required int demandLevel, // بنقوله خد intensity من الـ JSON وحطها في demandLevel
  }) : super(
          id: id,
          lat: lat,
          lng: lng,
          demandLevel: demandLevel,
        );

  factory ZoneModel.fromJson(Map<String, dynamic> json) => _$ZoneModelFromJson(json);

  Map<String, dynamic> toJson() => _$ZoneModelToJson(this);
}