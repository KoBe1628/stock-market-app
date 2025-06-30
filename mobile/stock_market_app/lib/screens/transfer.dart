import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:stock_market_app/secrets.dart';


class TransferScreen extends StatefulWidget {
  final String symbol;
  final bool isCrypto;
  final String action;

  const TransferScreen({
    super.key,
    required this.symbol,
    required this.isCrypto,
    required this.action,});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final List<String> assets = [
    'BTC',
    'ETH',
    'SOL',
    'AAPL',
    'TSLA',
    'NFLX',
    'GOOGL',
    'META',
    'MSFT',
    'PFE'
  ];
  final List<String> fiats = ['USD', 'EUR'];

  String fromAsset = 'BTC';
  String toFiat = 'USD';
  bool isBuying = true;

  double enteredAmount = 0.0;
  double convertedAmount = 0.0;

  Map<String, double> latestPrices = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPrices();
  }

  Future<void> fetchPrices() async {
    try {
      const coingeckoUrl =
          'https://api.coingecko.com/api/v3/simple/price?ids=bitcoin,ethereum,solana&vs_currencies=usd,eur';
      final stockSymbols = ['AAPL', 'TSLA', 'NFLX', 'GOOGL', 'META', 'MSFT', 'PFE'];
      final finnhubKey = finnhubApiKey;

      final res = await http.get(Uri.parse(coingeckoUrl));
      final coinData = jsonDecode(res.body);

      latestPrices['BTC_USD'] = coinData['bitcoin']['usd'].toDouble();
      latestPrices['BTC_EUR'] = coinData['bitcoin']['eur'].toDouble();
      latestPrices['ETH_USD'] = coinData['ethereum']['usd'].toDouble();
      latestPrices['ETH_EUR'] = coinData['ethereum']['eur'].toDouble();
      latestPrices['SOL_USD'] = coinData['solana']['usd'].toDouble();
      latestPrices['SOL_EUR'] = coinData['solana']['eur'].toDouble();

      for (var symbol in stockSymbols) {
        final uri = Uri.parse(
            'https://finnhub.io/api/v1/quote?symbol=$symbol&token=$finnhubKey');
        final stockRes = await http.get(uri);
        final data = jsonDecode(stockRes.body);
        latestPrices['${symbol}_USD'] = data['c']?.toDouble() ?? 0.0;
        latestPrices['${symbol}_EUR'] = (data['c'] * 0.93).toDouble(); // est.
      }

      setState(() => isLoading = false);
    } catch (e) {
      debugPrint('❌ Error fetching prices: $e');
    }
  }

  void onAmountChanged(String value) {
    setState(() {
      enteredAmount = double.tryParse(value) ?? 0.0;
      String key = '${fromAsset}_$toFiat';
      double rate = latestPrices[key] ?? 0.0;
      convertedAmount = enteredAmount * rate;
    });
  }

  void swapDirection() {
    setState(() => isBuying = !isBuying);
  }

  String getImagePath(String symbol) {
    final lower = symbol.toLowerCase();
    if (['btc', 'eth', 'sol'].contains(lower)) {
      return 'assets/logos/coins/${_coinImageFileName(lower)}';
    } else {
      return 'assets/logos/market/${lower}.png';
    }
  }

  String _coinImageFileName(String symbol) {
    switch (symbol) {
      case 'btc':
        return 'bitcoin.png';
      case 'eth':
        return 'ethereum.png';
      case 'sol':
        return 'solana.png';
      default:
        return '$symbol.png';
    }
  }



  Widget buildAssetDropdown() {
    return DropdownButton<String>(
      value: fromAsset,
      isExpanded: true,
      items: assets.map((e) {
        final path = getImagePath(e);
        return DropdownMenuItem(
          value: e,
          child: Row(
            children: [
              Image.asset(path, width: 24, height: 24),
              const SizedBox(width: 8),
              Text(e),
            ],
          ),
        );
      }).toList(),
      onChanged: (val) => setState(() => fromAsset = val!),
    );
  }

  Widget buildFiatDropdown() {
    return DropdownButton<String>(
      value: toFiat,
      isExpanded: true,
      items: fiats.map((e) {
        final flagPath = e == 'USD'
            ? 'assets/flags/us.png'
            : 'assets/flags/germany.png';
        return DropdownMenuItem(
          value: e,
          child: Row(
            children: [
              Image.asset(flagPath, width: 24, height: 24),
              const SizedBox(width: 8),
              Text(e),
            ],
          ),
        );
      }).toList(),
      onChanged: (val) => setState(() => toFiat = val!),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text('${widget.action.toUpperCase()} ${widget.symbol.toUpperCase()}'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: buildAssetDropdown()),
                IconButton(
                  icon: const Icon(Icons.swap_horiz),
                  onPressed: swapDirection,
                ),
                Expanded(child: buildFiatDropdown()),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  labelText: 'Enter amount'),
              onChanged: onAmountChanged,
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(isBuying ? 'You get:' : 'You send:'),
            ),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                convertedAmount.toStringAsFixed(2),
                style: theme.textTheme.titleLarge,

              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Add action here
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor:
                  isBuying ? Colors.green : Colors.red),
              child: Text(isBuying ? 'Buy Now' : 'Sell Now'),
            ),
          ],
        ),
      ),
    );
  }
}