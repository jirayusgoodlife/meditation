import 'package:meditation/models/list_data.dart';
import 'package:flutter/material.dart';
import 'package:meditation/widgets/musicView.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ListSimpleCategoryView extends StatefulWidget {
  const ListSimpleCategoryView(
      {Key key, this.mainScreenAnimationController, this.mainScreenAnimation})
      : super(key: key);

  final AnimationController mainScreenAnimationController;
  final Animation<dynamic> mainScreenAnimation;

  @override
  _ListSimpleCategoryViewState createState() => _ListSimpleCategoryViewState();
}

class _ListSimpleCategoryViewState extends State<ListSimpleCategoryView>
    with TickerProviderStateMixin {
  AnimationController animationController;
  List<MusicListData> musicListData = [];

  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);

    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.mainScreenAnimationController,
      builder: (BuildContext context, Widget child) {
        return FadeTransition(
          opacity: widget.mainScreenAnimation,
          child: Transform(
            transform: Matrix4.translationValues(
                0.0, 30 * (1.0 - widget.mainScreenAnimation.value), 0.0),
            child: Container(
              height: 216,
              width: double.infinity,
              child: StreamBuilder<QuerySnapshot>(
                  stream: Firestore.instance
                      .collection('music')
                      .limit(4)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData)
                      return const Center(
                          child: Padding(
                              padding: const EdgeInsets.only(top: 8, bottom: 8),
                              child: Text('Loading...')));

                    final int musicCount = snapshot.data.documents.length;
                    return ListView.builder(
                      padding: const EdgeInsets.only(
                          top: 0, bottom: 0, right: 16, left: 16),
                      itemCount: musicCount,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (BuildContext context, int index) {
                        final DocumentSnapshot document =
                            snapshot.data.documents[index];

                        final Animation<double> animation =
                            Tween<double>(begin: 0.0, end: 1.0).animate(
                                CurvedAnimation(
                                    parent: animationController,
                                    curve: Interval(
                                        (1 / musicCount) * index, 1.0,
                                        curve: Curves.fastOutSlowIn)));
                        animationController.forward();
                        return MusicView(
                          musicListData: MusicListData(
                              mid: document['mid'],
                              imagePath: document['imagePath'],
                              startColor: document['startColor'],
                              endColor: document['endColor'],
                              title: document['title'],
                              artist: document['artist'],
                              album: document['album'],
                              time: document['time'],
                              detail: document['detail'],
                              music: document['music']),
                          animation: animation,
                          animationController: animationController,
                        );
                      },
                    );
                  }),
            ),
          ),
        );
      },
    );
  }
}
