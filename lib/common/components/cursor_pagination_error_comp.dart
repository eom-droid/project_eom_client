import 'package:client/common/model/cursor_pagination_model.dart';
import 'package:flutter/material.dart';

class CursorPaginationErrorComp extends StatelessWidget {
  final CursorPaginationError state;
  final VoidCallback onRetry;
  const CursorPaginationErrorComp({
    super.key,
    required this.state,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(state.message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16.0, color: Colors.white)),
            const SizedBox(
              height: 16.0,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
              onPressed: onRetry,
              child: const Text('다시시도'),
            ),
          ],
        ),
      ),
    );
  }
}
