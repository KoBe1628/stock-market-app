import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:url_launcher/url_launcher.dart';
import 'transfer.dart';
import 'explore.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:stock_market_app/secrets.dart';

class DetailsPage extends StatefulWidget {
  final String symbol;
  final bool isCrypto;
  final double price;
  final double change;

  const DetailsPage({
    super.key,
    required this.symbol,
    required this.isCrypto,
    required this.price,
    required this.change,
  });

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  String selectedInterval = '1D';
  List<FlSpot> chartSpots = [];
  bool isLoadingChart = true;

  Map<String, dynamic>? details;
  bool isLoadingDetails = true;

  final intervals = ['1D', '7D', '1M', '3M', '6M', '1Y'];

  String? about;
  String? website;
  String? coinLogoUrl;

  @override
  void initState() {
    super.initState();
    fetchChartData();
    fetchDetails();
  }

  Future<void> fetchChartData() async {
    setState(() => isLoadingChart = true);
    try {
      final List<FlSpot> spots = [];
      late Uri url;

      if (widget.isCrypto) {
        String days = switch (selectedInterval) {
          '1D' => '1',
          '7D' => '7',
          '1M' => '30',
          '3M' => '90',
          '6M' => '180',
          '1Y' => '365',
          _ => '7'
        };
        url = Uri.parse(
          'https://api.coingecko.com/api/v3/coins/${widget.symbol.toLowerCase()}/market_chart?vs_currency=usd&days=$days',
        );
        final res = await http.get(url);
        final List prices = jsonDecode(res.body)['prices'];

        for (int i = 0; i < prices.length; i++) {
          spots.add(FlSpot(i.toDouble(), prices[i][1].toDouble()));
        }
      } else {
        final apikey = twelveDataApiKey;
        String interval = switch (selectedInterval) {
          '1D' => '5min',
          '7D' => '30min',
          '1M' => '1h',
          '3M' => '1h',
          '6M' => '1d',
          '1Y' => '1d',
          _ => '1h'
        };

        url = Uri.parse(
          'https://api.twelvedata.com/time_series?symbol=${widget.symbol}&interval=$interval&apikey=$apikey&outputsize=100',
        );
        final res = await http.get(url);
        final values = jsonDecode(res.body)['values'];

        for (int i = 0; i < values.length; i++) {
          spots.add(FlSpot(i.toDouble(), double.parse(values[values.length - i - 1]['close'])));
        }
      }

      setState(() {
        chartSpots = spots;
        isLoadingChart = false;
      });
    } catch (e) {
      debugPrint('Chart error: $e');
      setState(() => isLoadingChart = false);
    }
  }

  Future<void> fetchDetails() async {
    setState(() => isLoadingDetails = true);
    try {
      Map<String, dynamic> fetched;
      String? fetchedAbout;
      String? fetchedWebsite;

      if (widget.isCrypto) {
        final url = Uri.parse(
          'https://api.coingecko.com/api/v3/coins/${widget.symbol.toLowerCase()}',
        );
        final res = await http.get(url);
        final data = jsonDecode(res.body);
        fetched = {
          'Market Cap': data['market_data']?['market_cap']?['usd'],
          '24h Volume': data['market_data']?['total_volume']?['usd'],
          '24h High': data['market_data']?['high_24h']?['usd'],
          '24h Low': data['market_data']?['low_24h']?['usd'],
          'Circulating Supply': data['market_data']?['circulating_supply'],
          'Total Supply': data['market_data']?['total_supply'],
        };
        fetchedAbout = data['description']?['en'];
        final homepages = data['links']?['homepage'];
        if (homepages is List && homepages.isNotEmpty) {
          fetchedWebsite = homepages[0];
        }
        coinLogoUrl = data['image']?['large'];
      } else {
        final apikey = twelveDataApiKey;
        final url = Uri.parse(
          'https://api.twelvedata.com/quote?symbol=${widget.symbol}&apikey=$apikey',
        );
        final res = await http.get(url);
        final data = jsonDecode(res.body);
        fetched = {
          'Market Cap': data['market_cap'],
          'Prev Close': data['previous_close'],
          '52W High': (data['fifty_two_week'] is Map ? data['fifty_two_week']['high'] : null),
          '52W Low': (data['fifty_two_week'] is Map ? data['fifty_two_week']['low'] : null),
          'Volume': data['volume'],
        };
        fetchedAbout = data['name'];
        fetchedWebsite = data['website'];
      }
      setState(() {
        details = fetched;
        about = fetchedAbout;
        website = fetchedWebsite;
        isLoadingDetails = false;
      });
    } catch (e) {
      debugPrint('Details error: $e');
      setState(() => isLoadingDetails = false);
    }
  }


  Widget buildDetailsCard() {
    if (isLoadingDetails) return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Center(child: CircularProgressIndicator()),
    );
    if (details == null) return const SizedBox.shrink();
    return Card(
      margin: const EdgeInsets.only(top: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: details!.entries
              .where((e) => e.value != null && e.value.toString() != 'null')
              .map((entry) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(entry.key, style: const TextStyle(fontSize: 15, color: Colors.grey)),
                Text(
                  entry.value is num
                      ? _formatNumber(entry.value)
                      : entry.value.toString(),
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
              ],
            ),
          ))
              .toList(),
        ),
      ),
    );
  }

  String _formatNumber(dynamic numValue) {
    // Format large numbers with K/M/B suffixes
    if (numValue is int || numValue is double) {
      double n = numValue.toDouble();
      if (n >= 1e9) return '${(n / 1e9).toStringAsFixed(2)}B';
      if (n >= 1e6) return '${(n / 1e6).toStringAsFixed(2)}M';
      if (n >= 1e3) return '${(n / 1e3).toStringAsFixed(1)}K';
      return n.toStringAsFixed(2);
    }
    return numValue.toString();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.change >= 0 ? Colors.green : Colors.red;

    return Scaffold(
      appBar: AppBar(title: Text(widget.symbol.toUpperCase())),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Expanded makes the upper content scrollable
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage: widget.isCrypto
                              ? (coinLogoUrl != null
                              ? NetworkImage(coinLogoUrl!)
                              : const AssetImage('assets/placeholder.png') as ImageProvider)
                              : AssetImage('assets/logos/market/${widget.symbol.toLowerCase()}.png') as ImageProvider,

                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.symbol.toUpperCase(),
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '\$${widget.price.toStringAsFixed(2)}',
                              style: TextStyle(fontSize: 18, color: color),
                            ),
                          ],
                        )
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: intervals.map((i) {
                        final selected = selectedInterval == i;
                        return GestureDetector(
                          onTap: () {
                            setState(() => selectedInterval = i);
                            fetchChartData();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: selected ? Colors.green : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(i, style: TextStyle(color: selected ? Colors.white : Colors.black)),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    if (isLoadingChart)
                      const Center(child: CircularProgressIndicator())
                    else
                      SizedBox(
                        height: 200,
                        child: LineChart(
                          LineChartData(
                            gridData: FlGridData(show: false),
                            titlesData: FlTitlesData(show: false),
                            borderData: FlBorderData(show: false),
                            lineBarsData: [
                              LineChartBarData(
                                spots: chartSpots,
                                isCurved: true,
                                dotData: FlDotData(show: false),
                                color: color,
                                belowBarData: BarAreaData(show: false),
                              )
                            ],
                          ),
                        ),
                      ),
                    // --- EXTRA DETAILS CARD BELOW THE CHART ---
                    buildDetailsCard(),
                    buildAboutCard(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TransferScreen(
                            symbol: widget.symbol,
                            isCrypto: widget.isCrypto,
                            action: 'buy',
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text('Buy'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TransferScreen(
                            symbol: widget.symbol,
                            isCrypto: widget.isCrypto,
                            action: 'sell',
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('Sell'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  Widget buildAboutCard() {
    if (isLoadingDetails) return const SizedBox.shrink();
    if ((about == null || about!.trim().isEmpty) && (website == null || website!.trim().isEmpty)) {
      return const SizedBox.shrink();
    }
    return Card(
      margin: const EdgeInsets.only(top: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (about != null && about!.trim().isNotEmpty)
              Text(
                about!.length > 250 ? about!.substring(0, 250) + '...' : about!,
                style: const TextStyle(fontSize: 15, color: Colors.black87),
              ),
            if (website != null && website!.trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.link, size: 19),
                  const SizedBox(width: 7),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        // Use url_launcher to open website in browser
                        // (Remember to add url_launcher to your pubspec.yaml)
                        launchUrl(Uri.parse(website!));
                      },
                      child: Text(
                        website!,
                        style: const TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                          fontSize: 15,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ]
          ],
        ),
      ),
    );
  }
}
