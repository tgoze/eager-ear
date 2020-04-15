import 'package:eager_ear/games/muisc_maker/bloc/mm_state.dart';
import 'package:flutter/material.dart';

class MelodyMetadataDialog extends StatefulWidget {
  MelodyMetadataDialog({Key key, this.mmState}) : super(key: key);

  final MusicMakerState mmState;

  @override
  State<StatefulWidget> createState() => new _MelodyMetadataDialogState();
}

class _MelodyMetadataDialogState extends State<MelodyMetadataDialog> {
  final _metaFormKey = new GlobalKey<FormState>();
  final _titleEditingController = TextEditingController();
  bool _lowerVoice = false;

  @override
  Widget build(BuildContext context) {
    _titleEditingController.text = widget.mmState.melody.title;
    return Dialog(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 280.0),
            child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
              Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
                Padding(
                    padding: EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 0.0),
                    child: DefaultTextStyle(
                      style: Theme.of(context).textTheme.title,
                      child: Text('Edit Melody Details'),
                    ))
              ]),
              Padding(
                padding: EdgeInsets.fromLTRB(24.0, 10, 24.0, 0.0),
                child: Form(
                    key: _metaFormKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        TextFormField(
                          controller: _titleEditingController,
                          decoration:
                              InputDecoration(labelText: 'Enter a melody title'),
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter a title';
                            }
                            return null;
                          },
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                          child: Row(
                            children: <Widget>[
                              Expanded(child: Text('Lower voice')),
                              Switch(
                                value: widget.mmState.melody.lowerVoice,
                                onChanged: (bool value) => _lowerVoice = value,
                              )
                            ],
                          ),
                        )
                      ],
                    )),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(24.0, 24.0, 0.0, 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    FlatButton(
                      child: Text('Cancel'),
                      textColor: Colors.blue,
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    FlatButton(
                      child: Text('Save'),
                      textColor: Colors.green,
                      onPressed: () {
                        if (_metaFormKey.currentState.validate()) {
                          var newTitle = _titleEditingController.text;
                          widget.mmState.setTitle(newTitle);
                          widget.mmState.setIsLowerVoice(_lowerVoice);
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                  ],
                ),
              )
            ]),
          ),
        ),
        shape: ContinuousRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(50))));
  }

  @override
  void dispose() {
    _titleEditingController.dispose();
    super.dispose();
  }
}
