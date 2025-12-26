import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/typography.dart';

/// Price Alert Card - Create and manage price alerts
class PriceAlertCard extends StatefulWidget {
  final String symbol;
  final double currentPrice;
  final List<PriceAlert> alerts;
  final Function(PriceAlert) onAddAlert;
  final Function(String id) onRemoveAlert;

  const PriceAlertCard({
    super.key,
    required this.symbol,
    required this.currentPrice,
    required this.alerts,
    required this.onAddAlert,
    required this.onRemoveAlert,
  });

  @override
  State<PriceAlertCard> createState() => _PriceAlertCardState();
}

class _PriceAlertCardState extends State<PriceAlertCard> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? ThryveColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? ThryveColors.surfaceElevatedDark : ThryveColors.divider,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Alerts',
                style: ThryveTypography.titleSmall.copyWith(
                  color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
                ),
              ),
              TextButton.icon(
                onPressed: () => _showAddAlertSheet(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add'),
                style: TextButton.styleFrom(
                  foregroundColor: ThryveColors.accent,
                ),
              ),
            ],
          ),
          
          if (widget.alerts.isEmpty)
            _buildEmptyState(isDark)
          else
            ...widget.alerts.map((alert) => _buildAlertItem(alert, isDark)),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: ThryveColors.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.notifications_outlined,
              color: ThryveColors.accent,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No price alerts',
                  style: ThryveTypography.titleSmall.copyWith(
                    color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
                  ),
                ),
                Text(
                  'Get notified when price hits your target',
                  style: ThryveTypography.bodySmall.copyWith(
                    color: ThryveColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertItem(PriceAlert alert, bool isDark) {
    final isAbove = alert.targetPrice > widget.currentPrice;
    final direction = isAbove ? 'Above' : 'Below';
    final icon = isAbove ? Icons.arrow_upward : Icons.arrow_downward;
    final color = isAbove ? ThryveColors.success : ThryveColors.error;

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? ThryveColors.surfaceElevatedDark : ThryveColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '\$${alert.targetPrice.toStringAsFixed(2)}',
                  style: ThryveTypography.titleSmall.copyWith(
                    color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
                  ),
                ),
                Text(
                  '$direction current price',
                  style: ThryveTypography.caption.copyWith(
                    color: ThryveColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, size: 18, color: ThryveColors.textSecondary),
            onPressed: () => widget.onRemoveAlert(alert.id),
          ),
        ],
      ),
    );
  }

  void _showAddAlertSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final priceController = TextEditingController();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? ThryveColors.backgroundDark : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: ThryveColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Create Price Alert',
                style: ThryveTypography.headlineSmall.copyWith(
                  color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Current price: \$${widget.currentPrice.toStringAsFixed(2)}',
                style: ThryveTypography.bodyMedium.copyWith(
                  color: ThryveColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                decoration: InputDecoration(
                  labelText: 'Target Price',
                  prefixText: '\$ ',
                  filled: true,
                  fillColor: isDark ? ThryveColors.surfaceDark : ThryveColors.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  final price = double.tryParse(priceController.text);
                  if (price != null && price > 0) {
                    widget.onAddAlert(PriceAlert(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      symbol: widget.symbol,
                      targetPrice: price,
                      createdAt: DateTime.now(),
                    ));
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThryveColors.accent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  'Create Alert',
                  style: ThryveTypography.button.copyWith(color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

/// Model for price alert
class PriceAlert {
  final String id;
  final String symbol;
  final double targetPrice;
  final DateTime createdAt;
  bool isTriggered;

  PriceAlert({
    required this.id,
    required this.symbol,
    required this.targetPrice,
    required this.createdAt,
    this.isTriggered = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'symbol': symbol,
    'targetPrice': targetPrice,
    'createdAt': createdAt.toIso8601String(),
    'isTriggered': isTriggered,
  };

  factory PriceAlert.fromJson(Map<String, dynamic> json) => PriceAlert(
    id: json['id'],
    symbol: json['symbol'],
    targetPrice: json['targetPrice'],
    createdAt: DateTime.parse(json['createdAt']),
    isTriggered: json['isTriggered'] ?? false,
  );
}
