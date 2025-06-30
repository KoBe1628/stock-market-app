import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'portfolio.dart';
import 'pro_version_screen.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:stock_market_app/secrets.dart';


class HomeScreen extends StatefulWidget {
  final double portfolioBalance;
  final double invested;

  const HomeScreen({super.key, required this.portfolioBalance, required this.invested});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _country;
  String? _flagAsset;

  List<Map<String, dynamic>> stockData = [];
  bool isStockLoading = true;

  List<Map<String, dynamic>> newsList = [];
  bool isNewsLoading = true;

  List<Map<String, dynamic>> coinData = [];
  bool isCoinLoading = true;

  @override
  void initState() {
    super.initState();
    detectCountry();
    fetchMarketMovers();
    fetchNews();
    fetchCoins();
  }

  Future<void> detectCountry() async {
    try {
      final hasPermission = await Geolocator.checkPermission();
      if (hasPermission == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }
      final position = await Geolocator.getCurrentPosition();
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        final country = placemarks.first.country ?? 'Unknown';
        setState(() {
          _country = country;
          _flagAsset = _getFlagForCountry(country);
        });
      }
    } catch (e) {
      debugPrint('Location error: $e');
    }
  }

  String? _getFlagForCountry(String countryName) {
    const map = {
      'Germany': 'assets/flags/germany.png',
      'United States': 'assets/flags/us.png',
      'France': 'assets/flags/france.png',
      'United Kingdom': 'assets/flags/uk.png',
      'India': 'assets/flags/india.png',
    };
    return map[countryName];
  }

  Future<void> fetchMarketMovers() async {
    final apiKey = finnhubApiKey;
    final symbols = ['AAPL', 'GOOGL', 'TSLA', 'MSFT', 'NFLX', 'PFE'];

    List<Map<String, dynamic>> fetched = [];

    try {
      for (var sym in symbols) {
        final uri = Uri.parse('https://finnhub.io/api/v1/quote?symbol=$sym&token=$apiKey');
        final res = await http.get(uri);

        // Debug logs:
        print('📦 Response for $sym: ${res.statusCode}');
        print('🧾 Body: ${res.body}');

        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);

          final curr = data['c'];
          final prev = data['pc'];

          if (curr == null || prev == null) {
            print('⚠️ Missing data for $sym');
            continue;
          }

          if (prev != 0) {
            double pct = ((curr - prev) / prev) * 100;
            fetched.add({
              'symbol': sym,
              'change_percent': pct,
            });
          }
        } else {
          print('❌ Failed to fetch $sym: ${res.reasonPhrase}');
        }
      }

      setState(() {
        stockData = fetched;
        isStockLoading = false;
      });
    } catch (e, stackTrace) {
      print('❌ Exception in fetchMarketMovers: $e');
      print('📍 Stacktrace: $stackTrace');
      setState(() => isStockLoading = false);
    }
  }

  Future<void> fetchNews() async {
    final apiKey = newsApiKey;
    final uri = Uri.parse(
      'https://newsapi.org/v2/top-headlines?country=us&pageSize=10&apiKey=$apiKey',
    );
    try {
      final res = await http.get(uri);
      final data = jsonDecode(res.body);
      if (data['articles'] != null) {
        setState(() {
          newsList = List<Map<String, dynamic>>.from(data['articles']);
          isNewsLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error fetching news: $e');
      setState(() => isNewsLoading = false);
    }
  }

  Future<void> fetchCoins() async {
    final uri = Uri.parse(
      'https://api.coingecko.com/api/v3/coins/markets?'
          'vs_currency=usd&ids=bitcoin,ethereum,solana,cardano,binancecoin,dogecoin'
          '&order=market_cap_desc&sparkline=false',
    );
    try {
      final res = await http.get(uri);
      setState(() {
        coinData = List<Map<String, dynamic>>.from(jsonDecode(res.body));
        isCoinLoading = false;
      });
    } catch (e) {
      debugPrint('❌ Error fetching coins: $e');
      setState(() => isCoinLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasBalance = widget.portfolioBalance > 0 && widget.invested > 0;
    final double change = hasBalance
        ? ((widget.portfolioBalance - widget.invested) / widget.invested) * 100
        : 0;
    final bool isPositive = change >= 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: const [
          Icon(Icons.notifications_none),
          SizedBox(width: 16),
          Icon(Icons.more_vert),
          SizedBox(width: 16),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            fetchMarketMovers(),
            fetchNews(),
            fetchCoins(),
          ]);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Portfolio card
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PortfolioScreen(onBalanceUpdate: (_, __) {}),
                  ),
                );
              },
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text(
                        'Portfolio Balance',
                        style: TextStyle(fontSize: 20),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.portfolioBalance > 0
                            ? '\$${widget.portfolioBalance.toStringAsFixed(2)}'
                            : 'Loading...',
                        style: const TextStyle(fontSize: 18),
                      ),
                    if (hasBalance)
                      Text(
                        '${isPositive ? '+' : ''}${change.toStringAsFixed(2)}% overall',
                         style: TextStyle(
                           fontSize: 16,
                           color: isPositive ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // News section
            const Text(
              'Check out today’s news',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 140,
              child: isNewsLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: newsList.length,
                itemBuilder: (_, i) {
                  final news = newsList[i];
                  return GestureDetector(
                    onTap: () async {
                      final uri = Uri.parse(news['url'] ?? '');
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri,
                            mode: LaunchMode.externalApplication);
                      }
                    },
                    child: Container(
                      width: 220,
                      margin: const EdgeInsets.only(right: 12),
                      child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 80,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                image: (news['urlToImage'] != null)
                                    ? DecorationImage(
                                  image: NetworkImage(
                                      news['urlToImage']),
                                  fit: BoxFit.cover,
                                )
                                    : null,
                              ),
                              child: news['urlToImage'] == null
                                  ? const Center(
                                  child: Icon(Icons.image, size: 40))
                                  : null,
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  news['title'] ?? 'No title',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // Stock movers
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Popular Stocks in Your Region',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (_flagAsset != null)
                  CircleAvatar(
                    radius: 12,
                    backgroundImage: AssetImage(_flagAsset!),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Market Movers',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 120,
              child: isStockLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: stockData.length,
                itemBuilder: (_, idx) {
                  final s = stockData[idx];
                  final sym = s['symbol'];
                  final pct = s['change_percent'] as double;
                  final formatted = pct.toStringAsFixed(2);
                  final positive = pct >= 0;
                  return _imageCard(
                    'assets/logos/market/${sym.toLowerCase()}.png',
                    sym,
                    '${positive ? '+' : ''}$formatted%',
                    positive ? Colors.green : Colors.red,
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // Crypto movers
            const Text(
              'Popular Coins',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 120,
              child: isCoinLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: coinData.length,
                itemBuilder: (_, idx) {
                  final c = coinData[idx];
                  final name = c['name'] ?? '';
                  final img = c['image'] ?? '';
                  final change = (c['price_change_percentage_24h'] ??
                      0.0) as double;
                  final positive = change >= 0;
                  return Container(
                    width: 100,
                    margin: const EdgeInsets.only(right: 8),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 6),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              backgroundImage: NetworkImage(img),
                              radius: 20,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${change.toStringAsFixed(2)}%',
                              style: TextStyle(
                                  color:
                                  positive ? Colors.green : Colors.red,
                                  fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // Pro upgrade card
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ProVersionScreen()),
                );
              },
              child: Card(
                color: const Color(0xFFA2FF6B),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: const [
                      Icon(Icons.star,
                          size: 40, color: Colors.deepPurple),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                  text: 'Get ',
                                  style: TextStyle(fontSize: 16)),
                              TextSpan(
                                text: 'BeStock Pro',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurple),
                              ),
                              TextSpan(
                                  text: ' now 50% off',
                                  style: TextStyle(fontSize: 16)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _imageCard(
      String assetPath, String name, String change, Color color) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 8),
      child: Card(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 2,
        child: Padding(
          padding:
          const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage(assetPath),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 13),
                  textAlign: TextAlign.center),
              const SizedBox(height: 4),
              Text(change, style: TextStyle(color: color, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}