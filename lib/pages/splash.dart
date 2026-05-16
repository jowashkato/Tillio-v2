import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config.dart';
import '../helpers/AppTheme.dart';
import '../helpers/SizeConfig.dart';
import '../helpers/otherHelpers.dart';
import '../locale/MyLocalizations.dart';

class Splash extends StatefulWidget {
  static int themeType = 1;

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  ThemeData themeData = AppTheme.getThemeFromThemeMode(Splash.themeType);
  CustomAppTheme customAppTheme = AppTheme.getCustomAppTheme(Splash.themeType);

  var selectedLanguage;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      changeLanguage();
      loadData();
    });
  }

  void changeLanguage() async {
    try {
      var prefs = await SharedPreferences.getInstance();

      selectedLanguage =
          prefs.getString('language_code') ?? Config().defaultLanguage;

      if (mounted) setState(() {});
    } catch (e) {
      debugPrint("Language error: $e");
    }
  }

  Future<void> loadData() async {
    try {
      // Safe permission request (can fail on web)
      try {
        await Helper().requestAppPermission();
      } catch (e) {
        debugPrint("Permission error: $e");
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();

      if (!mounted) return;

      if (prefs.getInt('userId') != null) {
        Config.userId = prefs.getInt('userId');

        Helper().jobScheduler();

        if (!mounted) return;

        Navigator.of(context).pushReplacementNamed('/layout');
      } else {
        if (!mounted) return;

        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      debugPrint("Splash load error: $e");

      if (!mounted) return;

      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    MySize().init(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // YOUR LOGO (REPLACES ICON)
            Image.asset(
              'assets/images/logo.png',
              width: 140,
              height: 140,
            ),

            const SizedBox(height: 25),

            // LOADING INDICATOR
            const CircularProgressIndicator(
              color: Color(0xff3d63ff),
            ),

            const SizedBox(height: 15),

            // APP NAME (kept same logic)
            Text(
              Config().appName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget initialInterface() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/lottie/welcome.json',
            width: 500,
          ),
          Text(
            AppLocalizations.of(context).translate('welcome'),
            style: AppTheme.getTextStyle(
              themeData.textTheme.headlineMedium,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Close'),
                    )
                  ],
                  title: Text(
                    AppLocalizations.of(context).translate('language'),
                  ),
                  content: changeAppLanguage(),
                ),
              );
            },
            child: Text(
              AppLocalizations.of(context).translate('language'),
            ),
          ),
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: loadData,
            child: Text(
              AppLocalizations.of(context).translate('login'),
            ),
          ),
          Visibility(
            visible: Config().showRegister,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: GestureDetector(
                child: Text(
                  AppLocalizations.of(context).translate('register'),
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () async {
                  try {
                    await launchUrl(
                      Uri.parse('${Config.baseUrl}/business/register'),
                      mode: LaunchMode.externalApplication,
                    );
                  } catch (e) {
                    debugPrint("Launch error: $e");
                  }
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget changeAppLanguage() {
    var appLanguage = Provider.of<AppLanguage>(context);

    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: selectedLanguage,
        onChanged: (String? newValue) {
          if (newValue == null) return;

          appLanguage.changeLanguage(Locale(newValue), newValue);
          selectedLanguage = newValue;

          Navigator.pop(context);
        },
        items: Config().lang.map<DropdownMenuItem<String>>((Map locale) {
          return DropdownMenuItem<String>(
            value: locale['languageCode'],
            child: Text(locale['name']),
          );
        }).toList(),
      ),
    );
  }
}
