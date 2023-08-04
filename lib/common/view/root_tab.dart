import 'package:flutter/material.dart';
import 'package:client/home/view/home_screen.dart';

class RootTab extends StatelessWidget {
  static String get routeName => 'root';

  const RootTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeScreen();
  }
}
