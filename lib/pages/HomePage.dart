import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_bmi/models/UserInputModel.dart';
import 'package:easy_bmi/models/SystemModel.dart';
import '../widgets/SectionTitle.dart';
import '../utils/globals.dart' as Globals;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  List<bool> _isSelected = [true, false];
  final _weightKey = GlobalKey<FormFieldState>();
  TextEditingController _weightController = TextEditingController();
  final _heightKey = GlobalKey<FormFieldState>();
  TextEditingController _heightController = TextEditingController();
  SharedPreferences _prefs;
  int _years;
  int _months;
  List<dynamic> _validYears = List.generate(19, (index) {
    if (index == 0) return "Years";
    return index + 1;
  });
  List<dynamic> _validMonths = List.generate(12, (index) {
    if (index == 0) return "Months";
    return index;
  });

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    _getPrefs();
    super.initState();
  }

  Future<void> _getPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> _saveData() async {
    final systemModel = Provider.of<SystemModel>(context, listen: false);
    final keys = _prefs.getKeys();

    // limit to 10 data sets saved in memory
    if (keys.length >= 10) {
      await _prefs
          .remove(keys.first); // remove oldest key before adding new data
    }

    int age; // age in months
    if (_years != null) {
      age = (_years * 12) + (_months == null ? 0 : _months);
    }
    await _prefs.setStringList(DateTime.now().toString() + "_bmi", [
      _isSelected[0] == true ? "Male" : "Female",
      age.toString(),
      _heightKey.currentState.value.toString(),
      _weightKey.currentState.value.toString(),
      systemModel.system == System.imperial ? "Imperial" : "Metric",
    ]);
  }

  void _updateInputModel() {
    final inputModel = Provider.of<UserInputModel>(context, listen: false);
    final systemModel = Provider.of<SystemModel>(context, listen: false);

    int age; // age in months
    if (_years != null) {
      age = (_years * 12) + (_months == null ? 0 : _months);
    }
    inputModel.changeInput([
      _isSelected[0] == true ? "Male" : "Female",
      age.toString(),
      _heightKey.currentState.value.toString(),
      _weightKey.currentState.value.toString(),
      systemModel.system == System.imperial ? "Imperial" : "Metric",
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 10),
      child: LayoutBuilder(
        builder: (context, constraint) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraint.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(
                              height: MediaQuery.of(context).size.height < 700
                                  ? 0
                                  : 10,
                            ),
                            Text(
                              "Calculate",
                              textScaleFactor: 2.5,
                              style: TextStyle(
                                color:
                                    Theme.of(context).textTheme.headline5.color,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              "BMI",
                              textScaleFactor: 2.0,
                              style: TextStyle(
                                color:
                                    Theme.of(context).textTheme.headline6.color,
                              ),
                            ),
                          ],
                        ),
                        Spacer(),
                        SvgPicture.asset(
                          Theme.of(context).brightness == Brightness.light
                              ? 'assets/images/light_homeArt.svg'
                              : 'assets/images/dark_homeArt.svg',
                          height: MediaQuery.of(context).size.height < 700
                              ? 100
                              : null,
                        ),
                      ],
                    ),
                    SectionTitle("Gender"),
                    SizedBox(
                      height: MediaQuery.of(context).size.height < 700 ? 5 : 10,
                    ),
                    ToggleButtons(
                      isSelected: _isSelected,
                      constraints: BoxConstraints(
                        minWidth: 100,
                        minHeight: 40,
                      ),
                      children: <Widget>[
                        Text(
                          "Male",
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          "Female",
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
                              _isSelected[buttonIndex] = true;
                            } else {
                              _isSelected[buttonIndex] = false;
                            }
                          }
                        });
                      },
                    ),
                    Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        SectionTitle("Age (optional)"),
                        Text(
                          "*BMI-for-Age: 2-20 yrs only",
                          style: Theme.of(context).textTheme.caption,
                        )
                      ],
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height < 700 ? 5 : 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          width: 80,
                          child: DropdownButtonFormField(
                            value: _years,
                            hint: Text(
                              "Years",
                              style:
                                  Theme.of(context).textTheme.caption.copyWith(
                                        fontSize: 20,
                                        color: Theme.of(context)
                                            .textTheme
                                            .caption
                                            .color
                                            .withOpacity(0.5),
                                      ),
                            ),
                            items: _validYears
                                .map(
                                  (item) => DropdownMenuItem(
                                    value: item is String ? null : item,
                                    child: Center(
                                      child: Text(
                                        "$item",
                                        style: Theme.of(context)
                                            .textTheme
                                            .caption
                                            .copyWith(
                                              fontSize: 20,
                                              color: !(item is String)
                                                  ? Globals.mainColor
                                                  : Theme.of(context)
                                                      .textTheme
                                                      .caption
                                                      .color
                                                      .withOpacity(0.5),
                                            ),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _years = value is String ? null : value;
                              });
                            },
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          "yrs",
                          style: TextStyle(
                            color: Theme.of(context).textTheme.headline5.color,
                          ),
                        ),
                        SizedBox(width: 60),
                        SizedBox(
                          width: 100,
                          child: DropdownButtonFormField(
                            value: _months,
                            hint: Text(
                              "Months",
                              style:
                                  Theme.of(context).textTheme.caption.copyWith(
                                        fontSize: 20,
                                        color: Theme.of(context)
                                            .textTheme
                                            .caption
                                            .color
                                            .withOpacity(0.5),
                                      ),
                            ),
                            items: _validMonths
                                .map(
                                  (item) => DropdownMenuItem(
                                    value: item is String ? null : item,
                                    child: Text(
                                      "$item",
                                      style: Theme.of(context)
                                          .textTheme
                                          .caption
                                          .copyWith(
                                            fontSize: 20,
                                            color: !(item is String)
                                                ? Globals.mainColor
                                                : Theme.of(context)
                                                    .textTheme
                                                    .caption
                                                    .color
                                                    .withOpacity(0.5),
                                          ),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _months = value is String ? null : value;
                              });
                            },
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          "mos",
                          style: TextStyle(
                            color: Theme.of(context).textTheme.headline5.color,
                          ),
                        ),
                      ],
                    ),
                    Spacer(),
                    SectionTitle("Height"),
                    SizedBox(
                      height: MediaQuery.of(context).size.height < 700 ? 0 : 10,
                    ),
                    Consumer<SystemModel>(
                      builder: (context, systemModel, child) {
                        return Row(
                          children: <Widget>[
                            Expanded(
                              flex: 1,
                              child: TextFormField(
                                key: _heightKey,
                                controller: _heightController,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                maxLength: systemModel.system == System.imperial
                                    ? 4
                                    : 5,
                                buildCounter: (BuildContext context,
                                        {int currentLength,
                                        int maxLength,
                                        bool isFocused}) =>
                                    null,
                                style: TextStyle(
                                  fontSize: 22,
                                  color: Globals.mainColor,
                                ),
                                decoration: InputDecoration(
                                  hintText: "Enter height",
                                  hintStyle: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .caption
                                        .color
                                        .withOpacity(0.5),
                                    fontSize: 20,
                                  ),
                                ),
                                cursorColor: Globals.mainColor,
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Please enter a number';
                                  }
                                  double height = double.parse(value);
                                  if (systemModel.system == System.imperial &&
                                      (height < 20 || height > 90)) {
                                    return 'Number must be between 20 and 90';
                                  }
                                  if (systemModel.system == System.metric &&
                                      (height < 50 || height > 229)) {
                                    return 'Number must be between 50 and 229';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                systemModel.system == System.imperial
                                    ? " inches (in)"
                                    : " centimeters (cm)",
                                textScaleFactor: 1.3,
                                maxLines: 1,
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .headline5
                                        .color),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    Spacer(),
                    SectionTitle("Weight"),
                    SizedBox(
                      height: MediaQuery.of(context).size.height < 700 ? 0 : 10,
                    ),
                    Consumer<SystemModel>(
                      builder: (context, systemModel, child) {
                        return Row(
                          children: <Widget>[
                            Expanded(
                              flex: 1,
                              child: TextFormField(
                                key: _weightKey,
                                controller: _weightController,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                maxLength: 5,
                                buildCounter: (BuildContext context,
                                        {int currentLength,
                                        int maxLength,
                                        bool isFocused}) =>
                                    null,
                                style: TextStyle(
                                  fontSize: 22,
                                  color: Globals.mainColor,
                                ),
                                cursorColor: Globals.mainColor,
                                decoration: InputDecoration(
                                  hintText: "Enter weight",
                                  hintStyle: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .caption
                                        .color
                                        .withOpacity(0.5),
                                    fontSize: 20,
                                  ),
                                ),
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Please enter a number';
                                  }
                                  double weight = double.parse(value);
                                  if (systemModel.system == System.imperial &&
                                      (weight < 10 || weight > 400)) {
                                    return 'Number must be between 10 and 400';
                                  }
                                  if (systemModel.system == System.metric &&
                                      (weight < 1 || weight > 182)) {
                                    return 'Number must be between 4 and 182';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                systemModel.system == System.imperial
                                    ? " pounds (lbs)"
                                    : " kilograms (kg)",
                                textScaleFactor: 1.3,
                                maxLines: 1,
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .headline5
                                        .color),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    Spacer(),
                    Center(
                      child: MaterialButton(
                        height: 50,
                        minWidth: MediaQuery.of(context).size.width,
                        child: Text("CALCULATE"),
                        color: Globals.mainColor,
                        textTheme: ButtonTextTheme.primary,
                        onPressed: () async {
                          String message;
                          if (_months != null &&
                              _months > 0 &&
                              _years == null) {
                            message =
                                "Minimum age for BMI-for-Age is 2 years old";
                          }
                          if ((message == null) &
                              _heightKey.currentState.validate() &
                              _weightKey.currentState.validate()) {
                            await _saveData();
                            _updateInputModel();
                            Navigator.of(context).pushNamed("/results");
                          }
                          if (message != null) {
                            Scaffold.of(context).showSnackBar(
                              SnackBar(
                                content: Text(message),
                                backgroundColor: Colors.red,
                                duration: Duration(milliseconds: 3500),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
