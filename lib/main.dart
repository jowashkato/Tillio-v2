import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'config.dart';
import 'helpers/AppTheme.dart';
import 'helpers/routes.dart';
import 'locale/MyLocalizations.dart';
import 'pages/notifications/view_model_manger/notifications_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ❌ Disable orientation lock on Web
  if (!kIsWeb) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  AppLanguage appLanguage = AppLanguage();

  try {
    await appLanguage.fetchLocale();
  } catch (e) {
    debugPrint("Locale error: $e");
  }

  runApp(MyApp(appLanguage: appLanguage));
}

class MyApp extends StatelessWidget {
  final AppLanguage? appLanguage;

  const MyApp({super.key, this.appLanguage});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = NotificationsCubit();
        try {
          cubit.getNotification();
        } catch (e) {
          debugPrint("Notification error: $e");
        }
        return cubit;
      },
      child: ChangeNotifierProvider<AppLanguage>(
        create: (_) => appLanguage ?? AppLanguage(),
        child: Consumer<AppLanguage>(
          builder: (context, model, child) {
            return MaterialApp(
              routes: Routes.generateRoute(),

              // Optional safer fallback for web debugging
              home: Scaffold(
                body: Center(child: Text("APP STARTS OK")),
              ),

              debugShowCheckedModeBanner: false,

              theme: AppTheme.getThemeFromThemeMode(1),

              locale: model.appLocal,
              supportedLocales: Config().supportedLocales,

              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
              ],
            );
          },
        ),
      ),
    );
  }
}
