import 'package:flutter/material.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  String spend = '';
  String receive = '0';

  void onKeyTap(String value) {
    setState(() {
      if (value == '←') {
        spend = spend.isNotEmpty ? spend.substring(0, spend.length - 1) : '';
      } else {
        spend += value;
      }

      double amount = double.tryParse(spend) ?? 0;
      receive = (amount * 0.9).toStringAsFixed(2); // example: 10% fee
    });
  }

  @override
  Widget build(BuildContext context) {
    final buttons = [
      '1', '2', '3',
      '4', '5', '6',
      '7', '8', '9',
      ',', '0', '←',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buy'),
        centerTitle: true,
        leading: const BackButton(),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          _infoCard(title: 'Spend', value: spend.isEmpty ? '10 - 100,000' : spend),
          _infoCard(title: 'Receive', value: receive),
          const SizedBox(height: 10),
          _buildNumberPad(buttons),
          const SizedBox(height: 10),
          _buildPaymentLogos(),
        ],
      ),
    );
  }

  Widget _infoCard({required String title, required String value}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildNumberPad(List<String> keys) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: GridView.builder(
        shrinkWrap: true,
        itemCount: keys.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
        ),
        itemBuilder: (_, index) {
          final key = keys[index];
          return ElevatedButton(
            onPressed: () => onKeyTap(key),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              backgroundColor: Colors.grey[200],
              foregroundColor: Colors.black,
              padding: const EdgeInsets.all(20),
            ),
            child: Text(key, style: const TextStyle(fontSize: 18)),
          );
        },
      ),
    );
  }

  Widget _buildPaymentLogos() {
    final logos = [
      'assets/Cards/visa.png',
      'assets/Cards/mastercard.png',
      'assets/Cards/discover.png',
      'assets/Cards/amex.png',
    ];


    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: logos.map((logo) {
          return Image.asset(logo, width: 60, height: 40, fit: BoxFit.contain);
        }).toList(),
      ),
    );
  }
}