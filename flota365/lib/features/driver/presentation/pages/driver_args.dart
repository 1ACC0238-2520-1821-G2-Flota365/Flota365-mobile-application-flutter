class DriverArgs {
  final String driverId;
  final String? email;
  final String? fullName;

  const DriverArgs({
    required this.driverId,
    this.email,
    this.fullName,
  });
}