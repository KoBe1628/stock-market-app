import 'package:flutter/material.dart';
import 'coin_chart.dart';

class CoinDetailPage extends StatelessWidget {
  const CoinDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Bitcoin',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Coin Info Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/Bitcoin.svg.png',
                        width: 36,
                        height: 36,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Bitcoin',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Inter',
                            ),
                          ),
                          Text(
                            'BTC',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: const [
                      Text(
                        '\$84.146,70',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter',
                        ),
                      ),
                      Text(
                        '+0.29%',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF2ECC71),
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Chart
              Container(
                height: 220,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: const CoinChart(),
              ),
              const SizedBox(height: 28),

              // Buy / Sell Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2ECC71),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 6,
                        shadowColor: Colors.black26,
                      ),
                      child: const Text(
                        'Buy',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEB5757),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 6,
                        shadowColor: Colors.black26,
                      ),
                      child: const Text(
                        'Sell',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Time Filter Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  _TimeStat(label: 'Today', value: '%0,29', valueColor: Color(0xFF2ECC71)),
                  _TimeStat(label: '7 Days', value: '%9,08', valueColor: Color(0xFF2ECC71)),
                  _TimeStat(label: '30 Days', value: '%15,39', valueColor: Color(0xFF2ECC71)),
                  _TimeStat(label: '90 Days', value: '%-5,05', valueColor: Color(0xFFEB5757)),
                  _TimeStat(label: '180 Days', value: '%31,68', valueColor: Color(0xFF2ECC71)),
                ],
              ),
              const SizedBox(height: 32),

              // Statistics
              const Text(
                'Statistics',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 12),

              _statRow('Price', '\$84,146.70'),
              Divider(),
              _statRow('Change', '+4.357%', valueColor: Color(0xFF2ECC71)),
              Divider(),
              _statRow('24H Volume', '\$25.86B'),
              Divider(),
              _statRow('Market Cap', '\$1,883.67B'),
              Divider(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // Helper for stat rows
  Widget _statRow(String label, String value, {Color valueColor = Colors.black}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'Inter',
              )),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: valueColor,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }
}

// TimeStat Widget
class _TimeStat extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _TimeStat({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.black87,
              fontFamily: 'Inter',
            )),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: valueColor,
              fontFamily: 'Inter',
            )),
      ],
    );
  }
}
