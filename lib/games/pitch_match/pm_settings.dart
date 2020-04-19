import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'bloc/pm_settings.dart';

class PitchMatchSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pitch Match Settings'),
      ),
      body: PitchMatchSettingsManager(),
    );
  }
}

class PitchMatchSettingsManager extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _PitchMatchSettingsManagerState();
}

class _PitchMatchSettingsManagerState extends State<PitchMatchSettingsManager> {

  Future<Null> setPreferences(bool isLowerVoice) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('PitchMatchLowerVoice', isLowerVoice);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, viewportConstraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: viewportConstraints.minHeight
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Divider(
                  indent: 10,
                  endIndent: 10,
                ),
                Consumer<PitchMatchSettingsState>(
                  builder: (_, pmSettingsState, __) {
                    return Padding(
                      padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                      child: Row(
                        children: <Widget>[
                          Expanded(child: Text('Lower voice')),
                          Switch(
                            value: pmSettingsState.lowerVoice,
                            onChanged: (bool value) {
                              setPreferences(value).whenComplete(() {
                                pmSettingsState.setLowerVoice(value);
                              });
                            },
                          )
                        ],
                      ),
                    );
                  },
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.fromLTRB(5, 5, 20, 5),
                        child: Icon(
                          Icons.info,
                          color: Colors.grey,
                        )
                      ),
                      Flexible(
                        child: DefaultTextStyle(
                          style: Theme.of(context).textTheme.overline,
                          child: Text(
                            'Enable this if you have a lower singing voice.'),
                        )
                      )
                    ],
                  ),
                ),
                Divider(
                  indent: 10,
                  endIndent: 10,
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
