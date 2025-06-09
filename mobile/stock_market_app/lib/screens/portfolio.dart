// ✅ This will be a demo PortfolioScreen that shows fake holdings with real-time prices
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PortfolioScreen extends StatefulWidget {
  final void Function(double) onBalanceUpdate;
  const PortfolioScreen({super.key, required this.onBalanceUpdate});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  // Fake portfolio data
  final List<Map<String, dynamic>> holdings = [
    {'symbol': 'AAPL', 'shares': 10.0, 'type': 'stock'},
    {'symbol': 'TSLA', 'shares': 5.0, 'type': 'stock'},
    {'symbol': 'NFLX', 'shares': 22.0, 'type': 'stock'},
    {'symbol': 'BTC', 'shares': 0.71, 'type': 'coin'},
    {'symbol': 'ETH', 'shares': 0.5, 'type': 'coin'},
    {'symbol': 'SOL', 'shares': 22.1, 'type': 'coin'},
  ];

  Map<String, double> latestPrices = {}; // will store real-time prices
  bool isLoading = true;

  final Map<String, String> logos = {
    'AAPL': 'assets/logos/market/aapl.png',
    'TSLA': 'assets/logos/market/tsla.png',
    'NFLX': 'assets/logos/market/nflx.png',
    'BTC': 'assets/logos/coins/bitcoin.png',
    'ETH': 'assets/logos/coins/ethereum.png',
    'SOL': 'assets/logos/coins/solana.png',
  };

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchPrices(); // safe call after build
    });
  }


  Future<void> fetchPrices() async {
    const finnhubKey = 'd10nv91r01qlsaca9k70d10nv91r01qlsaca9k7g';
    const coingeckoUrl = 'https://api.coingecko.com/api/v3/simple/price?ids=bitcoin,ethereum,solana&vs_currencies=usd';

    try {
      final symbols = holdings.where((h) => h['type'] == 'stock').map((e) => e['symbol']).toList();
      Map<String, double> fetched = {};

      // Get stock prices from Finnhub
      for (String symbol in symbols) {
        final uri = Uri.parse('https://finnhub.io/api/v1/quote?symbol=$symbol&token=$finnhubKey');
        final res = await http.get(uri);
        final json = jsonDecode(res.body);
        fetched[symbol] = json['c']?.toDouble() ?? 0.0;
      }

      // Get coin prices from CoinGecko
      final coinRes = await http.get(Uri.parse(coingeckoUrl));
      final coinJson = jsonDecode(coinRes.body);
      fetched['BTC'] = coinJson['bitcoin']['usd'].toDouble();
      fetched['ETH'] = coinJson['ethereum']['usd'].toDouble();
      fetched['SOL'] = coinJson['solana']['usd'].toDouble();

      setState(() {
        latestPrices = fetched;
        isLoading = false;
      });
      widget.onBalanceUpdate(totalBalance);
    } catch (e) {
      debugPrint('❌ Error fetching prices: $e');
      setState(() => isLoading = false);
    }
  }

  double get totalBalance {
    double total = 0.0;
    for (var item in holdings) {
      final symbol = item['symbol'];
      final shares = item['shares'];
      final price = latestPrices[symbol] ?? 0.0;
      total += shares * price;
    }
    return total;
  }

  Widget _buildAssetTile(Map<String, dynamic> item) {
    final symbol = item['symbol'];
    final shares = item['shares'];
    final price = latestPrices[symbol] ?? 0.0;
    final total = shares * price;
    return Card(
      child: ListTile(
        leading: Image.asset(
          logos[symbol] ?? 'assets/images/meme.png',
          width: 32,
          height: 32,
        ),
        title: Text(symbol, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('$shares units'),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('\$${total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('\$${price.toStringAsFixed(2)}/unit', style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stockHoldings = holdings.where((h) => h['type'] == 'stock').toList();
    final coinHoldings = holdings.where((h) => h['type'] == 'coin').toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Portfolio')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Top section with avatar and balance
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundImage: AssetImage('assets/images/meme.png'),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Shiny Flakes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const Text('@jamal1233', style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 8),
                      Text('Current Balance\n\$${totalBalance.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Your Stocks', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...stockHoldings.map(_buildAssetTile).toList(),
          const SizedBox(height: 20),
          const Text('Your Coins', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...coinHoldings.map(_buildAssetTile).toList(),
        ],
      ),
    );
  }
}
