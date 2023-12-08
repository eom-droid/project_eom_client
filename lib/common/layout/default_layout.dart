import 'package:flutter/material.dart';

class DefaultLayout extends StatelessWidget {
  final Color? backgroundColor;
  final Widget child;

  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final AppBar? appBar;

  final bool isFullScreen;

  const DefaultLayout({
    super.key,
    required this.child,
    this.bottomNavigationBar,
    this.backgroundColor,
    this.appBar,
    this.floatingActionButton,
    this.isFullScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: isFullScreen ? 0.0 : 16.0),
        child: child,
      ),
      appBar: appBar,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
    );
  }

  // AppBar? renderAppBar() {
  //   if (title == null) {
  //     return null;
  //   } else {
  //     return AppBar(
  //       actions: appBarActions,
  //       backgroundColor: BACKGROUND_BLACK,
  //       // 앞으로 튀어나온 효과
  //       elevation: 0,
  //       title: Text(
  //         title!,
  //         style: const TextStyle(
  //           fontSize: 16.0,
  //           fontWeight: FontWeight.w500,
  //         ),
  //       ),
  //       foregroundColor: Colors.white,
  //     );
  //   }
  // }
}
