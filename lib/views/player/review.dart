import 'package:flutter/material.dart';
import 'package:meditation/theme/primary.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class ReviewScreen extends StatefulWidget {
  ReviewScreen({Key key, this.mid}) : super(key: key);
  final String mid;

  @override
  _ReviewScreenState createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  double _rating = 5.0;

  String userId = "";
  String documentId = "";

  onSetDocuemntId() async {
    final FirebaseUser user = await _auth.currentUser();
    setState(() {
      userId = user.uid;
    });
    Firestore.instance
        .collection('logReview')
        .where("uid", isEqualTo: user.uid)
        .where("mid", isEqualTo: widget.mid)
        .snapshots()
        .listen((data) {
      data.documents.forEach((doc) {
        setState(() {
          documentId = doc.documentID;
        });
      });
    });
  }

  @override
  void initState() {
    super.initState();
    onSetDocuemntId();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: PrimaryTheme.nearlyWhite,
        child: SafeArea(
            top: true,
            bottom: false,
            child: Scaffold(
                backgroundColor: Colors.transparent,
                body: Stack(children: <Widget>[
                  InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      onTap: () {
                        FocusScope.of(context).requestFocus(FocusNode());
                      },
                      child: Column(children: <Widget>[
                        getAppBarUI(context),
                        Container(height: AppBar().preferredSize.height),
                        Center(
                            child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            getRatingUI(),
                            Container(height: AppBar().preferredSize.height),
                            getSaveButton(context),
                            GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                    FlutterI18n.translate(
                                        context, 'player.review.skip'),
                                    style: PrimaryTheme.caption))
                          ],
                        ))
                      ]))
                ]))));
  }

  Widget getAppBarUI(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: PrimaryTheme.backgroundColor,
        boxShadow: <BoxShadow>[
          BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              offset: Offset(0, 2),
              blurRadius: 8.0),
        ],
      ),
      child: Row(
        children: <Widget>[
          Container(
              alignment: Alignment.centerLeft,
              width: AppBar().preferredSize.height,
              height: AppBar().preferredSize.height),
          Text(FlutterI18n.translate(context, 'player.review.title'),
              style: PrimaryTheme.headline),
        ],
      ),
    );
  }

  Widget getRatingUI() {
    return RatingBar(
      initialRating: _rating,
      direction: Axis.horizontal,
      itemCount: 5,
      itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
      itemBuilder: (context, index) {
        switch (index) {
          case 0:
            return Icon(
              Icons.sentiment_very_dissatisfied,
              color: Colors.red,
            );
          case 1:
            return Icon(
              Icons.sentiment_dissatisfied,
              color: Colors.redAccent,
            );
          case 2:
            return Icon(
              Icons.sentiment_neutral,
              color: Colors.amber,
            );
          case 3:
            return Icon(
              Icons.sentiment_satisfied,
              color: Colors.lightGreen,
            );
          case 4:
            return Icon(
              Icons.sentiment_very_satisfied,
              color: Colors.green,
            );
          default:
            return Container();
        }
      },
      onRatingUpdate: (rating) {
        setState(() {
          _rating = rating;
        });
      },
    );
  }

  Widget getSaveButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 8),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: PrimaryTheme.primaryColor,
          borderRadius: BorderRadius.all(Radius.circular(24.0)),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.grey.withOpacity(0.6),
              blurRadius: 8,
              offset: Offset(4, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.all(Radius.circular(24.0)),
            highlightColor: Colors.transparent,
            onTap: () {
              ProgressDialog pr = new ProgressDialog(context);
              pr.style(message: FlutterI18n.translate(context, 'saving'));
              pr.show();
              if (documentId == "") {
                Firestore.instance.collection('logReview').document().setData({
                  'uid': userId,
                  'mid': widget.mid,
                  'point': _rating.toString(),
                });
              } else {
                Firestore.instance
                    .collection('logReview')
                    .document(documentId)
                    .updateData({'point': _rating.toString()});
              }
              Future.delayed(Duration(seconds: 2), () {
                pr.hide();

                Navigator.pop(context);

                /*
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => NavigationHomeScreen()),
                );
                */
              });
            },
            child: Center(
              child: Text(
                FlutterI18n.translate(context, 'player.review.save'),
                style: PrimaryTheme.body1White,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
