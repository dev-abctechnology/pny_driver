class SeletorT {
  late final String label;
  late final String value;

  SeletorT({required this.label, required this.value});

  SeletorT.fromJson(Map<String, dynamic> json) {
    label = json["label"];
    value = json["value"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["label"] = label;
    data["value"] = value;
    return data;
  }
}
