import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:meditation/theme/primary.dart';
import 'package:flutter/material.dart';

class TitleView extends StatelessWidget {
  final String titleTxt;
  final String subTxt;
  final IconData icon;
  final AnimationController animationController;
  final Animation animation;
  final bool isShowSubIcon;
  final callback;

  const TitleView(
      {Key key,
      this.titleTxt: "",
      this.subTxt: "",
      this.icon: FontAwesomeIcons.arrowRight,
      this.animationController,
      this.animation,
      this.isShowSubIcon: true,
      this.callback})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (BuildContext context, Widget child) {
        return FadeTransition(
          opacity: animation,
          child: new Transform(
            transform: new Matrix4.translationValues(
                0.0, 30 * (1.0 - animation.value), 0.0),
            child: Container(
              child: Padding(
                padding: const EdgeInsets.only(left: 24, right: 24),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        titleTxt,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontFamily: PrimaryTheme.fontName,
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                          letterSpacing: 0.5,
                          color: PrimaryTheme.lightText,
                        ),
                      ),
                    ),
                    InkWell(
                      highlightColor: Colors.transparent,
                      borderRadius: BorderRadius.all(Radius.circular(4.0)),
                      onTap: () {
                        if (callback != null) {
                          callback();
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Row(
                          children: <Widget>[
                            Text(
                              subTxt,
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontFamily: PrimaryTheme.fontName,
                                fontWeight: FontWeight.normal,
                                fontSize: 16,
                                letterSpacing: 0.5,
                                color: PrimaryTheme.nearlyDarkBlue,
                              ),
                            ),
                            SizedBox(
                              height: 38,
                              width: 26,
                              child: isShowSubIcon
                                  ? Icon(icon,
                                      size: 18, color: PrimaryTheme.darkText)
                                  : Text(''),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
