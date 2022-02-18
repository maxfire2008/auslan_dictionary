import 'package:auslan_dictionary/main.dart';
import 'package:auslan_dictionary/types.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'common.dart';

class FavouritesPageController {
  void Function() refreshParent;

  FavouritesPageController(this.refreshParent);

  bool isMounted = false;

  void onMount() {
    isMounted = true;
  }

  void dispose() {
    isMounted = false;
  }

  Color getFloatingActionButtonColor() {
    return enableSortButton ? MAIN_COLOR : Colors.grey;
  }

  late void Function() toggleSort;

  // TODO: Let users choose to sort list items by default or not.
  bool viewSortedList = false;

  bool enableSortButton = true;

  void setEnableSortButton(bool value) {
    enableSortButton = value;
    refreshParent();
  }
}

class FavouritesPage extends StatefulWidget {
  final FavouritesPageController controller;

  FavouritesPage({Key? key, required this.controller}) : super(key: key);

  @override
  _FavouritesPageState createState() => _FavouritesPageState(controller);
}

class _FavouritesPageState extends State<FavouritesPage> {
  late FavouritesPageController controller;

  _FavouritesPageState(FavouritesPageController _controller) {
    controller = _controller;
    controller.toggleSort = toggleSort;
  }

  // All the user's favourites.
  late List<Word> favourites;

  // The favourites that match the user's search term.
  late List<Word> favouritesSearched;

  String currentSearchTerm = "";

  final _favouritesFieldController = TextEditingController();

  late Future<void> initStateAsyncFuture;
  late SharedPreferences prefs;

  void toggleSort() {
    setState(() {
      controller.viewSortedList = !controller.viewSortedList;
      search();
    });
  }

  @override
  void initState() {
    initStateAsyncFuture = initStateAsync();
    super.initState();
  }

  Future<void> initStateAsync() async {
    // I assume that we load the words first, don't change this order.
    await loadFavouritesInner();
    search();
  }

  Future<void> loadFavouritesInner() async {
    favourites = await loadFavourites(context);
    favouritesSearched = List.from(favourites);
  }

  void updateCurrentSearchTerm(String term) {
    setState(() {
      currentSearchTerm = term;
      controller.setEnableSortButton(currentSearchTerm.length == 0);
    });
  }

  void search() {
    setState(() {
      if (currentSearchTerm.length > 0) {
        favouritesSearched =
            searchList(currentSearchTerm, favourites, favourites);
      } else {
        favouritesSearched = List.from(favourites);
        if (controller.viewSortedList) {
          favouritesSearched.sort();
        }
      }
    });
  }

  void clearSearch() {
    setState(() {
      favouritesSearched = List.from(favourites);
      _favouritesFieldController.clear();
      updateCurrentSearchTerm("");
      search();
    });
  }

  void removeFavourite(Word word) {
    removeFromFavourites(word, context);
    setState(() {
      favourites.removeWhere((element) => element.word == word.word);
      search();
    });
  }

  Future<void> refreshFavourites() async {
    await loadFavouritesInner();
    setState(() {
      search();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: initStateAsyncFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return new Center(
              child: new CircularProgressIndicator(),
            );
          }
          return Container(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                        bottom: 10, left: 32, right: 32, top: 0),
                    child: Form(
                        child: Column(children: <Widget>[
                      TextField(
                        controller: _favouritesFieldController,
                        decoration: InputDecoration(
                          hintText: 'Search your favourites',
                          suffixIcon: IconButton(
                            onPressed: () {
                              clearSearch();
                            },
                            icon: Icon(Icons.clear),
                          ),
                        ),
                        // The validator receives the text that the user has entered.
                        onChanged: (String value) {
                          updateCurrentSearchTerm(value);
                          search();
                        },
                        autofocus: false,
                        textInputAction: TextInputAction.search,
                        keyboardType: TextInputType.visiblePassword,
                        autocorrect: false,
                      ),
                    ])),
                  ),
                  new Expanded(
                    child: listWidget(context, favouritesSearched, wordsGlobal,
                        removeFavourite, refreshFavourites),
                  ),
                ],
              ),
            ),
          );
        });
  }
}

Widget listWidget(
    BuildContext context,
    List<Word?> favouritesSearched,
    List<Word> allWords,
    Function removeFavouriteFn,
    Function refreshFavouritesFn) {
  return ListView.builder(
    itemCount: favouritesSearched.length,
    itemBuilder: (context, index) {
      return ListTile(
          title: listItem(context, favouritesSearched[index]!, allWords,
              removeFavouriteFn, refreshFavouritesFn));
    },
  );
}

Widget listItem(BuildContext context, Word word, List<Word> allWords,
    Function removeFavouriteFn, Function refreshFavouritesFn) {
  return FlatButton(
    child: Align(alignment: Alignment.topLeft, child: Text("${word.word}")),
    onPressed: () async => {
      await navigateToWordPage(context, word),
      await refreshFavouritesFn(),
    },
    onLongPress: () => removeFavouriteFn(word),
    splashColor: MAIN_COLOR,
  );
}
