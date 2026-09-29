import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../utils/constants.dart';
import '../../utils/errors.dart';

class PrivacyPolicyPage extends StatefulWidget {
  const PrivacyPolicyPage({Key? key}) : super(key: key);

  @override
  State<PrivacyPolicyPage> createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
  late final Future<WebViewController?> _controller = _create();

  Future<WebViewController?> _create() async {
    try {
      final WebViewController controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onWebResourceError: (WebResourceError error) {
              debugPrint('privacy policy load error: ${error.description}');
            },
          ),
        )
        ..loadRequest(Uri.parse(privacyPolicyUrl));
      return controller;
    } catch (e) {
      debugPrint('WebView unavailable: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: const Text('Privacy policy'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Open in browser',
            onPressed: () => launchUrl(
              Uri.parse(privacyPolicyUrl),
              mode: LaunchMode.externalApplication,
            ),
            icon: const Icon(Icons.open_in_new_rounded, size: 20),
          ),
        ],
      ),
      body: FutureBuilder<WebViewController?>(
        future: _controller,
        builder: (
          BuildContext context,
          AsyncSnapshot<WebViewController?> snapshot,
        ) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final WebViewController? controller = snapshot.data;
          if (controller == null) {
            return const _Fallback();
          }
          return WebViewWidget(controller: controller);
        },
      ),
    );
  }
}

class _Fallback extends StatelessWidget {
  const _Fallback();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.cloud_off_rounded, size: 46),
            const SizedBox(height: 16),
            Text(
              FriendlyError(
                'The privacy policy needs a connection. You can also read it '
                'in your browser.',
              ).message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: () => launchUrl(
                Uri.parse(privacyPolicyUrl),
                mode: LaunchMode.externalApplication,
              ),
              child: const Text('Open in browser'),
            ),
          ],
        ),
      ),
    );
  }
}
