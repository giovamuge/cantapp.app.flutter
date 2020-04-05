import 'package:cantapp/services/firestore_database.dart';
import 'package:cantapp/song/song_model.dart';
import 'package:cantapp/song/song_screen.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';

class SongSearchDelegate extends SearchDelegate {
  // Songs _songsData;
  SongSearchDelegate();

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) => searchSongs(context);

  @override
  Widget buildSuggestions(BuildContext context) => Container();

  Widget searchSongs(BuildContext context) {
    // List<Song> _songs = _songsData.items;

    if (query.length < 2) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
            child: Text(
              "Inserisci più di due ✌️ lettere \nper la ricerca. ",
              textAlign: TextAlign.center,
            ),
          )
        ],
      );
    }

    // var songSearchList = new List<Song>();
    // songSearchList.addAll(_songs);

    // List<Song> songListData = List<Song>();
    final database = Provider.of<FirestoreDatabase>(context,
        listen: false); // potrebbe essere true, da verificare

    // _songs.forEach((item) {
    //   var title = item.title.toLowerCase();
    //   var querylow = query.toLowerCase();

    //   if (title.contains(querylow)) {
    //     songListData.add(item);
    //   }
    // });

    print(query);

    return StreamBuilder(
        stream: database.songsSearchStream(textSearch: query.toLowerCase()),
        builder: (BuildContext context, AsyncSnapshot<List<Song>> snapshot) {
          if (snapshot.hasData && snapshot.data.isNotEmpty) {
            final List<Song> items = snapshot.data;
            return ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                return ListTile(
                    title: Text(items[index].title),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => SongScreen(song: items[index]))));
              },
            );
          } else {
            return Center(child: Text("Nessun risultato trovato. 🤔"));
          }
        });

    // if (songListData.length == 0) {
    //   return Center(child: Text("Nessun risultato trovato. 🤔"));
    // } else {
    //   return ListView.builder(
    //     itemCount: songListData.length,
    //     itemBuilder: (context, index) {
    //       return ListTile(
    //         title: Text(songListData[index].title),
    //         onTap: () => Navigator.of(context).push(
    //           MaterialPageRoute(
    //               builder: (context) => SongScreen(song: songListData[index])),
    //         ),
    //       );
    //     },
    //   );
    // }
  }
}