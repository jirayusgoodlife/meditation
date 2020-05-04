import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:meditation/theme/primary.dart';
import 'package:meditation/models/hexcode.dart';
import 'package:flutter/material.dart';
import 'package:meditation/widgets/waveView.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DashboardView extends StatelessWidget {
  final AnimationController animationController;
  final Animation animation;

  final int numberTrainToday;
  final int numberTrainWeekly;
  final int numberTrainMonthly;
  final int numberTrainLastMonth;
  final int userTarget;

  const DashboardView(
      {Key key,
      this.animationController,
      this.animation,
      this.numberTrainToday: 0,
      this.numberTrainWeekly: 0,
      this.numberTrainMonthly: 0,
      this.numberTrainLastMonth: 0,
      this.userTarget: 15})
      : super(key: key);

  Widget getCardLong(BuildContext context, String title, int value, FaIcon icon,
      Color colorline) {
    return Row(
      children: <Widget>[
        Container(
          height: 48,
          width: 2,
          decoration: BoxDecoration(
            color: colorline.withOpacity(0.5),
            borderRadius: BorderRadius.all(Radius.circular(4.0)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 2),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: PrimaryTheme.fontName,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    letterSpacing: -0.1,
                    color: PrimaryTheme.grey.withOpacity(0.5),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  SizedBox(
                    width: 28,
                    height: 28,
                    child: icon,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 3),
                    child: Text(
                      '${(value * animation.value).toInt()}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: PrimaryTheme.fontName,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: PrimaryTheme.darkerText,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 3),
                    child: Text(
                      FlutterI18n.translate(context, 'main.dashboard.minute'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: PrimaryTheme.fontName,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        letterSpacing: -0.2,
                        color: PrimaryTheme.grey.withOpacity(0.5),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        )
      ],
    );
  }

  Widget getCardShort(BuildContext context, String title, String subtitle,
      double percent, Color color) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: PrimaryTheme.fontName,
              fontWeight: FontWeight.w500,
              fontSize: 16,
              letterSpacing: -0.2,
              color: PrimaryTheme.darkText,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Container(
              height: 4,
              width: 70,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.all(Radius.circular(4.0)),
              ),
              child: Row(
                children: <Widget>[                
                  Container(
                    width: percent <= 0 ? 0 : ( ((percent /100 ) * 70 ) * animation.value),
                    height: 4,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        color,
                        color.withOpacity(0.5),
                      ]),
                      borderRadius: BorderRadius.all(Radius.circular(4.0)),
                    ),
                  )
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: PrimaryTheme.fontName,
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: PrimaryTheme.grey.withOpacity(0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double calculatorTarget() {
    if (numberTrainToday == 0) return 0.0;
    return numberTrainToday / userTarget * 100;
  }

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
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 24, right: 24, top: 16, bottom: 18),
              child: Container(
                decoration: BoxDecoration(
                  color: PrimaryTheme.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8.0),
                      bottomLeft: Radius.circular(8.0),
                      bottomRight: Radius.circular(8.0),
                      topRight: Radius.circular(8.0)),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                        color: PrimaryTheme.grey.withOpacity(0.2),
                        offset: Offset(1.1, 1.1),
                        blurRadius: 10.0),
                  ],
                ),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 16, left: 16, right: 16),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 8, right: 8, top: 4),
                              child: Column(
                                children: <Widget>[
                                  getCardLong(
                                      context,
                                      FlutterI18n.translate(
                                          context, 'main.dashboard.today'),
                                      numberTrainToday,
                                      FaIcon(FontAwesomeIcons.smileBeam,
                                          color: HexColor('#69D2E7')),
                                      HexColor('#69D2E7')),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  getCardLong(
                                      context,
                                      FlutterI18n.translate(
                                          context, 'main.dashboard.weekly'),
                                      numberTrainWeekly,
                                      FaIcon(FontAwesomeIcons.smileWink,
                                          color: HexColor('#F56991')),
                                      HexColor('#F56991')),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 16, right: 8, top: 16),
                            child: Container(
                              width: 60,
                              height: 160,
                              decoration: BoxDecoration(
                                color: HexColor('#E8EDFE'),
                                borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(80.0),
                                    bottomLeft: Radius.circular(80.0),
                                    bottomRight: Radius.circular(80.0),
                                    topRight: Radius.circular(80.0)),
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                      color: PrimaryTheme.grey.withOpacity(0.4),
                                      offset: const Offset(2, 2),
                                      blurRadius: 4),
                                ],
                              ),
                              child: WaveView(
                                percentageValue: calculatorTarget(),
                                colorCode: '#63DB6A'
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 24, right: 24, top: 8, bottom: 8),
                      child: Container(
                        height: 2,
                        decoration: BoxDecoration(
                          color: PrimaryTheme.background,
                          borderRadius: BorderRadius.all(Radius.circular(4.0)),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 24, right: 24, top: 8, bottom: 16),
                      child: Row(
                        children: <Widget>[
                          getCardShort(
                              context,
                              FlutterI18n.translate(
                                  context, 'main.dashboard.monthly'),
                              FlutterI18n.translate(context, 'main.dashboard.minuteWithTime',translationParams: {"time": numberTrainMonthly.toString()}),
                              100.00,
                              HexColor('#FF9F80')),
                          getCardShort(
                              context,
                              FlutterI18n.translate(
                                  context, 'main.dashboard.lastMonth'),
                              FlutterI18n.translate(context, 'main.dashboard.minuteWithTime',translationParams: {"time": numberTrainLastMonth.toString()}),
                              100.00,
                              HexColor('#E0E4CC')),                          
                          getCardShort(
                              context,
                              FlutterI18n.translate(
                                  context, 'main.dashboard.targetToday'),
                              ((userTarget - numberTrainToday) >= 0) ? 
                                FlutterI18n.translate(context, 'main.dashboard.timeLeft',translationParams: {"time": (userTarget - numberTrainToday).toString()}) 
                              : FlutterI18n.translate(context,"main.dashboard.success"),
                              calculatorTarget(),
                              HexColor('#a3ff8f')),
                          ],
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
