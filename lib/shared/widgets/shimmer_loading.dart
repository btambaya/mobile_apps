import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../app/theme/colors.dart';

/// Shimmer loading placeholder for various content types
class ShimmerLoading extends StatelessWidget {
  final ShimmerType type;
  final int count;

  const ShimmerLoading({
    super.key,
    this.type = ShimmerType.list,
    this.count = 3,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? ThryveColors.surfaceDark : ThryveColors.surface;
    final highlightColor = isDark ? ThryveColors.surfaceElevatedDark : Colors.white;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    switch (type) {
      case ShimmerType.card:
        return _buildCardShimmer();
      case ShimmerType.list:
        return _buildListShimmer();
      case ShimmerType.portfolio:
        return _buildPortfolioShimmer();
      case ShimmerType.stock:
        return _buildStockShimmer();
      case ShimmerType.transaction:
        return _buildTransactionShimmer();
    }
  }

  Widget _buildCardShimmer() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
    );
  }

  Widget _buildListShimmer() {
    return Column(
      children: List.generate(count, (index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 100,
                      height: 14,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 160,
                      height: 12,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    width: 60,
                    height: 14,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 40,
                    height: 12,
                    color: Colors.white,
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildPortfolioShimmer() {
    return Column(
      children: [
        // Portfolio card
        Container(
          height: 180,
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        const SizedBox(height: 24),
        // Quick actions
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(4, (index) {
              return Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 50,
                    height: 12,
                    color: Colors.white,
                  ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildStockShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Price
        Container(
          width: 150,
          height: 36,
          color: Colors.white,
        ),
        const SizedBox(height: 8),
        Container(
          width: 100,
          height: 24,
          color: Colors.white,
        ),
        const SizedBox(height: 24),
        // Chart
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        const SizedBox(height: 24),
        // Stats
        Container(
          height: 150,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionShimmer() {
    return Column(
      children: List.generate(count, (index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 120,
                      height: 14,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 80,
                      height: 12,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
              Container(
                width: 70,
                height: 20,
                color: Colors.white,
              ),
            ],
          ),
        );
      }),
    );
  }
}

enum ShimmerType { card, list, portfolio, stock, transaction }
