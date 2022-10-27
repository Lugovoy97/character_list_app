import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rickandmorty/bloc_observable.dart';
import 'package:rickandmorty/ui/pages/home_page.dart';

// void main() {
//   BlocOverrides.runZoned(
//     () => runApp(const MyApp()),
//     blocObserver: CharacterBlocObservable(),
//   );
// }

void main() {
  Bloc.observer = CharacterBlocObservable();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rick and Morty',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(title: 'Rick and Morty'),
    );
  }
}