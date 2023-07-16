import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../qiita_repository.dart';
import 'item_list_screen.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final QiitaRepository repository = QiitaRepository();

  late String _state;
  late StreamSubscription<Uri> _subscription;

  @override
  void initState() {
    super.initState();

    _state = _randomString(40);
    getInitialUri().then((Uri? uri) {
      if (uri != null && uri.path == '/oauth/authorize/callback') {
        _onAuthorizeCallbackIsCalled(uri);
      }
    });
    // Future<Uri?> getInitialUri() async {
    //   final _subscription = await getInitialLink();
    //   if (link == null) return null;
    //   return Uri.parse('/oauth/authorize/callback');
    // }

    // _subscription = getInitialUri().listen((Uri uri) {
    //   if (uri.path == '/oauth/authorize/callback') {
    //     _onAuthorizeCallbackIsCalled(uri);
    //   }
    // });
  }

  @override
  void dispose() {
    _subscription.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 7,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Qiita App',
                      style: TextStyle(color: Colors.white, fontSize: 32),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Qiitaクライアントアプリ\npowered by Flutter',
                      style: TextStyle(color: Colors.white.withOpacity(0.8)),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Center(
                  child: Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(horizontal: 32),
                child: TextButton(
                  style: TextButton.styleFrom(backgroundColor: Colors.white),
                  onPressed: (_onSignInButtonIsPressed),
                  child: Text(
                    'Qiita ログイン',
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                ),
              )),
            ),
            Expanded(
              flex: 2,
              child: DefaultTextStyle(
                style: TextStyle(color: Colors.white, fontSize: 12),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FutureBuilder<PackageInfo>(
                        future: PackageInfo.fromPlatform(),
                        builder: (context, snapshot) {
                          return Text('Ver. ${snapshot.data?.version ?? '-'}');
                        },
                      ),
                      SizedBox(height: 8),
                      GestureDetector(
                        onTap: () {
                          showLicensePage(context: context);
                        },
                        child: Text('OSS Licenses'),
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

  void _onSignInButtonIsPressed() {
    launchUrlString(repository.createAuthorizeUrl(_state));
  }

  void _onAuthorizeCallbackIsCalled(Uri uri) async {
    closeInAppWebView();

    final accessToken =
        await repository.createAccessTokenFromCallbackUri(uri, _state);
    await repository.saveAccessToken(accessToken);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => ItemListScreen()),
    );
  }

  String _randomString(int length) {
    final chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final rand = Random.secure();
    final codeUnits = List.generate(length, (index) {
      final n = rand.nextInt(chars.length);
      return chars.codeUnitAt(n);
    });
    return String.fromCharCodes(codeUnits);
  }
}
