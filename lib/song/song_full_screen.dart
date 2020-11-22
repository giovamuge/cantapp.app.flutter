import 'package:cantapp/song/song_lyric.dart';
import 'package:cantapp/song/utils/lyric_util.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import 'utils/song_util.dart';

class SongFullScreen extends StatelessWidget {
  // @override
  // void initState() {
  //   super.initState();
  //   SystemChrome.setPreferredOrientations([
  //     DeviceOrientation.landscapeRight,
  //     DeviceOrientation.landscapeLeft,
  //   ]);
  // }

  // @override
  // dispose() {
  //   SystemChrome.setPreferredOrientations([
  //     DeviceOrientation.landscapeRight,
  //     DeviceOrientation.landscapeLeft,
  //     DeviceOrientation.portraitUp,
  //     DeviceOrientation.portraitDown,
  //   ]);
  //   super.dispose();
  // }

  final String _title;
  final String _body;
  final Widget _child;
  const SongFullScreen(
      {@required String body, @required String title, Widget child})
      : _body = body,
        _title = title,
        _child = child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(FontAwesomeIcons.compress),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.format_size),
            onPressed: () async =>
                await SongUtil().settingModalBottomSheet(context),
          )
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Consumer<SongLyric>(
          builder: (context, lyricData, child) {
            return Wrap(
              // alignment: WrapAlignment.start,
              // verticalDirection: VerticalDirection.down,
              // crossAxisAlignment: WrapCrossAlignment.start,
              direction: Axis.vertical,
              runSpacing: 25,
              spacing: 0,
              children: [
                Text(
                  _title,
                  style: TextStyle(
                    fontSize: lyricData.fontSize * 1.25,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 20),
                ...LyricUtil()
                    .buildLyric(context, _body, lyricData.fontSize, _child)
                // ..._buildLyric(context, lyricData.fontSize),
              ],
            );
            // return Column(
            //   children: [..._buildLyric(context, lyricData.fontSize)],
            // );
          },
        ),
      ),
    );
  }
}
