class Client {
  final String id;
  final String name;
  final String? email;
  final String? phone;
  final String? company;
  final String status;
  final double monthly_payment;
  final int? payment_day;
  final DateTime? contract_start;
  final DateTime? contract_end;

  Client({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.company,
    required this.status,
    required this.monthly_payment,
    this.payment_day,
    this.contract_start,
    this.contract_end,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      company: json['company'],
      status: json['status'] ?? 'ativo',
      monthly_payment: double.parse(json['monthly_payment'].toString()),
      payment_day: json['payment_day'],
      contract_start: json['contract_start'] != null 
          ? DateTime.parse(json['contract_start']) 
          : null,
      contract_end: json['contract_end'] != null 
          ? DateTime.parse(json['contract_end']) 
          : null,
    );
  }
}
