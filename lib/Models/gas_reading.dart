class GasReading {
  final int id;
  final int idAlat;
  final double nilai;
  final DateTime createdAt;

  GasReading({
    required this.id,
    required this.idAlat,
    required this.nilai,
    required this.createdAt,
  });

  factory GasReading.fromJson(Map<String, dynamic> json) {
    return GasReading(
      id: json['id_humidity'] ??
          json['id_temp'],
      idAlat: json['id_alat'],
      nilai: (json['nilai_humidity'] ??
              json['nilai_suhu'])
          .toDouble(),
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class ApiResponse {
  final List<GasReading> humidity;
  final List<GasReading> temperature;

  ApiResponse({
    required this.humidity,
    required this.temperature,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      humidity: (json['humidity'] as List)
          .map((i) => GasReading.fromJson(i))
          .toList(),
      temperature: (json['Temperature'] as List)
          .map((i) => GasReading.fromJson(i))
          .toList(),
    );
  }
}
