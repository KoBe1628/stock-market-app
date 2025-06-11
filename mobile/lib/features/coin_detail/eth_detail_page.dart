import 'package:flutter/material.dart';
import 'coin_chart.dart';

class EthDetailPage extends StatelessWidget {
  const EthDetailPage({super.key});

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
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Ethereum',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/eth.png',
                        width: 36,
                        height: 36,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Etherium',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Inter',
                            ),
                          ),
                          Text(
                            'ETH',
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
                        '\$1.546,80',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter',
                        ),
                      ),
                      Text(
                        '-2.546%',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                height: 220,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: const CoinChart(isRed: true),
              ),
              const SizedBox(height: 28),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  _TimeStat(label: 'Today', value: '%1,59', valueColor: Color(0xFF2ECC71)),
                  _TimeStat(label: '7 Days', value: '%15,42', valueColor: Color(0xFF2ECC71)),
                  _TimeStat(label: '30 Days', value: '%0,25', valueColor: Color(0xFF2ECC71)),
                  _TimeStat(label: '90 Days', value: '%-40,27', valueColor: Color(0xFFEB5757)),
                  _TimeStat(label: '180 Days', value: '%-31,43', valueColor: Color(0xFFEB5757)),
                ],
              ),
              const SizedBox(height: 32),
              const Text(
                'Statistics',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 12),
              _statRow('Price', '\$1.546,803'),
              Divider(),
              _statRow('Change', '-2.546%', valueColor: Colors.red),
              Divider(),
              _statRow('24H Volume', '\$16.37B'),
              Divider(),
              _statRow('Market Cap', '\$219.33B'),
              Divider(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

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
