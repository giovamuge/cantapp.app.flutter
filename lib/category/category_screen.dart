import 'package:cantapp/category/category_model.dart' as cat;
import 'package:cantapp/song/song_model.dart';
import 'package:cantapp/widgets/list_songs_screen.dart';
import 'package:cantapp/widgets/title.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CategoryScreen extends StatefulWidget {
  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  // Categories _categoriesData;
  Songs _songsData;

  @override
  didChangeDependencies() async {
    super.didChangeDependencies();

    _songsData = Provider.of<Songs>(context);
    // _categoriesData = Provider.of<Categories>(context);
    // await _categoriesData.fetchSongsToCategories(_songsData.items);
  }

  @override
  Widget build(BuildContext context) {
    var categories = cat.Categories().items;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            TitleWidget(
              "Categoria",
              padding: const EdgeInsets.only(
                  top: 30, left: 15, right: 15, bottom: 15),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: categories.length,
              itemBuilder: (context, i) => ListTile(
                dense: true,
                trailing: Icon(
                  Icons.chevron_right,
                  size: 20.00,
                ),
                title: Text(categories[i].title),
                // enabled: categories[i].songs != null,
                onTap: () {
                  // print(categories[i].songs);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return ListSongsScreen(
                          items: _songsData.findByCategory(categories[i]),
                          title: categories[i].title,
                        );
                      },
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
