import 'package:meditation/theme/primary.dart';
import 'package:meditation/models/hexcode.dart';
import 'package:meditation/views/player/playermusicscreen.dart';
import 'package:meditation/models/list_data.dart';
import 'package:flutter/material.dart';

class MusicView extends StatelessWidget {
  const MusicView(
      {Key key, this.musicListData, this.animationController, this.animation})
      : super(key: key);

  final MusicListData musicListData;
  final AnimationController animationController;
  final Animation<dynamic> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (BuildContext context, Widget child) {
        return FadeTransition(
          opacity: animation,
          child: Transform(
            transform: Matrix4.translationValues(
                100 * (1.0 - animation.value), 0.0, 0.0),
            child: SizedBox(
              width: 130,
              child: Stack(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 32, left: 8, right: 8, bottom: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                              color: HexColor(musicListData.endColor)
                                  .withOpacity(0.6),
                              offset: const Offset(1.1, 4.0),
                              blurRadius: 8.0),
                        ],
                        gradient: LinearGradient(
                          colors: <HexColor>[
                            HexColor(musicListData.startColor),
                            HexColor(musicListData.endColor),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: const BorderRadius.only(
                          bottomRight: Radius.circular(8.0),
                          bottomLeft: Radius.circular(8.0),
                          topLeft: Radius.circular(8.0),
                          topRight: Radius.circular(54.0),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 54, left: 16, right: 16, bottom: 8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                                width: 80,
                                child: Text(
                                  musicListData.title,
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontFamily: PrimaryTheme.fontName,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    letterSpacing: 0.2,
                                    color: PrimaryTheme.white,
                                  ),
                                )),
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(top: 8, bottom: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      width: 80,
                                      child: Text(
                                        musicListData.artist,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: TextStyle(
                                          fontFamily: PrimaryTheme.fontName,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                          letterSpacing: 0.2,
                                          color: PrimaryTheme.white,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: PrimaryTheme.nearlyWhite,
                                shape: BoxShape.circle,
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                      color: PrimaryTheme.nearlyBlack
                                          .withOpacity(0.4),
                                      offset: Offset(8.0, 8.0),
                                      blurRadius: 8.0),
                                ],
                              ),
                              child: IconButton(
                                icon: Icon(Icons.music_note),
                                iconSize: 24,
                                color: HexColor(musicListData.endColor),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => PlayerMusicScreen(
                                            musicListData: musicListData)),
                                  );
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        color: PrimaryTheme.nearlyWhite.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 8,
                    child: SizedBox(
                      width: 80,
                      height: 80,
                      child: Image.network(musicListData.imagePath),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
