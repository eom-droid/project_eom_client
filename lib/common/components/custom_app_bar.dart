import 'package:client/common/const/colors.dart';
import 'package:flutter/material.dart';

AppBar CustomAppBar({
  required VoidCallback close,
}) {
  return AppBar(
    toolbarHeight: 50.0,
    titleSpacing: 0,
    backgroundColor: const Color(0x44000000),
    automaticallyImplyLeading: false,
    bottom: PreferredSize(
      preferredSize: const Size.fromHeight(4.0),
      child: Container(
        color: Colors.white,
        height: 1.0,
      ),
    ),
    title: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Image.asset(
                "asset/imgs/logo/logo.png",
                width: 35,
                height: 35,
              ),
              const SizedBox(width: 16),
              const Text(
                'Eom Tae Ho',
                style: TextStyle(
                  fontSize: 20,
                  color: INPUT_BG_COLOR,
                  fontFamily: "sabreshark",
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
  );
}
