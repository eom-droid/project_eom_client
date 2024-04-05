import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:client/common/const/colors.dart';
import 'package:client/music/model/music_model.dart';
import 'package:marquee/marquee.dart';
import 'package:url_launcher/url_launcher_string.dart';

class MusicCard extends StatelessWidget {
  final String id;
  final String title;
  final String artiste;
  final String review;
  final String albumCover;
  final String youtubeMusicId;
  final String spotifyId;

  const MusicCard({
    Key? key,
    required this.id,
    required this.title,
    required this.artiste,
    required this.review,
    required this.albumCover,
    required this.youtubeMusicId,
    required this.spotifyId,
  }) : super(key: key);

  factory MusicCard.fromModel({
    required MusicModel model,
  }) {
    return MusicCard(
      id: model.id,
      title: model.title,
      artiste: model.artiste,
      review: model.review,
      albumCover: model.albumCover,
      youtubeMusicId: model.youtubeMusicId,
      spotifyId: model.spotifyId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.width - 32,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
            color: Colors.black,
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.all(
              Radius.circular(10),
            ),
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(
                sigmaX: 5.0,
                sigmaY: 5.0,
              ),
              child: Image.network(
                albumCover,
                fit: BoxFit.cover,
                // color: Colors.white.withOpacity(0.7),
                // colorBlendMode: BlendMode.modulate,
              ),
            ),
          ),
        ),
        Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.width - 32.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: Colors.black.withOpacity(0.5),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          child: ClipRect(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
                color: const Color.fromARGB(255, 25, 25, 25).withOpacity(0.6),
              ),
              width: MediaQuery.of(context).size.width - 32,
              child: Dismissible(
                confirmDismiss: (DismissDirection direction) async {
                  if (direction == DismissDirection.startToEnd) {
                    await launchSpotify(spotifyId);
                  } else if (direction == DismissDirection.endToStart) {
                    await launchYoutubeMusic(youtubeMusicId);
                  }
                  return false;
                },
                background: Container(
                  color: SPOTIFY_LOGO_COLOR.withAlpha(100),
                  child: const Padding(
                    padding: EdgeInsets.only(left: 16.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Spotify',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontFamily: "sabreshark",
                        ),
                      ),
                    ),
                  ),
                ),
                secondaryBackground: Container(
                  color: YOUTUBE_MUSIC_LOGO_COLOR.withAlpha(100),
                  child: const Padding(
                    padding: EdgeInsets.only(right: 16.0),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'YT Music',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontFamily: "sabreshark",
                        ),
                      ),
                    ),
                  ),
                ),
                key: Key(id),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: SPOTIFY_LOGO_COLOR.withAlpha(100),
                        borderRadius: const BorderRadius.only(
                          bottomRight: Radius.circular(50),
                          topRight: Radius.circular(50),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 24,
                          horizontal: 20.0,
                        ),
                        child: SvgPicture.asset(
                          'asset/imgs/icons/spotify-logo.svg',
                          height: 20,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 30,
                              child: Marquee(
                                text: title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 18.0,
                                ),
                                blankSpace: 20.0,
                                scrollAxis: Axis.horizontal,
                                startAfter: const Duration(seconds: 1),
                                crossAxisAlignment: CrossAxisAlignment.center,
                                pauseAfterRound: const Duration(seconds: 1),
                              ),
                            ),
                            Text(
                              artiste,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: YOUTUBE_MUSIC_LOGO_COLOR.withAlpha(100),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(50),
                          topLeft: Radius.circular(50),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 24,
                          horizontal: 20.0,
                        ),
                        child: SvgPicture.asset(
                          'asset/imgs/icons/youtube-music-logo.svg',
                          height: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> launchSpotify(String spotifyId) async {
    if (await canLaunchUrlString('spotify:track:$spotifyId')) {
      print("?????????????");
      await launchUrlString('spotify:track:$spotifyId',
          mode: LaunchMode.externalApplication);
    } else {
      print("!!!!!!!!!!!!!");

      final String spotifyContent = "https://open.spotify.com/track/$spotifyId";
      if (await canLaunchUrlString(spotifyContent)) {
        await launchUrlString(spotifyContent);
      } else {
        throw 'Could not launch https://www.youtube.com/channel/UCwXdFgeE9KYzlDdR7TG9cMw';
      }
    }
    // final url = 'https://open.spotify.com/track/$spotifyId';

    // if (await canLaunchUrlString(url)) {
    //   // await launchUrlString(url, mode: LaunchMode.externalApplication);
    //   await launchUrlString(url, mode: LaunchMode.externalApplication);
    // }
  }

  Future<void> launchYoutubeMusic(String youtubeMusicId) async {
    final url =
        'https://music.youtube.com/watch?v=$youtubeMusicId&feature=share';

    if (await canLaunchUrlString(url)) {
      await launchUrlString(url, mode: LaunchMode.externalApplication);
    }
  }
}
