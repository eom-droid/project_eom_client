// import 'package:flutter/material.dart';

// class DiaryCommentCard extends StatelessWidget {
//   final String nickName;
//   final String? profileImg;
//   const DiaryCommentCard({
//     super.key,
//     required this.nickName,
//     required this.profileImg,
//   });

//   // factory DiaryCommentCard.fromModel({
//   //   required DiaryCommentModel model,
//   // }) {
//   //   return DiaryCommentCard(
//   //     nickName: model.nickName,
//   //     profileImg: model.profileImg,
//   //   );
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return const Padding(
//       padding: EdgeInsets.symmetric(
//         horizontal: 16.0,
//       ),
//       child: Column(
//         children: [
//           CircleAvatar(
//             radius: 16.0,
//             backgroundColor: Colors.grey,
//             // backgroundImage: AssetImage(
//             //   'assets/images/default_profile.png',
//             // ),
//             child: Text(
//               '?',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 22.0,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
