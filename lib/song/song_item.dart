import 'package:cantapp/favorite/favorite.dart';
import 'package:cantapp/favorite/favorite_screen.dart';
import 'package:cantapp/song/song_model.dart';
import 'package:cantapp/song/song_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SongWidget extends StatelessWidget {
  Song song;
  int number;
  MaterialColor _avatarColor;
  MaterialColor _textColor;

  SongWidget(
      {Key key,
      @required this.song,
      @required this.number,
      avatarColor,
      textColor})
      : _avatarColor = avatarColor ?? Colors.purple,
        _textColor = textColor ??
            MaterialColor(
              0xFF000000,
              <int, Color>{
                50: Color(0xFF000000),
                100: Color(0xFF000000),
                200: Color(0xFF000000),
                300: Color(0xFF000000),
                400: Color(0xFF000000),
                500: Color(0xFF000000),
                600: Color(0xFF000000),
                700: Color(0xFF000000),
                800: Color(0xFF000000),
                900: Color(0xFF000000),
              },
            ),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    // var favoritesData = Provider.of<Favorites>(context);
    return Consumer<Favorites>(
      builder: (ctx, favoritesData, child) => ListTile(
        leading: CircleAvatar(
          maxRadius: 20,
          backgroundColor: _avatarColor[100],
          child: Text(
            '$number',
            style: TextStyle(
                color: _avatarColor[900],
                fontWeight: FontWeight.w800,
                fontSize: 11),
          ),
        ),
        title: Text(
          '${song.title}',
          style: TextStyle(fontWeight: FontWeight.bold, color: _textColor[900], fontSize: 15),
        ),
        subtitle:
            Text('Artista sconosciuto', style: TextStyle(color: _textColor[900], fontSize: 11)),
        // isThreeLine: true,
        // subtitle: Text("Prova"),
        dense: true,
        onTap: () => _navigateToSong(context, song),
        trailing: PopupMenuButton<OptionSong>(
          color: _textColor[900],
          onSelected: (OptionSong result) {
            if (result == OptionSong.add) {
              favoritesData.addFavorite(song.id);
              _messageSnackbar(context, OptionSong.add);
            }

            if (result == OptionSong.remove) {
              favoritesData.removeFavorite(song.id);
              _messageSnackbar(context, OptionSong.remove);
            }

            if (result == OptionSong.view) {
              _navigateToSong(context, song);
            }
          },
          itemBuilder: (ctx) => _buildOptions(ctx, favoritesData),
        ),
      ),
    );
  }

  List<PopupMenuEntry<OptionSong>> _buildOptions(
      BuildContext context, Favorites data) {
    List<PopupMenuItem<OptionSong>> result = [];
    if (data.exist(song.id)) {
      result.add(const PopupMenuItem<OptionSong>(
        value: OptionSong.remove,
        child: Text('💔 elimina preferito'),
      ));
    } else {
      result.add(const PopupMenuItem<OptionSong>(
        value: OptionSong.add,
        child: Text('❤️ salva preferito'),
      ));
    }

    return [
      ...result,
      const PopupMenuItem<OptionSong>(
        value: OptionSong.view,
        child: Text('🎶 canta'),
      ),
    ];
  }

  _messageSnackbar(BuildContext context, OptionSong option) {
    String msg;
    if (option == OptionSong.add) {
      msg = '${song.title} ❤️ aggiunto hai preferiti';
    } else {
      msg = '${song.title} 💔 rimosso dai preferiti';
    }
    SnackBar snackBar = SnackBar(
      backgroundColor: Colors.purple[100],
      elevation: 5,
      behavior: SnackBarBehavior.floating,
      content: Text(msg),
      action: option == OptionSong.remove
          ? null
          : SnackBarAction(
              label: 'visualizza',
              textColor: Colors.purple[800],
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => FavoriteScreen()),
              ),
            ),
    );

    Scaffold.of(context).showSnackBar(snackBar);
  }

  _navigateToSong(context, song) => Navigator.of(context).push(
        MaterialPageRoute(
            // fullscreenDialog: true, // sono sicuro?
            builder: (context) => SongScreen(song: song)),
      );
}

enum OptionSong { add, remove, view }