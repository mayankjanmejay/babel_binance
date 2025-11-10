/// Represents a cryptocurrency pair being watched for trading signals
class WatchlistItem {
  final String id;
  final String userId;
  final String symbol;
  final double? targetBuy;
  final double? targetSell;
  final bool active;
  final DateTime createdAt;

  WatchlistItem({
    required this.id,
    required this.userId,
    required this.symbol,
    this.targetBuy,
    this.targetSell,
    required this.active,
    required this.createdAt,
  });

  factory WatchlistItem.fromJson(Map<String, dynamic> json) {
    return WatchlistItem(
      id: json['\$id'] ?? json['id'] ?? '',
      userId: json['user_id'] ?? '',
      symbol: json['symbol'] ?? '',
      targetBuy: json['target_buy']?.toDouble(),
      targetSell: json['target_sell']?.toDouble(),
      active: json['active'] ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'symbol': symbol,
      'target_buy': targetBuy,
      'target_sell': targetSell,
      'active': active,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
