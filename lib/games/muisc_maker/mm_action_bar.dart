import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'bloc/mm_state.dart';
import 'mm_edit_melody_meta_dialog.dart';

class MusicMakerActionBar extends StatefulWidget implements PreferredSizeWidget {
  @override
  State<StatefulWidget> createState() => new _MusicMakerActionBarState();

  @override
  Size get preferredSize => AppBar().preferredSize;
}

class _MusicMakerActionBarState extends State<MusicMakerActionBar> {
  bool _isSaving = false;

  Future<void> _showMetaDataDialog() {
    var mmState = Provider.of<MusicMakerState>(context, listen: false);
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return MelodyMetadataDialog(mmState: mmState);
        });
  }

  Future<dynamic> _saveMelody() {
    setState(() { _isSaving = true; });
    var mmState = Provider.of<MusicMakerState>(context, listen: false);
    var melodyJson = mmState.melody.toJson();
    var docRef = mmState.documentReference;
    if (docRef == null) {
      return Firestore.instance.collection('melodies').document().setData(melodyJson);
    } else {
      return Firestore.instance.runTransaction((transaction) async {
        DocumentSnapshot newSnap = await transaction.get(docRef);
        await transaction.update(newSnap.reference, melodyJson);
      });
    }
  }

  Future<bool> _onBackPressed() {
    var mmState = Provider.of<MusicMakerState>(context, listen: false);
    if (mmState.modified) {
      return showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: Text('Do you want to exit?'),
            content:
              Text('You have unsaved changes to ${mmState.melody.title}.'),
            actions: <Widget>[
              FlatButton(
                child: Text('Yes'),
                textColor: Colors.grey,
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
              FlatButton(
                child: Text('No'),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
            ],
            shape: ContinuousRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(50))
            )
          )
      );
    }
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MusicMakerState>(builder: (_, mmState, __) {
        return WillPopScope(
          onWillPop: () => _onBackPressed(),
          child: AppBar(
            title: Text(mmState.melody.title),
            actions: <Widget>[
              IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => _showMetaDataDialog()
              ),
              _isSaving
                  ? Padding(
                      padding: EdgeInsets.all(10),
                      child: CircularProgressIndicator(
                          backgroundColor: Colors.white
                      )
                    )
                  : IconButton(
                      icon: Icon(Icons.save),
                      onPressed: mmState.modified ? () {
                        _saveMelody().whenComplete(() {
                          setState(() { _isSaving = false; });
                          mmState.setModified(false);
                          var snackBar = SnackBar(
                              content: Text('Melody saved'));
                          Scaffold.of(context).showSnackBar(snackBar);
                        });
                      } : null
                    ),
            ],
          ),
        );
      }
    );
  }
}
