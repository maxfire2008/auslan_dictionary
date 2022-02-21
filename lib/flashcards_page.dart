import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:settings_ui/settings_ui.dart';

import 'common.dart';
import 'globals.dart';
import 'settings_page.dart';
import 'types.dart';

// - The first screen for flashcards should be something that lets you choose
//   what list to revise. At first only favourites.
// - Once you start the review, push navigation, so you can't change the favourites
//   mid review.
// - In the settings, let people choose what state(s) they want to see flashcards for.
//   - What about the regional information unknown case?
// - In the settings, let people choose sign -> word and word -> sign.
// - In the flashcards app bar have a history button to see a summary of previous flashcard sessions.
// - In the settings, let people choose between random revision and spaced repetition, and in order (alphabetical or insertion order).
// - Add option to choose limit, like x cards at a time.

const String KEY_SIGN_TO_WORD = "sign_to_word";
const String KEY_WORD_TO_SIGN = "word_to_sign";

class FlashcardsPageController {
  bool isMounted = false;

  void onMount() {
    isMounted = true;
  }

  void dispose() {
    isMounted = false;
  }

  void Function() goToSettingsFunction;

  FlashcardsPageController(this.goToSettingsFunction);
}

class FlashcardsLandingPage extends StatefulWidget {
  final FlashcardsPageController controller;

  FlashcardsLandingPage({Key? key, required this.controller}) : super(key: key);

  @override
  _FlashcardsLandingPageState createState() =>
      _FlashcardsLandingPageState(controller);
}

class _FlashcardsLandingPageState extends State<FlashcardsLandingPage> {
  late FlashcardsPageController controller;

  _FlashcardsLandingPageState(FlashcardsPageController _controller) {
    controller = _controller;
  }

  void onPrefSwitch(String key, bool newValue) {
    setState(() {
      sharedPreferences.setBool(key, newValue);
    });
  }

  @override
  Widget build(BuildContext context) {
    EdgeInsetsDirectional margin =
        EdgeInsetsDirectional.only(start: 15, end: 15, top: 10, bottom: 10);

    List<AbstractSettingsSection?> sections = [
      SettingsSection(
        title: Text('Revision Settings'),
        tiles: [
          SettingsTile.switchTile(
            title: Text(
              'Sign -> Word',
              style: TextStyle(fontSize: 15),
            ),
            initialValue: sharedPreferences.getBool(KEY_SIGN_TO_WORD) ?? true,
            onToggle: (newValue) => onPrefSwitch(KEY_SIGN_TO_WORD, newValue),
          ),
          SettingsTile.switchTile(
            title: Text(
              'Word -> Sign',
              style: TextStyle(fontSize: 15),
            ),
            initialValue: sharedPreferences.getBool(KEY_WORD_TO_SIGN) ?? true,
            onToggle: (newValue) => onPrefSwitch(KEY_WORD_TO_SIGN, newValue),
          ),
          SettingsTile.navigation(
            title: getText(
              'Select revision technique',
            ),
            trailing: Container(),
            onPressed: (BuildContext context) async {
              // TODO
            },
          ),
          SettingsTile.navigation(
              title: getText("Select flashcard regions"),
              trailing: Container(),
              onPressed: (BuildContext context) async {
                await showDialog(
                  context: context,
                  builder: (ctx) {
                    List<int> initialValues = (sharedPreferences
                                .getStringList(KEY_FLASHCARD_REGIONS) ??
                            [])
                        .map((e) => e as int)
                        .toList();
                    return MultiSelectDialog(
                      items: Region.values
                          .map((e) => MultiSelectItem(e.index, e.pretty))
                          .toList(),
                      initialValue: initialValues,
                      onConfirm: (values) {
                        sharedPreferences.setStringList(KEY_FLASHCARD_REGIONS,
                            values.map((e) => e.toString()).toList());
                      },
                    );
                  },
                );
              }),
        ],
        margin: margin,
      ),
    ];

    List<AbstractSettingsSection> nonNullSections = [];
    for (AbstractSettingsSection? section in sections) {
      if (section != null) {
        nonNullSections.add(section);
      }
    }

    Widget settings = SettingsList(
      sections: nonNullSections,
    );

    return Container(
      child: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 30),
          ),
          TextButton(
            child: Text(
              "Start",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20),
            ),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(MAIN_COLOR),
              foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
              minimumSize: MaterialStateProperty.all<Size>(Size(120, 50)),
            ),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FlashcardsPage()),
              );
            },
          ),
          Expanded(child: settings),
        ],
      )),
      color: Color(0xFFEFEFF4),
    );
  }
}

class FlashcardsPage extends StatefulWidget {
  FlashcardsPage({Key? key}) : super(key: key);

  @override
  _FlashcardsPageState createState() => _FlashcardsPageState();
}

class _FlashcardsPageState extends State<FlashcardsPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Start", style: TextStyle(fontSize: 1)),
      ],
    );
  }
}
