class ControlState {
  final String message;
  final bool isActive;

  ControlState({
    required this.message,
    required this.isActive,
  });

  factory ControlState.fromJson(dynamic json) {
    return ControlState(
      message: json[0], // Pesan, contoh: "Data pompa berhasil di hidupkan"
      isActive: json['status'] == 1, // Status: 1 = aktif, 0 = mati
    );
  }
}
