class BodyOverview {
  final int heightCm;
  final double weightKg;
  final double bmi;

  const BodyOverview({
    required this.heightCm,
    required this.weightKg,
    required this.bmi,
  });

  factory BodyOverview.fromJson(Map<String, dynamic> json) {
    return BodyOverview(
      heightCm: json['heightCm'] as int,
      weightKg: (json['weightKg'] as num).toDouble(),
      bmi: (json['bmi'] as num).toDouble(),
    );
  }
}
