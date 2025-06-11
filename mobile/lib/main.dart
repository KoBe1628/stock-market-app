import 'package:bestox/features/coin_detail/coin_detail_page.dart';
import 'package:bestox/features/coin_detail/eth_detail_page.dart';
import 'package:bestox/features/coin_detail/tesla_detail_page.dart';
import 'package:bestox/features/login/login_page.dart';
import 'package:bestox/features/pro/pro_page.dart';
import 'package:flutter/material.dart';
import 'package:bestox/features/coin_detail/coin_detail_page.dart';

void main() {
  runApp(const BeStoxApp());
}

class BeStoxApp extends StatelessWidget {
  const BeStoxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CoinDetailPage(),
    );
  }
}
