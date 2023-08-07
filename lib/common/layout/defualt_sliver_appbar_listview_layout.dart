import 'package:flutter/material.dart';
import 'package:client/common/const/colors.dart';

class DefaultSliverAppbarListviewLayout extends StatelessWidget {
  final Widget sliverAppBar;
  final Future<void> Function() onRefresh;
  final Widget listview;
  const DefaultSliverAppbarListviewLayout({
    super.key,
    required this.sliverAppBar,
    required this.onRefresh,
    required this.listview,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BACKGROUND_BLACK,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxScrolled) => [
          sliverAppBar,
        ],
        body: RefreshIndicator(
          color: Colors.white,
          backgroundColor: BACKGROUND_BLACK,
          onRefresh: onRefresh,
          child: listview,
        ),
      ),
    );
  }
}
