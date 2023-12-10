import 'package:client/common/const/colors.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget {
  final VoidCallback? close;
  const CustomAppBar({
    super.key,
    required this.close,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                height: width * 0.1,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Image.asset(
                      "asset/imgs/logo/logo.png",
                      width: width * 0.1,
                      height: width * 0.1,
                    ),
                    const SizedBox(width: 16),
                    const Align(
                      alignment: Alignment.bottomCenter,
                      child: Text(
                        'Eom Tae Ho',
                        style: TextStyle(
                          fontSize: 20,
                          // fontWeight: FontWeight.bold,
                          color: INPUT_BG_COLOR,
                          fontFamily: "sabreshark",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: close,
                child: const Icon(
                  Icons.close_sharp,
                  color: INPUT_BG_COLOR,
                  size: 30,
                ),
              ),
            ],
          ),
        ),
        const Divider(
          color: INPUT_BG_COLOR,
          thickness: 1,
        ),
      ],
    );
  }
}
