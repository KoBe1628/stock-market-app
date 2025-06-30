import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ProVersionScreen extends StatefulWidget {
  const ProVersionScreen({Key? key}) : super(key: key);

  @override
  State<ProVersionScreen> createState() => _ProVersionScreenState();
}

class _ProVersionScreenState extends State<ProVersionScreen> {
  bool _agreed = false;

  void _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Upgrade'),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.titleLarge,
                children: [

                ],
              ),
            ),
            const SizedBox(height: 24),
            Image.asset('assets/images/pro_version.png', height: 200),

            const SizedBox(height: 32),
            // Yearly button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrangeAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {},
                child: Column(
                  children: const [
                    Text('Yearly \$59.99'),
                    SizedBox(height: 4),
                    Text('Per month \$6 – Save 50% off'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),
            // Monthly button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  side: BorderSide(color: Theme.of(context).dividerColor),
                ),
                onPressed: () {},
                child: const Text('Monthly \$9.99'),
              ),
            ),

            const SizedBox(height: 24),
            // Upgrade button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _agreed ? () { /* purchase */ } : null,
                child: const Text('Upgrade'),
              ),
            ),

            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: _agreed,
                  onChanged: (v) => setState(() => _agreed = v!),
                ),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodySmall,
                      children: [
                        const TextSpan(text: 'By placing this order you agree to the '),
                        TextSpan(
                          text: 'Terms of Service',
                          style: const TextStyle(decoration: TextDecoration.underline),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => _launchUrl('https://example.com/terms'),
                        ),
                        const TextSpan(text: ' and '),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: const TextStyle(decoration: TextDecoration.underline),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => _launchUrl('https://example.com/privacy'),
                        ),
                        const TextSpan(
                            text:
                            '.\nSubscription auto-renews unless turned off 24h before period end.'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}