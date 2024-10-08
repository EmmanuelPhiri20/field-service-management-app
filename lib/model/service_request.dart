class ServiceRequest {
  final String id;
  final String category;
  final String description;
  final String status;
  final String date;
  final String time;
  final String imageUrl;

  ServiceRequest({
    required this.id,
    required this.category,
    required this.description,
    required this.status,
    required this.date,
    required this.time,
    required this.imageUrl,
  });
}
