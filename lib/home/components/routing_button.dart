import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RoutingButton extends StatelessWidget {
  final VoidCallback onDiaryTap;
  final SvgPicture icon;
  final String routeName;
  final bool disabled;

  const RoutingButton({
    super.key,
    this.disabled = false,
    required this.onDiaryTap,
    required this.icon,
    required this.routeName,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: disabled ? null : onDiaryTap,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            width: 70,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              border: Border.all(
                color: Colors.white,
                width: 3.0,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFFD9D9D9),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    icon,
                    Text(
                      routeName,
                      style: const TextStyle(
                        fontFamily: "sabreshark",
                        fontSize: 12.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                if (disabled)
                  Container(
                    width: 70,
                    height: 100,
                    color: Colors.black.withOpacity(0.8),
                    child: const Center(
                      child: Text(
                        "Need\nLogin",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: "sabreshark",
                          fontSize: 12.0,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// class XPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Colors.white
//       ..strokeWidth = 4;

//     // X 모양을 그립니다.
//     canvas.drawLine(const Offset(0, 0), Offset(size.width, size.height), paint);
//     canvas.drawLine(Offset(size.width, 0), Offset(0, size.height), paint);
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) {
//     return false;
//   }
// }
