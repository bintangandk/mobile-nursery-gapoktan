// Model class to represent a single ph record
class HourlyPh {
  final int hour;
  final double averagePhtanah;

  HourlyPh({required this.hour, required this.averagePhtanah});

  factory HourlyPh.fromJson(Map<String, dynamic> json) {
    return HourlyPh(
      hour: json['hour'],
      averagePhtanah: (json['average_phtanah'] ?? 0.0).toDouble(),
    );
  }
}

// Model class to represent a list of ph records
class PhData {
  final List<HourlyPh> ph_tanah;

  PhData({required this.ph_tanah});

  // Factory method to create an instance from JSON
  factory PhData.fromJson(List<dynamic> json) {
    List<HourlyPh> ph =
        json.map((ph) => HourlyPh.fromJson(ph)).toList();
    return PhData(ph_tanah: ph);
  }
}
