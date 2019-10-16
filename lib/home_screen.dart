import 'package:cantapp/bloc_provider.dart';
import 'package:cantapp/category_screen.dart';
import 'package:cantapp/favorite_bloc.dart';
import 'package:cantapp/favorite_repository.dart';
import 'package:cantapp/list_songs_screen.dart';
import 'package:cantapp/song_model.dart';
import 'package:cantapp/song_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'dart:math' as math;

// This is the type used by the popup menu below.
enum HomeAction { category, donate, favorite }

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Firestore _databaseReference = Firestore.instance;
  List<Song> _songs = new List<Song>();
  List<Song> _songListData = new List<Song>();
  FavoriteRepository _repo;
  List<Favorite> _favorites;
  FavoritesBloc _favoriteBloc;
  // HomeAction _selection;

  @override
  void initState() {
    super.initState();

    _repo = new FavoriteRepository();
    _getData();

    // is obsolete
    // Firestore.instance.enablePersistence(true);
  }

  @override
  Widget build(BuildContext context) {
    /// Access the favorites list from the [BlocProvider], which is available as a root
    /// element of the app.

    _favoriteBloc = BlocProvider.favorites(context);

    return CustomScrollView(
        // physics: ScrollPhysics(parent: ),
        // headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 100.0,
            floating: false,
            elevation: 0,
            pinned: true,
            snap: false,
            // snap: true,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: false,
              titlePadding: EdgeInsets.only(left: 20, right: 20, bottom: 15),
              title: Text(
                'Cantapp',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25.0,
                  shadows: [Shadow(blurRadius: 0, color: Colors.white)],
                ),
              ),
            ),
          ),
          // SliverList(
          //   delegate: SliverChildListDelegate([
          //     SearchTextField(
          //         onChanged: (value) => _filterSearchResults(value))
          //   ]),
          // ),
          SliverPersistentHeader(
            pinned: false,
            delegate: _SliverAppBarDelegate(
              minHeight: 50.0,
              maxHeight: 50.0,
              child: Container(
                  child: SearchTextField(
                      onChanged: (value) => _filterSearchResults(value))),
            ),
          ),
          SliverList(
              delegate: SliverChildBuilderDelegate(
            (context, index) => Slidable(
              actionPane: SlidableStrechActionPane(),
              actionExtentRatio: 0.25,
              child: Column(children: <Widget>[
                ListTile(
                    title: Text(_songListData[index].title),
                    trailing: Icon(
                      Icons.chevron_right,
                      size: 20.00,
                    ),
                    leading: SizedBox(
                        height: 45,
                        child: CircleAvatar(
                            child: Text('$index',
                                style: TextStyle(fontSize: 15)))),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        // fullscreenDialog: true, // sono sicuro?
                        builder: (context) =>
                            SongScreen(song: _songListData[index])))),
                Divider(
                  color: Colors.grey[500],
                  indent: 15.00,
                  thickness: .30,
                  height: 0,
                ),
              ]),
              secondaryActions: <Widget>[
                IconSlideAction(
                  color: Colors.red,
                  icon: _getIcon(_songListData[index]),
                  onTap: () => _onTapFavorite(index),
                ),
              ],
            ),
            childCount: _songListData.length,
            // semanticIndexCallback: (Widget widget, int localIndex) {
            //   if (localIndex.isEven) {
            //     return localIndex ~/ 2;
            //   }
            //   return null;
            // },
          ))
        ]);
  }

  void _onTapFavorite(int index) {
    var message = 'rimosso';
    // var uid = _songListData[index].id;

    var song = _songListData[index];
    var isFavorite = !_songListData[index].isFavorite;

    setState(() => _songListData[index].isFavorite = isFavorite);

    // if (_isFavorite(uid)) {
    //   _repo.remove(uid);
    //   message = 'rimosso';
    // } else {
    //   _repo.add(uid);
    //   message = 'aggiunto';
    // }

    if (!isFavorite) {
      _favoriteBloc.removeFavorite(song);
      message = 'rimosso';
    } else {
      _favoriteBloc.addFavorite(song);
      message = 'aggiunto';
    }

    // _getFavorites();

    final snackBar = SnackBar(
        backgroundColor: Colors.red,
        duration: const Duration(milliseconds: 1500),
        content: Text('${_songListData[index].title} $message ai preferiti'));

    // Find the Scaffold in the widget tree and use it to show a SnackBar.
    Scaffold.of(context).showSnackBar(snackBar);
  }

  void _filterSearchResults(String query) {
    // print(query);
    if (_songs == null) {
      return;
    }

    var songSearchList = new List<Song>();
    songSearchList.addAll(_songs);

    if (query.isNotEmpty) {
      List<Song> songListData = List<Song>();
      songSearchList.forEach((item) {
        var title = item.title.toLowerCase();
        var querylow = query.toLowerCase();

        if (title.contains(querylow)) {
          songListData.add(item);
        }
      });

      setState(() {
        _songListData.clear();
        _songListData.addAll(songListData);
      });
      return;
    } else {
      setState(() {
        _songListData.clear();
        _songListData.addAll(_songs);
      });
    }
  }

  void _getData() {
    _databaseReference
        .collection("songs")
        .orderBy("title")
        .getDocuments()
        .then((QuerySnapshot snapshot) {
      var result = snapshot.documents.map((doc) => Song.fromSnapshot(doc));
      result.forEach(
          (f) => f.isFavorite = _favoriteBloc.favorites.indexOf(f) > -1);

      setState(() {
        _songs = result.toList();
        _songListData = result.toList();
      });

      // _getFavorites();
    });
  }

  // void _getFavorites() {
  //   // _repo.favorites().then((value) => setState(() => _favorites = value));
  //   // setState(() => _favoriteBloc.favorites);
  // }

  IconData _getIcon(Song currentValue) {
    // if (_favoriteBloc.favorites.length == 0) return FontAwesomeIcons.heart;
    // var exist = _favoriteBloc.favorites.indexOf(currentValue) > -1;
    // return exist ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart;
    return currentValue.isFavorite
        ? FontAwesomeIcons.solidHeart
        : FontAwesomeIcons.heart;
  }

  // bool _isFavorite(String uid) {
  //   return _favorites.map((x) => x.uid).toList().indexOf(uid) > -1;
  // }

  // List<Song> _mergeFevoriteSongs() {
  //   return _songListData
  //       .where((x) => _favorites.map((x) => x.uid).toList().contains(x.id))
  //       .toList();
  // }
}

class SearchTextField extends StatefulWidget {
  final Function onChanged;

  SearchTextField({this.onChanged});

  @override
  _SearchTextFieldState createState() => _SearchTextFieldState();
}

class _SearchTextFieldState extends State<SearchTextField>
    with TickerProviderStateMixin {
  double _width;
  bool _isFocused;

  TextEditingController _editingController;

  @override
  void initState() {
    super.initState();

    _isFocused = false;
    _editingController = new TextEditingController();
    _editingController
        .addListener(() => widget.onChanged(_editingController.text));

    WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
  }

  void _afterLayout(_) {
    _width = MediaQuery.of(context).size.width;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor,
      padding: EdgeInsets.only(left: 20, right: 20, bottom: 15, top: 0),
      child: Stack(
        fit: StackFit.loose,
        children: <Widget>[
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: FlatButton(
              onPressed: () => _onCancel(),
              textColor: Colors.white,
              child: Text('Cancella'),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            width: _width ?? MediaQuery.of(context).size.width,
            child: TextField(
              onTap: () => _inOutFocus(true),
              controller: _editingController,
              // cursorColor: Colors.white,
              // style: TextStyle(color: Colors.white),
              onSubmitted: (value) => _inOutFocus(false),
              decoration: InputDecoration(
                filled: true,
                // fillColor: Color(0xFFDBEDFF),
                fillColor: Colors.white,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 15, vertical: 7.5),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  borderSide: BorderSide.none,
                ),
                hintText: 'Cerca',
                // hintStyle: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _inOutFocus(bool focus) {
    if (focus && !_isFocused) {
      setState(() {
        _width -= 140;
        _isFocused = true;
      });
    }

    if (!focus && _isFocused) {
      setState(() {
        _width += 140;
        _isFocused = false;
      });
    }
  }

  _onCancel() {
    _editingController.clear();
    FocusScope.of(context).requestFocus(FocusNode());
    _inOutFocus(false);
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    @required this.minHeight,
    @required this.maxHeight,
    @required this.child,
  });
  final double minHeight;
  final double maxHeight;
  final Widget child;
  @override
  double get minExtent => minHeight;
  @override
  double get maxExtent => math.max(maxHeight, minHeight);
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return new SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
