import 'dart:async';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:meditation/models/list_data.dart';
import 'package:flutter/material.dart';
import 'package:meditation/widgets/musicView.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meditation/theme/primary.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:meditation/models/hexcode.dart';

StreamController<List<MusicListData>> _streamController =
    StreamController<List<MusicListData>>.broadcast();
Stream<List<MusicListData>> get _stream => _streamController.stream;

class AlbumScreenView extends StatefulWidget {
  @override
  _AlbumScreenViewState createState() => _AlbumScreenViewState();
}

class _AlbumScreenViewState extends State<AlbumScreenView>
    with TickerProviderStateMixin {
  AnimationController animationController;

  List<MusicListData> masterMusicListData = [];

  ScrollController _scrollController = new ScrollController();

  TextEditingController txtController = TextEditingController();

  @override
  void initState() {
    animationController = AnimationController(
        duration: Duration(milliseconds: 2000), vsync: this);
    addMusicList();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  addMusicList() {
    Firestore.instance.collection('music').getDocuments().then((data) {
      data.documents.forEach((document) {
        // add init data to list
        masterMusicListData.add(MusicListData(
            mid: document['mid'],
            imagePath: document['imagePath'],
            startColor: document['startColor'],
            endColor: document['endColor'],
            title: document['title'],
            artist: document['artist'],
            album: document['album'],
            time: document['time'],
            detail: document['detail'],
            music: document['music']));
      });
    }).whenComplete(() {
      _streamController.sink.add(masterMusicListData);
    });
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
                        Expanded(
                            child: NestedScrollView(
                          controller: _scrollController,
                          headerSliverBuilder:
                              (BuildContext context, bool innerBoxIsScrolled) {
                            return <Widget>[
                              SliverList(
                                delegate: SliverChildBuilderDelegate(
                                    (BuildContext context, int index) {
                                  return Column(
                                    children: <Widget>[
                                      getSearchBarUI(context),
                                    ],
                                  );
                                }, childCount: 1),
                              ),
                            ];
                          },
                          body: getListGrid(),
                        ))
                      ]))
                ]))));
  }

  _filter(String searchQuery) {
    List<MusicListData> _filteredList = masterMusicListData
        .where((MusicListData data) =>
            data.title.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
    _streamController.sink.add(_filteredList);
  }

  Widget getSearchBarUI(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(left: 8, right: 8),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 8, right: 16, top: 8, bottom: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: PrimaryTheme.backgroundColor,
                    borderRadius: BorderRadius.all(
                      Radius.circular(38.0),
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          offset: Offset(0, 2),
                          blurRadius: 8.0),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 16, right: 16, top: 4, bottom: 4),
                    child: TextField(
                      controller: txtController,
                      style: PrimaryTheme.body1,
                      decoration: new InputDecoration(
                        border: InputBorder.none,
                        hintText: FlutterI18n.translate(context, 'search'),
                        hintStyle: PrimaryTheme.body1,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: HexColor("#54D3C2"),
                borderRadius: BorderRadius.all(
                  Radius.circular(38.0),
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                      color: Colors.grey.withOpacity(0.4),
                      offset: Offset(0, 2),
                      blurRadius: 8.0),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.all(
                    Radius.circular(32.0),
                  ),
                  onTap: () {
                    print(txtController.text);
                    _filter(txtController.text);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Icon(FontAwesomeIcons.search,
                        size: 20, color: PrimaryTheme.backgroundColor),
                  ),
                ),
              ),
            ),
          ],
        ));
  }

  Widget getListGrid() {
    return StreamBuilder<List<MusicListData>>(
      initialData: masterMusicListData,
      builder:
          (BuildContext context, AsyncSnapshot<List<MusicListData>> snapshot) {
        return StreamBuilder<List<MusicListData>>(
            key: ValueKey(snapshot.data),
            initialData: snapshot.data,
            stream: _stream,
            builder: (BuildContext context,
                AsyncSnapshot<List<MusicListData>> snapshot) {
              if (!snapshot.hasData)
                return const Center(
                    child: Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 8),
                        child: Text('Not Found')));
              return GridView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (_, int index) {
                  var animation = Tween(begin: 0.0, end: 1.0).animate(
                    CurvedAnimation(
                      parent: animationController,
                      curve: Interval((1 / snapshot.data.length) * index, 1.0,
                          curve: Curves.fastOutSlowIn),
                    ),
                  );
                  animationController.forward();
                  return MusicView(
                    musicListData: snapshot.data[index],
                    animation: animation,
                    animationController: animationController,
                  );
                },
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10.0,
                  crossAxisSpacing: 20.0,
                  childAspectRatio: 0.7,
                ),
              );
            });
      },
    );
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
            height: AppBar().preferredSize.height,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.all(
                  Radius.circular(32.0),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.arrow_back_ios,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
          Text(FlutterI18n.translate(context, 'main.homepage.title_02'),
              style: PrimaryTheme.headline),
        ],
      ),
    );
  }
}
