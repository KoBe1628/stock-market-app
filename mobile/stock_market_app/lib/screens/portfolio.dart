//  This will be a  PortfolioScreen that shows fake holdings with real-time prices
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';

class PortfolioScreen extends StatefulWidget {
  final void Function(double) onBalanceUpdate;
  const PortfolioScreen({super.key, required this.onBalanceUpdate});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  List<PieChartSectionData> _generatePieSections() {
    final total = totalBalance;
    if (total == 0) return [];

    return holdings.map((asset) {
      final symbol = asset['symbol'];
      final value = (latestPrices[symbol] ?? 0.0) * asset['shares'];
      final percentage = (value / total) * 100;

      return PieChartSectionData(
        color: _getColorForSymbol(symbol),
        value: percentage,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 50,
        titleStyle: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();
  }

  Color _getColorForSymbol(String symbol) {
    const colorMap = {
      'AAPL': Colors.blue,
      'TSLA': Colors.red,
      'NFLX': Colors.purple,
      'BTC': Colors.orange,
      'ETH': Colors.black,
      'SOL': Colors.teal,
    };
    return colorMap[symbol] ?? Colors.grey;
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: holdings.map((asset) {
        final symbol = asset['symbol'];
        final color = _getColorForSymbol(symbol);

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 12, height: 12, color: color),
            const SizedBox(width: 6),
            Text(symbol, style: const TextStyle(fontSize: 12)),
          ],
        );
      }).toList(),
    );
  }

  final List<Map<String, dynamic>> holdings = [
    {'symbol': 'AAPL', 'shares': 10.0, 'type': 'stock'},
    {'symbol': 'TSLA', 'shares': 5.0, 'type': 'stock'},
    {'symbol': 'NFLX', 'shares': 4.0, 'type': 'stock'},
    {'symbol': 'BTC', 'shares': 0.05, 'type': 'coin'},
    {'symbol': 'ETH', 'shares': 0.5, 'type': 'coin'},
    {'symbol': 'SOL', 'shares': 22.1, 'type': 'coin'},
  ];

  Map<String, double> latestPrices = {};
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
    WidgetsBinding.instance.addPostFrameCallback((_) => fetchPrices());
  }

  Future<void> fetchPrices() async {
    const finnhubKey = 'd10nv91r01qlsaca9k70d10nv91r01qlsaca9k7g';
    const coingeckoUrl = 'https://api.coingecko.com/api/v3/simple/price?ids=bitcoin,ethereum,solana&vs_currencies=usd';

    try {
      final symbols = holdings.where((h) => h['type'] == 'stock').map((e) => e['symbol']).toList();
      Map<String, double> fetched = {};

      for (String symbol in symbols) {
        final uri = Uri.parse('https://finnhub.io/api/v1/quote?symbol=$symbol&token=$finnhubKey');
        final res = await http.get(uri);
        final json = jsonDecode(res.body);
        fetched[symbol] = json['c']?.toDouble() ?? 0.0;
      }

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
          : RefreshIndicator(
        onRefresh: fetchPrices,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
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
            const Text('Asset Allocation', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: _generatePieSections(),
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildLegend(),
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
      ),
    );
  }
}
