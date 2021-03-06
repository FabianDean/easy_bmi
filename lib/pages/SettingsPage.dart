import 'package:flutter/material.dart';
import 'package:easy_bmi/models/SystemModel.dart';
import 'package:provider/provider.dart';
import '../utils/globals.dart' as Globals;

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with AutomaticKeepAliveClientMixin {
  List<bool> _isSelected = [true, false];

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    final systemModel = Provider.of<SystemModel>(context, listen: false);

    return SafeArea(
      minimum: EdgeInsets.only(
        top: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              left: 20,
              bottom: 5,
            ),
            child: Text(
              "General",
              textScaleFactor: 1.1,
              style: TextStyle(
                color: Theme.of(context).textTheme.headline6.color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: 20,
              top: 10,
            ),
            child: ToggleButtons(
              isSelected: _isSelected,
              constraints: BoxConstraints(
                minWidth: 100,
                minHeight: 40,
              ),
              children: <Widget>[
                Text(
                  "Imperial",
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  "Metric",
                  style: TextStyle(fontSize: 16),
                ),
              ],
              selectedColor: Globals.mainColor,
              disabledColor: Colors.black26,
              fillColor: Globals.mainColor.withOpacity(0.1),
              borderColor: Theme.of(context).dividerColor,
              selectedBorderColor: Theme.of(context).dividerColor,
              onPressed: (int index) {
                setState(() {
                  for (int buttonIndex = 0;
                      buttonIndex < _isSelected.length;
                      buttonIndex++) {
                    if (buttonIndex == index) {
                      systemModel.changeToSystem(System.values[index]);
                      _isSelected[buttonIndex] = true;
                    } else {
                      _isSelected[buttonIndex] = false;
                    }
                  }
                });
              },
            ),
          ),
          SizedBox(
            height: 20,
          ),
          MaterialButton(
            child: Container(
              alignment: Alignment.centerLeft,
              height: 50,
              constraints: BoxConstraints(
                minWidth: MediaQuery.of(context).size.width,
              ),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.history,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    "History",
                    textScaleFactor: 1.3,
                  ),
                ],
              ),
            ),
            onPressed: () {
              Navigator.of(context).pushNamed("/history");
            },
          ),
          SizedBox(
            height: 10,
          ),
          MaterialButton(
            child: Container(
              alignment: Alignment.centerLeft,
              height: 50,
              constraints: BoxConstraints(
                minWidth: MediaQuery.of(context).size.width,
              ),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.info_outline,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    "Disclaimer",
                    textScaleFactor: 1.3,
                  ),
                ],
              ),
            ),
            onPressed: () {
              Navigator.of(context).pushNamed("/disclaimer");
            },
          ),
          SizedBox(
            height: 10,
          ),
          MaterialButton(
            child: Container(
              alignment: Alignment.centerLeft,
              height: 50,
              constraints: BoxConstraints(
                minWidth: MediaQuery.of(context).size.width,
              ),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.bug_report,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    "Report a bug",
                    textScaleFactor: 1.3,
                  ),
                ],
              ),
            ),
            onPressed: () {
              Navigator.of(context).pushNamed("/bug_report");
            },
          ),
        ],
      ),
    );
  }
}
