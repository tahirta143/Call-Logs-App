class ServiceData {
  final String? id;
  final String? serviceName;
  final String? durationTime;
  final String? rate;
  final String? status;

  ServiceData({
    this.id,
    this.serviceName,
    this.durationTime,
    this.rate,
    this.status,
  });

  factory ServiceData.fromJson(Map<String, dynamic> json) {
    return ServiceData(
      id: (json['id'] ?? json['_id'] ?? json['uuid'])?.toString(),
      serviceName: (json['service_name'] ?? json['serviceName'] ?? json['name'])?.toString(),
      durationTime: (json['duration_time'] ?? json['durationTime'])?.toString(),
      rate: json['rate']?.toString(),
      status: json['status']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serviceName': serviceName,
      'durationTime': durationTime,
      'rate': rate,
      'status': status,
    };
  }
}
