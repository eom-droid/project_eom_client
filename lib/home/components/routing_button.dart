import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RoutingButton extends StatelessWidget {
  final VoidCallback onDiaryTap;
  final SvgPicture icon;
  final String routeName;

  const RoutingButton({
    super.key,
    required this.onDiaryTap,
    required this.icon,
    required this.routeName,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onDiaryTap,
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
            child: Column(
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
          ),
        ),
      ),
    );
  }
}
