
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/home.dart';
import 'screens/explore.dart';
import 'screens/transfer.dart';
import 'screens/portfolio.dart';
import 'screens/profile.dart';
import 'screens/login.dart';
import 'package:stock_market_app/secrets.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await dotenv.load();
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  runApp(MyApp(isLoggedIn: token != null));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stock Market App',
      debugShowCheckedModeBanner: false,
      home: isLoggedIn ? const MainNavigation() : const LoginPage(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  bool isDarkMode = false;
  double portfolioBalance = 0.0;
  double portfolioInvested = 0.0;
  Map<String, double> latestPrices = {};

  final List<Map<String, dynamic>> holdings = [
    {'symbol': 'AAPL', 'shares': 10.0, 'type': 'stock', 'avgPrice': 150.0},
    {'symbol': 'TSLA', 'shares': 5.0, 'type': 'stock', 'avgPrice': 200.0},
    {'symbol': 'NFLX', 'shares': 22.0, 'type': 'stock', 'avgPrice': 300.0},
    {'symbol': 'BTC', 'shares': 0.71, 'type': 'coin', 'avgPrice': 50000.0},
    {'symbol': 'ETH', 'shares': 0.5, 'type': 'coin', 'avgPrice': 3000.0},
    {'symbol': 'SOL', 'shares': 22.1, 'type': 'coin', 'avgPrice': 100.0},
  ];

  @override
  void initState() {
    super.initState();
    fetchPortfolioBalance();
  }

  Future<void> fetchPortfolioBalance() async {
    final finnhubKey = finnhubApiKey;
    const coingeckoUrl =
        'https://api.coingecko.com/api/v3/simple/price?ids=bitcoin,ethereum,solana&vs_currencies=usd';

    try {
      final symbols = holdings
          .where((h) => h['type'] == 'stock')
          .map((e) => e['symbol'])
          .toList();

      Map<String, double> fetched = {};

      for (String symbol in symbols) {
        final uri = Uri.parse(
            'https://finnhub.io/api/v1/quote?symbol=$symbol&token=$finnhubKey');
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
      double invested = 0.0;
      for (var item in holdings) {
        final symbol = item['symbol'];
        final shares = item['shares'];
        final price = fetched[symbol] ?? 0.0;
        total += shares * price;

        final avgPrice = item['avgPrice'] ?? 0.0;
        invested += avgPrice * shares;
      }

      setState(() {
        portfolioBalance = total;
        portfolioInvested = invested;
        latestPrices = fetched;
      });
    } catch (e) {
      debugPrint('❌ Error fetching balance: $e');
    }
  }

  void toggleTheme() {
    setState(() => isDarkMode = !isDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(
        portfolioBalance: portfolioBalance,
        invested: portfolioInvested,
      ),
      const ExploreScreen(),
      TransferScreen(
        symbol: 'AAPL',
        isCrypto: false,
        action: 'buy',
      ),
      PortfolioScreen(
        onBalanceUpdate: (balance, invested) {
          setState(() {
            portfolioBalance = balance;
            portfolioInvested = invested;
          });
        },
      ),
      ProfileScreen(
        toggleTheme: toggleTheme,
        isDarkMode: isDarkMode,
        balance: portfolioBalance,
      ),
    ];

    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.green,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.green,
      ),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: pages[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.green,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'),
            BottomNavigationBarItem(
                icon: Icon(Icons.swap_horiz), label: 'Transfer'),
            BottomNavigationBarItem(
                icon: Icon(Icons.pie_chart), label: 'Portfolio'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
