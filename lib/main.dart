import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sizer/sizer.dart';

import 'controller/autoComplete cubit/google_maps_cubit.dart';
import 'controller/bloc_observer.dart';
import 'firebase_options.dart';
import 'view/home.dart';

void main() async {
  // await dotenv.load(fileName: "lib/.env" ); //path to your .env file);
  //   print("API Key from env :${dotenv.env['GOOGLE_API_KEY']}");
  // const platform = MethodChannel('api_channel');
  // final googleApiKey = dotenv.env['GOOGLE_API_KEY'];
  // await platform.invokeMethod('setApiKey', googleApiKey);
  
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = MyBlocObserver();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GoogleMapsCubit(),
      child: Sizer(
        builder: (context, orientation, deviceType) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              useMaterial3: true,
            ),
            home: const MyHomePage(),
          );
        },
      ),
    );
  }
}
