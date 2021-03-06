import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity/connectivity.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:easy_bmi/models/UserInputModel.dart';
import 'package:easy_bmi/utils/Result.dart';
import 'package:easy_bmi/widgets/SectionTitle.dart';
import '../widgets/Chart.dart';
import '../utils/globals.dart' as Globals;
import '../utils/Result.dart' as Res;

class ResultsPage extends StatefulWidget {
  @override
  _ResultsPageState createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Result _result;
  UserInputModel _inputModel;
  // manage state of modal progress HUD widget
  bool _isInAsyncCall = false;

  @override
  void initState() {
    _inputModel = Provider.of<UserInputModel>(context, listen: false);
    if (_inputModel.input != null) {
      setState(() {
        // calculate BMI here
        _result = Res.getResult(
          _inputModel.input.elementAt(0), // gender
          int.tryParse(_inputModel.input.elementAt(1)), // age
          double.parse(_inputModel.input.elementAt(2)), // height
          double.parse(_inputModel.input.elementAt(3)), // weight
          _inputModel.input.elementAt(4), // system of measurement
        );
      });
    }
    super.initState();
  }

  /* Body of the page. Contains actual content */
  Widget _resultsSection(BuildContext context) {
    Color indicatorColor;
    if (_result.category == Category.healthy)
      indicatorColor = Colors.green;
    else if (_result.category == Category.overweight)
      indicatorColor = Colors.yellow;
    else
      indicatorColor = Colors.red;

    return Consumer<UserInputModel>(
      builder: (context, userInputModel, child) {
        return userInputModel.input != null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 20), // add some padding to top
                  Align(
                    alignment: Alignment.center,
                    child: RichText(
                      text: TextSpan(
                        children: <TextSpan>[
                          TextSpan(
                            text: "A BMI of ",
                            style: GoogleFonts.montserrat(
                              color: Theme.of(context)
                                  .textTheme
                                  .headline6
                                  .color
                                  .withOpacity(0.9),
                              fontSize: 22,
                            ),
                          ),
                          TextSpan(
                            text: _result.bmi.toString(),
                            style: GoogleFonts.montserrat(
                              color: Theme.of(context).accentColor,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: (" is considered "),
                            style: GoogleFonts.montserrat(
                              color: Theme.of(context)
                                  .textTheme
                                  .headline6
                                  .color
                                  .withOpacity(0.9),
                              fontSize: 22,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      _result.category
                          .toString()
                          .substring(9)
                          .toUpperCase(), // removes "Category." in string
                      style: GoogleFonts.montserrat(
                        color: indicatorColor,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Chart(category: _result.category),
                  SizedBox(height: 10),
                  Divider(indent: 20, endIndent: 20),
                  _inputSection(),
                  Divider(indent: 20, endIndent: 20),
                  SizedBox(height: 10),
                  SectionTitle("Summary"),
                  SizedBox(height: 10),
                  Text(
                    _result.summary,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.caption.color,
                    ),
                    textScaleFactor: 1.2,
                  ),
                  SizedBox(height: 20),
                  SectionTitle("More Information"),
                  SizedBox(height: 10),
                  RichText(
                    textScaleFactor: 1.2,
                    text: TextSpan(
                      text: "Details about BMI can be found ",
                      style: TextStyle(
                        color: Theme.of(context).textTheme.caption.color,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                            text: "here",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).accentColor,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () async {
                                if (_inputModel.input.elementAt(1) == "null") {
                                  await _launchInBrowser(
                                      "https://www.cdc.gov/healthyweight/assessing/bmi/adult_bmi/index.html");
                                } else {
                                  await _launchInBrowser(
                                      "https://www.cdc.gov/healthyweight/assessing/bmi/childrens_bmi/about_childrens_bmi.html");
                                }
                              }),
                        TextSpan(text: "."),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              )
            : Text(
                "User input not detected",
                style: Theme.of(context).textTheme.headline6,
              );
      },
    );
  }

  /* Holds information used for calculation (gender, age, height, weight) */
  Widget _inputSection() {
    /* Quick helper widget to avoid code duplication in input section */
    Widget item(dynamic value, String unit) {
      return RichText(
        text: TextSpan(
          children: <TextSpan>[
            TextSpan(
              text: value == null ? "N/A" : value.toString(),
              style: Theme.of(context).textTheme.caption.copyWith(
                    fontSize: 18,
                  ),
            ),
            unit == null
                ? TextSpan()
                : TextSpan(
                    text: unit,
                    style: GoogleFonts.montserrat(
                      color: Theme.of(context)
                          .textTheme
                          .headline6
                          .color
                          .withOpacity(0.5),
                      fontSize: 18,
                    ),
                  ),
          ],
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Column(
          children: <Widget>[
            item(_inputModel.input.elementAt(0), null),
            SizedBox(height: 10),
            item(_inputModel.input.elementAt(2),
                _inputModel.input.elementAt(4) == "Imperial" ? " in" : " cm"),
          ],
        ),
        Column(
          children: <Widget>[
            _inputModel.input.elementAt(1) == "null"
                ? item(null, null)
                : Row(
                    children: <Widget>[
                      item(int.parse(_inputModel.input.elementAt(1)) ~/ 12,
                          " y"),
                      SizedBox(width: 5),
                      item(int.parse(_inputModel.input.elementAt(1)) % 12, " m")
                    ],
                  ),
            SizedBox(height: 10),
            item(_inputModel.input.elementAt(3),
                _inputModel.input.elementAt(4) == "Imperial" ? " lbs" : " kg"),
          ],
        )
      ],
    );
  }

  Future<void> _launchInBrowser(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: false,
        forceWebView: false,
        headers: <String, String>{'my_header_key': 'my_header_value'},
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<bool> _checkInternet() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> _printChart() async {
    String system =
        _inputModel.input.elementAt(4) == "Imperial" ? "english" : "metric";
    String gender = _inputModel.input.elementAt(0) == "Male" ? "m" : "f";
    String age = _inputModel.input.elementAt(1);
    String height = _inputModel.input.elementAt(2);
    String weight = _inputModel.input.elementAt(3);
    http.Response response = await http.get(
      'https://easybmi-chart.herokuapp.com/bmichart?system=$system&gender=$gender&age=$age&height=$height&weight=$weight',
    );
    var pdfData = response.bodyBytes;
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdfData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Globals.mainColor,
        title: Text(
          "Results",
          style: GoogleFonts.montserrat(),
        ),
        actions: _inputModel.input.elementAt(1) == "null"
            ? null
            : <Widget>[
                MaterialButton(
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.print, color: Colors.white),
                        SizedBox(width: 5),
                        Text(
                          "Growth Chart",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    onPressed: () async {
                      // start the modal progress HUD
                      setState(() {
                        _isInAsyncCall = true;
                      });
                      bool hasInternet = await _checkInternet();
                      if (hasInternet) {
                        await _printChart();
                      } else {
                        _scaffoldKey.currentState.showSnackBar(SnackBar(
                          backgroundColor: Colors.red,
                          content: Text(
                            "An internet connection is required for this feature.",
                            style: TextStyle(color: Colors.white),
                          ),
                        ));
                      }
                      // end the modal progress HUD
                      setState(() {
                        _isInAsyncCall = false;
                      });
                    }),
              ],
      ),
      body: ModalProgressHUD(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraint) {
              return SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: constraint.maxWidth,
                    minHeight: constraint.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: _result != null
                        ? _resultsSection(context)
                        : CircularProgressIndicator(),
                  ),
                ),
              );
            },
          ),
        ),
        inAsyncCall: _isInAsyncCall,
        opacity: 0.4,
        progressIndicator: CircularProgressIndicator(),
      ),
    );
  }
}
