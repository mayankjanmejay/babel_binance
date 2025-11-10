import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import '../models/trade_record.dart';

/// Email notification service
/// Supports SendGrid and SMTP
class EmailService {
  final Logger _log = Logger('EmailService');

  final String provider; // 'sendgrid' or 'smtp'
  final String apiKey;
  final String fromEmail;
  final String fromName;
  final String toEmail;

  EmailService({
    required this.provider,
    required this.apiKey,
    required this.fromEmail,
    required this.fromName,
    required this.toEmail,
  });

  /// Send email via SendGrid
  Future<bool> _sendViaSendGrid({
    required String subject,
    required String htmlContent,
    required String textContent,
  }) async {
    final url = Uri.parse('https://api.sendgrid.com/v3/mail/send');

    final body = {
      'personalizations': [
        {
          'to': [
            {'email': toEmail}
          ],
          'subject': subject,
        }
      ],
      'from': {
        'email': fromEmail,
        'name': fromName,
      },
      'content': [
        {'type': 'text/plain', 'value': textContent},
        {'type': 'text/html', 'value': htmlContent},
      ],
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 202) {
        _log.info('📧 Email sent successfully via SendGrid');
        return true;
      } else {
        _log.warning('Failed to send email: ${response.statusCode} ${response.body}');
        return false;
      }
    } catch (e) {
      _log.severe('Error sending email: $e');
      return false;
    }
  }

  /// Send generic email
  Future<bool> sendEmail({
    required String subject,
    required String htmlContent,
    required String textContent,
  }) async {
    if (provider == 'sendgrid') {
      return await _sendViaSendGrid(
        subject: subject,
        htmlContent: htmlContent,
        textContent: textContent,
      );
    } else {
      _log.warning('Email provider "$provider" not supported yet');
      return false;
    }
  }

  /// Send trade notification
  Future<bool> notifyTradeExecuted(TradeRecord trade) async {
    final subject = '🤖 Trade Executed: ${trade.symbol} ${trade.side}';

    final emoji = trade.side == 'BUY' ? '🟢' : '🔴';
    final textContent = '''
$emoji Trade Executed

Symbol: ${trade.symbol}
Side: ${trade.side}
Quantity: ${trade.quantity}
Price: \$${trade.price.toStringAsFixed(2)}
Total Value: \$${trade.totalValue.toStringAsFixed(2)}
Algorithm: ${trade.algorithmName}
Status: ${trade.status}
Time: ${trade.timestamp.toString()}
    ''';

    final htmlContent = '''
<!DOCTYPE html>
<html>
<head>
    <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
        .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 20px; border-radius: 10px 10px 0 0; }
        .content { background: #f9f9f9; padding: 20px; border-radius: 0 0 10px 10px; }
        .trade-card { background: white; padding: 15px; border-radius: 8px; margin: 15px 0; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .label { color: #666; font-size: 12px; text-transform: uppercase; }
        .value { font-size: 18px; font-weight: bold; margin: 5px 0; }
        .buy { color: #10b981; }
        .sell { color: #ef4444; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>$emoji Trade Executed</h1>
        </div>
        <div class="content">
            <div class="trade-card">
                <div class="label">Symbol</div>
                <div class="value">${trade.symbol}</div>
            </div>
            <div class="trade-card">
                <div class="label">Side</div>
                <div class="value ${trade.side.toLowerCase()}">${trade.side}</div>
            </div>
            <div class="trade-card">
                <div class="label">Quantity</div>
                <div class="value">${trade.quantity}</div>
            </div>
            <div class="trade-card">
                <div class="label">Price</div>
                <div class="value">\$${trade.price.toStringAsFixed(2)}</div>
            </div>
            <div class="trade-card">
                <div class="label">Total Value</div>
                <div class="value">\$${trade.totalValue.toStringAsFixed(2)}</div>
            </div>
            <div class="trade-card">
                <div class="label">Algorithm</div>
                <div class="value">${trade.algorithmName}</div>
            </div>
            <p style="text-align: center; color: #666; margin-top: 20px;">
                ${trade.timestamp.toString()}
            </p>
        </div>
    </div>
</body>
</html>
    ''';

    return await sendEmail(
      subject: subject,
      htmlContent: htmlContent,
      textContent: textContent,
    );
  }

  /// Send stop-loss alert
  Future<bool> notifyStopLoss({
    required String symbol,
    required double entryPrice,
    required double exitPrice,
    required double loss,
    required double lossPercent,
  }) async {
    final subject = '🛑 Stop-Loss Triggered: $symbol';

    final textContent = '''
🛑 Stop-Loss Triggered

Symbol: $symbol
Entry Price: \$${entryPrice.toStringAsFixed(2)}
Exit Price: \$${exitPrice.toStringAsFixed(2)}
Loss: \$${loss.toStringAsFixed(2)} (${lossPercent.toStringAsFixed(2)}%)

Your position has been automatically closed to limit losses.
    ''';

    final htmlContent = '''
<!DOCTYPE html>
<html>
<head>
    <style>
        body { font-family: Arial, sans-serif; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
        .alert { background: #fee2e2; color: #991b1b; padding: 20px; border-radius: 8px; border-left: 4px solid #ef4444; }
        .alert h2 { margin-top: 0; }
    </style>
</head>
<body>
    <div class="container">
        <div class="alert">
            <h2>🛑 Stop-Loss Triggered</h2>
            <p><strong>Symbol:</strong> $symbol</p>
            <p><strong>Entry Price:</strong> \$${entryPrice.toStringAsFixed(2)}</p>
            <p><strong>Exit Price:</strong> \$${exitPrice.toStringAsFixed(2)}</p>
            <p><strong>Loss:</strong> \$${loss.toStringAsFixed(2)} (${lossPercent.toStringAsFixed(2)}%)</p>
            <p>Your position has been automatically closed to limit losses.</p>
        </div>
    </div>
</body>
</html>
    ''';

    return await sendEmail(
      subject: subject,
      htmlContent: htmlContent,
      textContent: textContent,
    );
  }

  /// Send daily summary
  Future<bool> sendDailySummary({
    required int totalTrades,
    required int buyTrades,
    required int sellTrades,
    required double totalVolume,
    required double totalPL,
    required List<TradeRecord> recentTrades,
  }) async {
    final subject = '📊 Daily Trading Summary - ${DateTime.now().toString().split(' ')[0]}';

    final plEmoji = totalPL >= 0 ? '📈' : '📉';
    final plColor = totalPL >= 0 ? '#10b981' : '#ef4444';

    final textContent = '''
📊 Daily Trading Summary

Total Trades: $totalTrades
Buy Orders: $buyTrades
Sell Orders: $sellTrades
Total Volume: \$${totalVolume.toStringAsFixed(2)}
Total P&L: \$${totalPL.toStringAsFixed(2)}

Recent Trades:
${recentTrades.take(5).map((t) => '${t.side} ${t.symbol} @ \$${t.price}').join('\n')}
    ''';

    final tradesHtml = recentTrades.take(5).map((t) => '''
      <tr>
        <td>${t.symbol}</td>
        <td style="color: ${t.side == 'BUY' ? '#10b981' : '#ef4444'}">${t.side}</td>
        <td>\$${t.price.toStringAsFixed(2)}</td>
        <td>\$${t.totalValue.toStringAsFixed(2)}</td>
      </tr>
    ''').join();

    final htmlContent = '''
<!DOCTYPE html>
<html>
<head>
    <style>
        body { font-family: Arial, sans-serif; background: #f3f4f6; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
        .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0; }
        .stats { background: white; padding: 20px; display: grid; grid-template-columns: repeat(2, 1fr); gap: 15px; }
        .stat { padding: 15px; background: #f9fafb; border-radius: 8px; text-align: center; }
        .stat-label { color: #6b7280; font-size: 12px; text-transform: uppercase; }
        .stat-value { font-size: 24px; font-weight: bold; margin-top: 5px; }
        .trades { background: white; padding: 20px; margin-top: 2px; }
        table { width: 100%; border-collapse: collapse; }
        th, td { padding: 10px; text-align: left; border-bottom: 1px solid #e5e7eb; }
        th { background: #f9fafb; font-size: 12px; text-transform: uppercase; color: #6b7280; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>$plEmoji Daily Trading Summary</h1>
            <p>${DateTime.now().toString().split(' ')[0]}</p>
        </div>
        <div class="stats">
            <div class="stat">
                <div class="stat-label">Total Trades</div>
                <div class="stat-value">$totalTrades</div>
            </div>
            <div class="stat">
                <div class="stat-label">Total Volume</div>
                <div class="stat-value">\$${totalVolume.toStringAsFixed(0)}</div>
            </div>
            <div class="stat">
                <div class="stat-label">Buy Orders</div>
                <div class="stat-value" style="color: #10b981">$buyTrades</div>
            </div>
            <div class="stat">
                <div class="stat-label">Sell Orders</div>
                <div class="stat-value" style="color: #ef4444">$sellTrades</div>
            </div>
        </div>
        <div class="stats" style="grid-template-columns: 1fr;">
            <div class="stat">
                <div class="stat-label">Total P&L</div>
                <div class="stat-value" style="color: $plColor">\$${totalPL.toStringAsFixed(2)}</div>
            </div>
        </div>
        <div class="trades">
            <h3>Recent Trades</h3>
            <table>
                <thead>
                    <tr>
                        <th>Symbol</th>
                        <th>Side</th>
                        <th>Price</th>
                        <th>Total</th>
                    </tr>
                </thead>
                <tbody>
                    $tradesHtml
                </tbody>
            </table>
        </div>
    </div>
</body>
</html>
    ''';

    return await sendEmail(
      subject: subject,
      htmlContent: htmlContent,
      textContent: textContent,
    );
  }

  /// Send error alert
  Future<bool> notifyError(String errorMessage, {String? details}) async {
    final subject = '⚠️ Trading Bot Error Alert';

    final textContent = '''
⚠️ Trading Bot Error

Error: $errorMessage

${details != null ? 'Details:\n$details' : ''}

Time: ${DateTime.now()}
    ''';

    final htmlContent = '''
<!DOCTYPE html>
<html>
<body>
    <div style="max-width: 600px; margin: 0 auto; padding: 20px;">
        <div style="background: #fef2f2; border-left: 4px solid #ef4444; padding: 20px; border-radius: 8px;">
            <h2 style="color: #991b1b; margin-top: 0;">⚠️ Trading Bot Error</h2>
            <p><strong>Error:</strong> $errorMessage</p>
            ${details != null ? '<p><strong>Details:</strong><br>$details</p>' : ''}
            <p style="color: #666; font-size: 12px;">Time: ${DateTime.now()}</p>
        </div>
    </div>
</body>
</html>
    ''';

    return await sendEmail(
      subject: subject,
      htmlContent: htmlContent,
      textContent: textContent,
    );
  }
}
