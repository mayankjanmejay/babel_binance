/// Represents a completed trade for database storage
class TradeRecord {
  final String? id;
  final String userId;
  final String symbol;
  final String side;
  final double quantity;
  final double price;
  final double totalValue;
  final DateTime timestamp;
  final String algorithmName;
  final String? orderId;
  final String status; // 'SUCCESS', 'FAILED', 'PENDING'

  TradeRecord({
    this.id,
    required this.userId,
    required this.symbol,
    required this.side,
    required this.quantity,
    required this.price,
    required this.totalValue,
    required this.timestamp,
    required this.algorithmName,
    this.orderId,
    this.status = 'SUCCESS',
  });

  factory TradeRecord.fromJson(Map<String, dynamic> json) {
    return TradeRecord(
      id: json['\$id'] ?? json['id'],
      userId: json['user_id'] ?? '',
      symbol: json['symbol'] ?? '',
      side: json['side'] ?? '',
      quantity: (json['quantity'] ?? 0).toDouble(),
      price: (json['price'] ?? 0).toDouble(),
      totalValue: (json['total_value'] ?? 0).toDouble(),
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      algorithmName: json['algorithm_name'] ?? '',
      orderId: json['order_id'],
      status: json['status'] ?? 'SUCCESS',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'symbol': symbol,
      'side': side,
      'quantity': quantity,
      'price': price,
      'total_value': totalValue,
      'timestamp': timestamp.toIso8601String(),
      'algorithm_name': algorithmName,
      'order_id': orderId,
      'status': status,
    };
  }
}
