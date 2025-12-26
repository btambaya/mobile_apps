import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/typography.dart';

/// Order History page - Detailed order status and history
/// Shows all orders with DriveWealth status tracking
class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Open', 'Filled', 'Cancelled'];

  // Mock data - would come from DriveWealth API
  final List<OrderItem> _orders = [
    OrderItem(
      id: 'ORD-2024-001234',
      symbol: 'AAPL',
      name: 'Apple Inc.',
      type: OrderType.market,
      side: OrderSide.buy,
      quantity: 2.5,
      price: 178.50,
      status: OrderStatus.filled,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      filledAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    OrderItem(
      id: 'ORD-2024-001235',
      symbol: 'TSLA',
      name: 'Tesla, Inc.',
      type: OrderType.limit,
      side: OrderSide.buy,
      quantity: 1.0,
      limitPrice: 240.00,
      status: OrderStatus.open,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    OrderItem(
      id: 'ORD-2024-001233',
      symbol: 'MSFT',
      name: 'Microsoft Corporation',
      type: OrderType.market,
      side: OrderSide.sell,
      quantity: 0.5,
      price: 380.25,
      status: OrderStatus.filled,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      filledAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    OrderItem(
      id: 'ORD-2024-001232',
      symbol: 'NVDA',
      name: 'NVIDIA Corporation',
      type: OrderType.limit,
      side: OrderSide.buy,
      quantity: 0.25,
      limitPrice: 450.00,
      status: OrderStatus.cancelled,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  List<OrderItem> get _filteredOrders {
    if (_selectedFilter == 'All') return _orders;
    return _orders.where((o) => o.status.label == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Order History',
          style: ThryveTypography.titleLarge.copyWith(
            color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = filter == _selectedFilter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _selectedFilter = filter);
                    },
                    selectedColor: ThryveColors.accent.withValues(alpha: 0.2),
                    checkmarkColor: ThryveColors.accent,
                    labelStyle: TextStyle(
                      color: isSelected ? ThryveColors.accent : ThryveColors.textSecondary,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Orders list
          Expanded(
            child: _filteredOrders.isEmpty
                ? _buildEmptyState(isDark)
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredOrders.length,
                    itemBuilder: (context, index) {
                      final order = _filteredOrders[index];
                      return _buildOrderCard(order, isDark);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: ThryveColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'No orders found',
            style: ThryveTypography.titleMedium.copyWith(
              color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
            ),
          ),
          Text(
            'Orders matching your filter will appear here',
            style: ThryveTypography.bodyMedium.copyWith(
              color: ThryveColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(OrderItem order, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? ThryveColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? ThryveColors.surfaceElevatedDark : ThryveColors.divider,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showOrderDetails(order),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  // Symbol badge
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: order.side.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        order.symbol[0],
                        style: ThryveTypography.titleMedium.copyWith(
                          color: order.side.color,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              order.symbol,
                              style: ThryveTypography.titleSmall.copyWith(
                                color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: order.side.color.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                order.side.label.toUpperCase(),
                                style: ThryveTypography.caption.copyWith(
                                  color: order.side.color,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          order.name,
                          style: ThryveTypography.caption.copyWith(
                            color: ThryveColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: order.status.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      order.status.label,
                      style: ThryveTypography.labelSmall.copyWith(
                        color: order.status.color,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Order details row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildDetailColumn(
                    'Type',
                    order.type.label,
                    isDark,
                  ),
                  _buildDetailColumn(
                    'Quantity',
                    '${order.quantity} shares',
                    isDark,
                  ),
                  _buildDetailColumn(
                    order.type == OrderType.limit ? 'Limit' : 'Price',
                    order.type == OrderType.limit
                        ? '\$${order.limitPrice?.toStringAsFixed(2) ?? 'N/A'}'
                        : '\$${order.price?.toStringAsFixed(2) ?? 'Pending'}',
                    isDark,
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Time and ID
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    order.formattedTime,
                    style: ThryveTypography.caption.copyWith(
                      color: ThryveColors.textTertiary,
                    ),
                  ),
                  Text(
                    order.id,
                    style: ThryveTypography.caption.copyWith(
                      color: ThryveColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailColumn(String label, String value, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: ThryveTypography.caption.copyWith(
            color: ThryveColors.textTertiary,
          ),
        ),
        Text(
          value,
          style: ThryveTypography.titleSmall.copyWith(
            color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
          ),
        ),
      ],
    );
  }

  void _showOrderDetails(OrderItem order) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? ThryveColors.backgroundDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
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
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: order.side.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      order.symbol[0],
                      style: ThryveTypography.titleMedium.copyWith(
                        color: order.side.color,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${order.side.label} ${order.symbol}',
                        style: ThryveTypography.headlineSmall.copyWith(
                          color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
                        ),
                      ),
                      Text(
                        order.name,
                        style: ThryveTypography.bodyMedium.copyWith(
                          color: ThryveColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildDetailRow('Order ID', order.id, isDark),
            _buildDetailRow('Status', order.status.label, isDark, valueColor: order.status.color),
            _buildDetailRow('Type', order.type.label, isDark),
            _buildDetailRow('Quantity', '${order.quantity} shares', isDark),
            if (order.limitPrice != null)
              _buildDetailRow('Limit Price', '\$${order.limitPrice!.toStringAsFixed(2)}', isDark),
            if (order.price != null)
              _buildDetailRow('Fill Price', '\$${order.price!.toStringAsFixed(2)}', isDark),
            _buildDetailRow('Created', order.formattedTime, isDark),
            if (order.filledAt != null)
              _buildDetailRow('Filled', _formatDateTime(order.filledAt!), isDark),
            const SizedBox(height: 24),
            if (order.status == OrderStatus.open)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Cancelling order ${order.id}...'),
                        backgroundColor: ThryveColors.warning,
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ThryveColors.error,
                    side: const BorderSide(color: ThryveColors.error),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Cancel Order'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDark, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: ThryveTypography.bodyMedium.copyWith(
              color: ThryveColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: ThryveTypography.titleSmall.copyWith(
              color: valueColor ?? (isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

enum OrderType { market, limit, stop }
enum OrderSide { buy, sell }
enum OrderStatus { open, filled, cancelled, rejected }

extension OrderTypeExt on OrderType {
  String get label {
    switch (this) {
      case OrderType.market: return 'Market';
      case OrderType.limit: return 'Limit';
      case OrderType.stop: return 'Stop';
    }
  }
}

extension OrderSideExt on OrderSide {
  String get label {
    switch (this) {
      case OrderSide.buy: return 'Buy';
      case OrderSide.sell: return 'Sell';
    }
  }

  Color get color {
    switch (this) {
      case OrderSide.buy: return ThryveColors.success;
      case OrderSide.sell: return ThryveColors.error;
    }
  }
}

extension OrderStatusExt on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.open: return 'Open';
      case OrderStatus.filled: return 'Filled';
      case OrderStatus.cancelled: return 'Cancelled';
      case OrderStatus.rejected: return 'Rejected';
    }
  }

  Color get color {
    switch (this) {
      case OrderStatus.open: return ThryveColors.info;
      case OrderStatus.filled: return ThryveColors.success;
      case OrderStatus.cancelled: return ThryveColors.warning;
      case OrderStatus.rejected: return ThryveColors.error;
    }
  }
}

class OrderItem {
  final String id;
  final String symbol;
  final String name;
  final OrderType type;
  final OrderSide side;
  final double quantity;
  final double? price;
  final double? limitPrice;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime? filledAt;

  OrderItem({
    required this.id,
    required this.symbol,
    required this.name,
    required this.type,
    required this.side,
    required this.quantity,
    this.price,
    this.limitPrice,
    required this.status,
    required this.createdAt,
    this.filledAt,
  });

  String get formattedTime {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ago';
    }
    return 'Just now';
  }
}
