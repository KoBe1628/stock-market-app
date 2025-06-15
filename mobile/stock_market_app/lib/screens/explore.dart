import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'watchlist_service.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String searchQuery = '';
  List<Map<String, dynamic>> stockResults = [];
  List<Map<String, dynamic>> coinResults = [];

  final List<String> stockSymbols = ['AAPL', 'GOOGL', 'TSLA', 'MSFT'];
  final List<String> defaultCoinIds = ['bitcoin', 'ethereum', 'solana', 'dogecoin'];
  final String finnhubApiKey = 'd10nv91r01qlsaca9k70d10nv91r01qlsaca9k7g';

  @override
  void initState() {
    super.initState();
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    await Future.wait([searchStocks(''), searchCoins('')]);
  }

  void onSearch(String query) {
    setState(() {
      searchQuery = query;
    });

    if (query.isNotEmpty) {
      searchStocks(query);
      searchCoins(query);
    } else {
      loadInitialData();
    }
  }

  Future<void> searchStocks(String query) async {
    List<Map<String, dynamic>> results = [];

    if (query.isEmpty) {
      for (String symbol in stockSymbols) {
        final url = Uri.parse('https://finnhub.io/api/v1/quote?symbol=$symbol&token=$finnhubApiKey');
        final response = await http.get(url);
        final data = jsonDecode(response.body);
        final curr = data['c'];
        final prev = data['pc'];

        if (curr != null && prev != null && prev != 0) {
          double pct = ((curr - prev) / prev) * 100;
          results.add({
            'symbol': symbol,
            'price': curr,
            'change_percent': pct,
          });
        }
      }
    } else {
      final lookupUrl = Uri.parse('https://finnhub.io/api/v1/search?q=$query&token=$finnhubApiKey');
      final lookupResponse = await http.get(lookupUrl);
      final lookupData = jsonDecode(lookupResponse.body);

      for (var result in lookupData['result'].take(4)) {
        final symbol = result['symbol'];
        final url = Uri.parse('https://finnhub.io/api/v1/quote?symbol=$symbol&token=$finnhubApiKey');
        final quoteResponse = await http.get(url);
        final data = jsonDecode(quoteResponse.body);

        final curr = data['c'];
        final prev = data['pc'];

        if (curr != null && prev != null && prev != 0) {
          double pct = ((curr - prev) / prev) * 100;
          results.add({
            'symbol': symbol,
            'price': curr,
            'change_percent': pct,
          });
        }
      }
    }

    setState(() {
      stockResults = results;
    });
  }

  Future<void> searchCoins(String query) async {
    if (query.isEmpty) {
      final ids = defaultCoinIds.join(',');
      final url = Uri.parse(
        'https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&ids=$ids&order=market_cap_desc',
      );

      try {
        final response = await http.get(url);
        final coins = List<Map<String, dynamic>>.from(jsonDecode(response.body));
        setState(() {
          coinResults = coins.take(4).toList();
        });
      } catch (e) {
        debugPrint('❌ Error loading default coins: $e');
      }
      return;
    }

    try {
      final searchUrl = Uri.parse('https://api.coingecko.com/api/v3/search?query=$query');
      final searchResponse = await http.get(searchUrl);
      final searchResults = jsonDecode(searchResponse.body)['coins'];

      final ids = searchResults.take(4).map((c) => c['id']).join(',');
      if (ids.isEmpty) {
        setState(() {
          coinResults = [];
        });
        return;
      }

      final marketUrl = Uri.parse(
          'https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&ids=$ids');
      final marketResponse = await http.get(marketUrl);
      final marketData = List<Map<String, dynamic>>.from(jsonDecode(marketResponse.body));

      setState(() {
        coinResults = marketData;
      });
    } catch (e) {
      debugPrint('❌ Error searching coins: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Search for Stocks,\nCoins and Companies',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              onChanged: onSearch,
              decoration: InputDecoration(
                hintText: 'Search ...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await Future.wait([
                    searchStocks(searchQuery),
                    searchCoins(searchQuery),
                  ]);
                },
                child: ListView(
                  children: [
                    if (stockResults.isNotEmpty) ...[
                      const Text('Stocks',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      ...stockResults.map((s) => _buildStockTile(s)),
                      const SizedBox(height: 20),
                    ],
                    if (coinResults.isNotEmpty) ...[
                      const Text('Coins',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      ...coinResults.map((c) => _buildCoinTile(c)),
                    ],
                    if (stockResults.isEmpty && coinResults.isEmpty && searchQuery.isNotEmpty)
                      const Center(child: Text('No results found')),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockTile(Map<String, dynamic> stock) {
    final change = stock['change_percent'];
    final symbol = stock['symbol'];
    final positive = (change ?? 0) >= 0;

    return FutureBuilder<bool>(
      future: WatchlistService.isInWatchlist(symbol),
      builder: (context, snapshot) {
        final isInWatchlist = snapshot.data ?? false;

        return Card(
          child: ListTile(
            leading: Image.asset(
              'assets/logos/market/${symbol.toLowerCase()}.png',
              width: 36,
              errorBuilder: (_, __, ___) =>
              const Icon(Icons.show_chart, color: Colors.grey),
            ),
            title: Text(symbol),
            subtitle: Text('\$${stock['price'].toStringAsFixed(2)}'),
            trailing: IconButton(
              icon: Icon(
                isInWatchlist ? Icons.star : Icons.star_border,
                color: Colors.orange,
              ),
              onPressed: () async {
                if (isInWatchlist) {
                  await WatchlistService.removeFromWatchlist(symbol);
                } else {
                  await WatchlistService.addToWatchlist(symbol);
                }
                setState(() {});
              },
            ),
          ),
        );
      },
    );
  }
  Widget _buildCoinTile(Map<String, dynamic> coin) {
    final symbol = coin['symbol']?.toUpperCase() ?? '';
    final price = coin['current_price'];
    final change = coin['price_change_percentage_24h'];
    final positive = (change ?? 0) >= 0;

    return FutureBuilder<bool>(
      future: WatchlistService.isInWatchlist(symbol),
      builder: (context, snapshot) {
        final isInWatchlist = snapshot.data ?? false;

        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(coin['image']),
            ),
            title: Text(symbol),
            subtitle: price != null
                ? Text('\$${price.toStringAsFixed(2)}')
                : const Text('N/A'),
            trailing: IconButton(
              icon: Icon(
                isInWatchlist ? Icons.star : Icons.star_border,
                color: Colors.orange,
              ),
              onPressed: () async {
                if (isInWatchlist) {
                  await WatchlistService.removeFromWatchlist(symbol);
                } else {
                  await WatchlistService.addToWatchlist(symbol);
                }
                setState(() {});
              },
            ),
          ),
        );
      },
    );
  }
}
