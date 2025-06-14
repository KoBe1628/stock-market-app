import 'package:flutter/material.dart';
import 'screens/home.dart';
import 'screens/explore.dart';
import 'screens/transfer.dart';
import 'screens/portfolio.dart';
import 'screens/profile.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const StockMarketApp());
}

class StockMarketApp extends StatefulWidget {
  const StockMarketApp({super.key});

  @override
  State<StockMarketApp> createState() => _StockMarketAppState();
}

class _StockMarketAppState extends State<StockMarketApp> {
  bool isDarkMode = false;

  void toggleTheme() {
    setState(() => isDarkMode = !isDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stock Market App',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.green,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.green,
      ),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: MainNavigation(toggleTheme: toggleTheme, isDarkMode: isDarkMode),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainNavigation extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  const MainNavigation({super.key, required this.toggleTheme, required this.isDarkMode});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  bool isDarkMode = false;
  double portfolioBalance = 0.0;
  Map<String, double> latestPrices = {};

  final List<Map<String, dynamic>> holdings = [
    {'symbol': 'AAPL', 'shares': 10.0, 'type': 'stock'},
    {'symbol': 'TSLA', 'shares': 5.0, 'type': 'stock'},
    {'symbol': 'NFLX', 'shares': 22.0, 'type': 'stock'},
    {'symbol': 'BTC', 'shares': 0.71, 'type': 'coin'},
    {'symbol': 'ETH', 'shares': 0.5, 'type': 'coin'},
    {'symbol': 'SOL', 'shares': 22.1, 'type': 'coin'},
  ];

  @override
  void initState() {
    super.initState();
    fetchPortfolioBalance();
  }

  Future<void> fetchPortfolioBalance() async {
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

      double total = 0.0;
      for (var item in holdings) {
        final symbol = item['symbol'];
        final shares = item['shares'];
        final price = fetched[symbol] ?? 0.0;
        total += shares * price;
      }

      setState(() {
        portfolioBalance = total;
        latestPrices = fetched;
      });
    } catch (e) {
      debugPrint('❌ Error fetching balance: $e');
    }
  }

  void toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stock Market App',
      theme: isDarkMode ? ThemeData.dark() : ThemeData.light(),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: _pages[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.green,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'),
            BottomNavigationBarItem(icon: Icon(Icons.swap_horiz), label: 'Transfer'),
            BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: 'Portfolio'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }

  late final List<Widget> _pages = [
    HomeScreen(portfolioBalance: portfolioBalance),
    const ExploreScreen(),
    const TransferScreen(),
    PortfolioScreen(onBalanceUpdate: (value) {
      setState(() => portfolioBalance = value);
    }),
    ProfileScreen(toggleTheme: toggleTheme, isDarkMode: isDarkMode),
  ];
}
