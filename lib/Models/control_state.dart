class ControlState {
  final bool isPumpActive;

  ControlState({required this.isPumpActive});

  // Method untuk parsing dari JSON
  factory ControlState.fromJson(Map<String, dynamic> json) {
    return ControlState(
      isPumpActive: json['is_pump_active'], // Sesuaikan key dengan API
    );
  }

  // Method untuk mengonversi model ke JSON (jika diperlukan)
  Map<String, dynamic> toJson() {
    return {
      'is_pump_active': isPumpActive,
    };
  }
}
