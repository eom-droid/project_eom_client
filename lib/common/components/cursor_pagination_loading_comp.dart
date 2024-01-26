import 'package:flutter/material.dart';

class CursorPaginationLoadingComp extends StatelessWidget {
  const CursorPaginationLoadingComp({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 100.0,
      child: Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      ),
    );
  }
}
