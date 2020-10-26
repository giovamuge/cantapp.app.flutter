import 'package:cantapp/activity/list_activity_cards.dart';
import 'package:cantapp/common/constants.dart';
import 'package:cantapp/common/theme.dart';
import 'package:cantapp/services/firestore_database.dart';
import 'package:cantapp/song/song_search.dart';
import 'package:cantapp/song/song_item.dart';
import 'package:cantapp/song/song_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    implements AutomaticKeepAliveClientMixin<HomeScreen> {
  // Songs _songsData;
  bool _visible;
  ScrollController _controller;

  @override
  void initState() {
    _visible = false;
    _controller = ScrollController();
    _controller.addListener(_onScrolling);
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    // _songsData = Provider.of<Songs>(context);
    // await _songsData.fetchSongs();
  }

  void _onScrolling() {
    // valore di offset costante
    const offset = 125;
    // Mostra il bottone search quando raggiungo
    // 120 di altezza, dove si trovara il bottone
    // grande search.
    if (_controller.offset <= offset && _visible) {
      setState(() => _visible = false);
    }

    // Nascondi in caso contrario
    // Controllo su _visible per non ripete il set continuamente
    if (_controller.offset > offset && !_visible) {
      setState(() => _visible = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: AnimatedOpacity(
        title: Visibility(
          // If the widget is visible, animate to 0.0 (invisible).
          // If the widget is hidden, animate to 1.0 (fully visible).
          // opacity: _visible ? 1.0 : 0.0,
          visible: _visible,
          // curve: Curves.easeInExpo,
          // duration: Duration(milliseconds: 200),
          child: Text("Cantapp"),
        ),
        actions: <Widget>[
          // AnimatedOpacity(
          Visibility(
            // If the widget is visible, animate to 0.0 (invisible).
            // If the widget is hidden, animate to 1.0 (fully visible).
            // opacity: _visible ? 1.0 : 0.0,
            visible: _visible,
            // duration: Duration(milliseconds: 200),
            // curve: Curves.easeInExpo,
            child: Center(
              child: IconButton(
                icon: Icon(Icons.search),
                onPressed: () => showSearch(
                  context: context,
                  delegate: SongSearchDelegate(),
                ),
              ),
            ),
          ),
          SizedBox(width: 20),
        ],
      ),
      body: ListView(
        controller: _controller,
        // padding: EdgeInsets.symmetric(horizontal: 20),
        addAutomaticKeepAlives: true,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "Quale canto stai\ncercando?",
              style: TextStyle(
                fontSize: 35,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: RaisedButton(
              onPressed: () => showSearch(
                context: context,
                delegate: SongSearchDelegate(),
              ),
              elevation: .5,
              hoverElevation: .5,
              focusElevation: .5,
              highlightElevation: .5,
              color: Theme.of(context).dialogBackgroundColor,
              padding: const EdgeInsets.all(12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.search,
                    size: 17.00,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text("Cerca")
                ],
              ),
            ),
          ),
          // SizedBox(height: 15),
          // ListActivityCardsWidget(),
          SizedBox(height: 15),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildContents(context)),
        ],
      ),
    );
  }

  Widget _buildContents(BuildContext context) {
    final database = Provider.of<FirestoreDatabase>(context,
        listen: false); // potrebbe essere true, da verificare
    return StreamBuilder<List<Song>>(
      stream: database.songsStream(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final List<Song> items = snapshot.data;
          if (items.isNotEmpty) {
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                return SongWidget(song: items[index], number: index);
              },
              itemCount: items.length,
            );
          } else {
            return Container(
                height: 300,
                child: Center(child: Text("Non ci sono canzoni 🤷‍♂️")));
          }
        } else if (snapshot.hasError) {
          return Container(
              height: 300,
              child: Center(
                  child: Text("C'è un errore 😖\nriprova tra qualche istante.",
                      textAlign: TextAlign.center)));
        }

        var theme = Provider.of<ThemeChanger>(context, listen: false);
        return Shimmer.fromColors(
          // baseColor: Theme.of(context).primaryColorLight,
          // highlightColor: Theme.of(context).primaryColor,
          baseColor: theme.getThemeName() == Constants.themeLight
              ? Colors.grey[100]
              : Colors.grey[600],
          highlightColor: theme.getThemeName() == Constants.themeLight
              ? Colors.grey[300]
              : Colors.grey[900],
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                leading: CircleAvatar(),
                title: Container(
                  width: double.infinity,
                  height: 15.00,
                  color: Colors.white,
                ),
              );
            },
            itemCount: List.generate(10, (i) => i++).length,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void updateKeepAlive() {}

  @override
  bool get wantKeepAlive => true;
}
