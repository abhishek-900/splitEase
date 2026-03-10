import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class BalanceSummaryCard extends StatelessWidget {
  final double netBalance;
  final double totalOwed;
  final double totalOwe;
  final String currency;

  const BalanceSummaryCard({
    super.key,
    required this.netBalance,
    required this.totalOwed,
    required this.totalOwe,
    this.currency = 'INR',
  });

  static const _symbols = {
    'INR': '₹',
    'USD': '\$',
    'EUR': '€',
    'GBP': '£',
    'JPY': '¥',
    'AED': 'د.إ',
    'SGD': 'S\$',
    'CAD': 'CA\$',
    'AUD': 'AU\$',
    'CHF': 'Fr',
    'CNY': '¥',
    'MYR': 'RM',
    'THB': '฿',
  };

  String _fmt(double v) {
    final sym = _symbols[currency] ?? currency;
    return '$sym${v.abs().toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final isSettled = netBalance.abs() < 0.01;
    final isPositive = netBalance > 0;

    final statusLabel = isSettled
        ? 'All settled up'
        : isPositive
            ? 'You are owed'
            : 'You owe';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryBlue,
            AppTheme.primaryBlue.withOpacity(0.80),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withOpacity(0.28),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(statusLabel,
                        style: const TextStyle(
                            fontSize: 12, color: Colors.white70)),
                    const SizedBox(height: 4),
                    Text(
                      isSettled ? 'All Clear ✓' : _fmt(netBalance),
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  currency,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCell(
                  label: 'Owed to you',
                  value: _fmt(totalOwed),
                  color: totalOwed > 0.01 ? AppTheme.success : Colors.white70,
                ),
              ),
              Container(width: 1, height: 32, color: Colors.white24),
              Expanded(
                child: _StatCell(
                  label: 'You owe',
                  value: _fmt(totalOwe),
                  color: totalOwe > 0.01 ? AppTheme.error : Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatCell({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(fontSize: 11, color: Colors.white54)),
      ],
    );
  }
}
