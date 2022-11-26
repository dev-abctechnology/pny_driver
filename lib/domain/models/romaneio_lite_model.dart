import 'package:pny_driver/domain/models/romaneio_model.dart';

class RomaneioLite {
  late final String id;
  late final String code;
  late final String driver;
  late final String deliveryDate;

  RomaneioLite(
      {required this.id,
      required this.code,
      required this.driver,
      required this.deliveryDate});

  RomaneioLite.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    code = json["code"];
    driver = json["data"]['slt_00005']['label'];
    deliveryDate = json["data"]['slt_00001'];
  }
}
