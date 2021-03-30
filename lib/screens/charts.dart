import 'dart:async';
import 'dart:convert' show utf8;
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:respiration_chamber_controller/screens/chartsdata.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ChartPage extends StatefulWidget {
  const ChartPage({Key key, this.device}) : super(key: key);

  final BluetoothDevice device;

  @override
  _ChartPageState createState() => _ChartPageState();
}

List allData = [];
int count = 0;

class _ChartPageState extends State<ChartPage> {
  final String serviceUUId = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
  final String characteristicUUId = "beb5483e-36e1-4688-b7f5-ea07361b26a8";
  bool isReady = false;
  Stream<List> stream;
  BluetoothCharacteristic targetCharacteristics;

  String state;

  @override
  void initState() {
    super.initState();

    connectToDevice();
    writeData(
        "Date, Time, Air Temperature(°C), Relative Humidity, Chamber Pressure(mBAR), Soil Moisture(%),Soil Temperature(°C),Chamber Status\r");
  }

  connectToDevice() async {
    if (widget.device == null) {
      _pop();
      return;
    }

    new Timer(const Duration(seconds: 15), () {
      if (!isReady) {
        disconnectFromDevice();
        _pop();
      }
    });

    await widget.device.connect();
    discoverServices();
  }

  disconnectFromDevice() {
    if (widget.device == null) {
      _pop();
      return;
    }
    widget.device.disconnect();
  }

  discoverServices() async {
    if (widget.device == null) {
      _pop();
      return;
    }

    List<BluetoothService> services = await widget.device.discoverServices();
    services.forEach((service) {
      if (service.uuid.toString() == serviceUUId) {
        service.characteristics.forEach((characteristic) {
          if (characteristic.uuid.toString() == characteristicUUId) {
            characteristic.setNotifyValue(!characteristic.isNotifying);
            stream = characteristic.value;
            targetCharacteristics = characteristic;

            setState(() {
              isReady = true;
              // writeData('1');
            });
          }
        });
      }
    });

    if (!isReady) {
      // _pop()
    }
  }

  _pop() {
    Navigator.of(context).pop(true);
  }

  String _dataParser(List<int> datafromdevice) {
    return utf8.decode(datafromdevice);
  }

  sendData(String data) async {
    if (targetCharacteristics == null) return;
    List<int> bytes = utf8.encode(data);
    await targetCharacteristics.write(bytes);
  }

  bool switchOn = false; // to check state of toggle switch
  String currentValue = '0'; // toggle switch data from device
  var text = ['...', '...', '...', '...', '...', '...'];
  var dataText = ['...', '...', '...', '...', '...'];
  var lastTwo = ['...', '...', '...', '...', '...', '...'];
  String recentValue = " ";
  String saveData;
  double airTemp = -50.0;
  String status = "";

  List<DataSet> temperature = [];
  List<DataSet> humidity = [];
  List<DataSet> pressure = [];
  List<DataSet> soilMoisture = [];
  List<DataSet> soilTemperature = [];
  File ourFile;

  int delay = 1;

  List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];

  // on back button pressed function

  Future<bool> _onBackButtonPressed() {
    return showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(
              title: Text('Are you sure?'),
              content: Text('Do you want to disconnect device and go back?'),
              actions: <Widget>[
                FlatButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text('No')),
                FlatButton(
                    onPressed: () {
                      disconnectFromDevice();
                      Navigator.of(context).pop(true);
                      // SystemNavigator.pop();
                    },
                    child: Text('Yes')),
              ],
            ) ??
            false);
  }

  // Storing codes starts from here

  void writeData(String data) async {
    Directory appDocDir = await getExternalStorageDirectory();
    String appDocPath = appDocDir.path;

    final dateTime2 = DateTime.now();
    String fileName =
        "${dateTime2.day} ${months[dateTime2.month - 1]} ${dateTime2.year}";
    ourFile = File('$appDocPath/$fileName.csv');
    ourFile.writeAsString(data, mode: FileMode.writeOnlyAppend);
    print(ourFile.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('CS-RC5'),
      ),
      body: WillPopScope(
        onWillPop: _onBackButtonPressed,
        child: SingleChildScrollView(
          dragStartBehavior: DragStartBehavior.start,
          scrollDirection: Axis.vertical,
          child: Center(
            child: !isReady
                ? Text('Waiting for data........')
                : Container(
                    child: StreamBuilder<List>(
                      stream: stream,
                      builder:
                          (BuildContext context, AsyncSnapshot<List> snapshot) {
                        if (snapshot.hasError) {
                          Timer(Duration(seconds: 30), () {
                            print('done');
                          });
                          return Center(
                            child: CircularProgressIndicator(
                              backgroundColor: Colors.lightBlueAccent,
                            ),
                          );
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.active) {
                          currentValue = _dataParser(snapshot.data);

                          try {
                            lastTwo = currentValue.split('+');
                            recentValue = currentValue[0] +
                                "+" +
                                currentValue[1] +
                                currentValue[2] +
                                currentValue[3] +
                                "+" +
                                currentValue[4] +
                                currentValue[5] +
                                currentValue[6] +
                                currentValue[7] +
                                currentValue[8] +
                                "+" +
                                currentValue[9] +
                                currentValue[10] +
                                currentValue[11] +
                                "+" +
                                lastTwo[1] +
                                "+" +
                                lastTwo[2];
                            print(recentValue);
                          } catch (e) {
                            print(e);
                            recentValue = "0+0+0+0+0+0";
                          }

                          var currentStatus = text[0];
                          if (currentStatus == "1") {
                            switchOn = true;
                            status = "Open";
                          } else if (currentStatus == "0") {
                            switchOn = false;
                            status = "Closed";
                          }

                          final dateTime = DateTime.now();
                          String time =
                              "${dateTime.hour}:${dateTime.minute}:${dateTime.second}";
                          String date =
                              "${dateTime.day}.${dateTime.month}.${dateTime.year}";
                          try {
                            text = recentValue.split('+');

                            double airTemp = double.parse(text[1]);

                            airTemp = (airTemp / 10) - 25.0;

                            double chPressure = double.parse(text[2]);
                            chPressure = chPressure / 10;

                            double soilTemp = double.parse(text[3]);
                            soilTemp = (soilTemp / 10) - 25.0;

                            double relHumidity = double.parse(text[4]);

                            double soilMois = double.parse(text[5]);

                            temperature.add(DataSet(time, airTemp));
                            humidity.add(DataSet(time, relHumidity));
                            pressure.add(DataSet(time, chPressure));
                            soilMoisture.add(DataSet(time, soilMois));
                            soilTemperature.add(DataSet(time, soilTemp));

                            if (temperature.length >= 6) {
                              temperature.removeAt(0);
                              humidity.removeAt(0);
                              pressure.removeAt(0);
                              soilMoisture.removeAt(0);
                              soilTemperature.removeAt(0);
                            }
                            dataText[0] = airTemp.toStringAsFixed(2);
                            dataText[1] = relHumidity.toString();
                            dataText[2] = chPressure.toString();
                            dataText[3] = soilMois.toString();
                            dataText[4] = soilTemp.toStringAsFixed(2);

                            String data =
                                "$date,$time,${dataText[0]},${dataText[1]},${dataText[2]},${dataText[3]},${dataText[4]},$status\r";

                            writeData(data);
                            String timeAndDate =
                                "${dateTime.hour}:${dateTime.minute}:${dateTime.second}:${dateTime.day}:${dateTime.month}:${dateTime.year}";
                            print(timeAndDate);
                            sendData(timeAndDate);
                          } catch (e) {
                            print(e);
                            Timer(const Duration(seconds: 20), () {
                              return Center(
                                child: CircularProgressIndicator(
                                  backgroundColor: Colors.lightBlueAccent,
                                ),
                              );
                            });
                          }
                        }

                        return Container(
                          child: snapshot.hasData == null
                              ? Center(
                                  child: CircularProgressIndicator(
                                    backgroundColor: Colors.lightBlueAccent,
                                  ),
                                )
                              : Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                            flex: 3,
                                            child: Container(
                                                margin: EdgeInsets.symmetric(
                                                    vertical: 5.0,
                                                    horizontal: 10.0),
                                                child: Text(
                                                  'Chamber Status',
                                                  style: TextStyle(
                                                      fontSize: 20.0,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ))),
                                        Container(
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 3.0),
                                          child: Card(
                                            elevation: 4.0,
                                            color: Colors.white30,
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(30.0))),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(
                                                              30.0)),
                                                  border: Border.all(
                                                      color: Colors.blueGrey,
                                                      width: 2.0)),
                                              margin: EdgeInsets.all(4.0),
                                              child: FlutterSwitch(
                                                toggleColor: Color(0xFFBDBDBD),
                                                activeText: "Open",
                                                activeColor: Colors.blueGrey,
                                                inactiveColor: Colors.blueGrey,
                                                inactiveText: "Closed",
                                                width: 115.0,
                                                height: 40.0,
                                                valueFontSize: 15.0,
                                                toggleSize: 35.0,
                                                value: switchOn,
                                                borderRadius: 20.0,
                                                showOnOff: true,
                                                onToggle: (value) {
                                                  setState(() {
                                                    switchOn = value;
                                                    if (!value) {
                                                      sendData('closed');
                                                    } else {
                                                      sendData('open');
                                                    }
                                                  });
                                                },
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                    Container(
                                      height: 150.0,
                                      child: SfCartesianChart(
                                        primaryXAxis: CategoryAxis(),

                                        // Chart title
                                        title: ChartTitle(
                                            textStyle:
                                                TextStyle(fontSize: 12.5),
                                            text:
                                                'Air Temperature (${dataText[0]}°C)'),
                                        // Enable legend
                                        legend: Legend(isVisible: false),
                                        // Enable tooltip
                                        tooltipBehavior:
                                            TooltipBehavior(enable: false),
                                        series: <ChartSeries<DataSet, String>>[
                                          LineSeries<DataSet, String>(
                                            dataSource: temperature,
                                            xValueMapper: (DataSet latest, _) =>
                                                latest.time,
                                            yValueMapper: (DataSet latest, _) =>
                                                latest.data,
                                            // Enable data label
                                            dataLabelSettings:
                                                DataLabelSettings(
                                                    isVisible: false),
                                          )
                                        ],
                                      ),
                                    ),
                                    Container(
                                      height: 150.0,
                                      child: SfCartesianChart(
                                        primaryXAxis: CategoryAxis(),
                                        // Chart title
                                        title: ChartTitle(
                                            textStyle:
                                                TextStyle(fontSize: 12.5),
                                            text:
                                                'Relative Humidity (${dataText[1]}%)'),
                                        // Enable legend
                                        legend: Legend(isVisible: false),
                                        // Enable tooltip
                                        tooltipBehavior:
                                            TooltipBehavior(enable: true),
                                        series: <ChartSeries<DataSet, String>>[
                                          LineSeries<DataSet, String>(
                                              yValueMapper:
                                                  (DataSet latest, _) =>
                                                      latest.data,
                                              xValueMapper:
                                                  (DataSet latest, _) =>
                                                      latest.time,
                                              dataSource: humidity,

                                              // Enable data label
                                              dataLabelSettings:
                                                  DataLabelSettings(
                                                      isVisible: false))
                                        ],
                                      ),
                                    ),
                                    Container(
                                      height: 150.0,
                                      child: SfCartesianChart(
                                        primaryXAxis: CategoryAxis(),
                                        // Chart title
                                        title: ChartTitle(
                                            textStyle:
                                                TextStyle(fontSize: 12.5),
                                            text:
                                                'Chamber Pressure (${dataText[2]}mBAR)'),
                                        // Enable legend
                                        legend: Legend(isVisible: false),
                                        // Enable tooltip
                                        tooltipBehavior:
                                            TooltipBehavior(enable: true),
                                        series: <ChartSeries<DataSet, String>>[
                                          LineSeries<DataSet, String>(
                                              dataSource: pressure,
                                              xValueMapper:
                                                  (DataSet sales, _) =>
                                                      sales.time,
                                              yValueMapper:
                                                  (DataSet sales, _) =>
                                                      sales.data,
                                              // Enable data label
                                              dataLabelSettings:
                                                  DataLabelSettings(
                                                      isVisible: false))
                                        ],
                                      ),
                                    ),
                                    Container(
                                      height: 150.0,
                                      child: SfCartesianChart(
                                        primaryXAxis: CategoryAxis(),
                                        // Chart title
                                        title: ChartTitle(
                                            textStyle:
                                                TextStyle(fontSize: 12.5),
                                            text:
                                                'Soil Moisture (${dataText[3]}%)'),
                                        // Enable legend
                                        legend: Legend(isVisible: false),
                                        // Enable tooltip
                                        tooltipBehavior:
                                            TooltipBehavior(enable: true),
                                        series: <ChartSeries<DataSet, String>>[
                                          LineSeries<DataSet, String>(
                                              dataSource: soilMoisture,
                                              xValueMapper:
                                                  (DataSet sales, _) =>
                                                      sales.time,
                                              yValueMapper:
                                                  (DataSet sales, _) =>
                                                      sales.data,
                                              // Enable data label
                                              dataLabelSettings:
                                                  DataLabelSettings(
                                                      isVisible: false))
                                        ],
                                      ),
                                    ),
                                    Container(
                                      height: 150.0,
                                      child: SfCartesianChart(
                                        primaryXAxis: CategoryAxis(),
                                        // Chart title
                                        title: ChartTitle(
                                            textStyle: TextStyle(
                                              fontSize: 12.5,
                                            ),
                                            text:
                                                'Soil Temperature (${dataText[4]}°C)'),
                                        // Enable legend
                                        legend: Legend(isVisible: false),
                                        // Enable tooltip
                                        tooltipBehavior:
                                            TooltipBehavior(enable: true),
                                        series: <ChartSeries<DataSet, String>>[
                                          LineSeries<DataSet, String>(
                                              dataSource: soilTemperature,
                                              xValueMapper:
                                                  (DataSet sales, _) =>
                                                      sales.time,
                                              yValueMapper:
                                                  (DataSet sales, _) =>
                                                      sales.data,
                                              // Enable data label
                                              dataLabelSettings:
                                                  DataLabelSettings(
                                                      isVisible: false))
                                        ],
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.fromLTRB(
                                          0.0, 8.0, 0.0, 8.0),
                                      child: Text(
                                        ' Data collection rate (${delay}sec)',
                                        style: TextStyle(fontSize: 15.0),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Expanded(
                                            child: Text(
                                          '1',
                                          textAlign: TextAlign.center,
                                        )),
                                        SizedBox(
                                          width: 55.0,
                                        ),
                                        Expanded(
                                            child: Text(
                                          '10',
                                          textAlign: TextAlign.center,
                                        )),
                                      ],
                                    ),
                                    Container(
                                      width: 250.0,
                                      child: SliderTheme(
                                        data: SliderThemeData(
                                          thumbShape: RoundSliderThumbShape(
                                              enabledThumbRadius: 12.0,
                                              disabledThumbRadius: 12.0),
                                          overlayShape: RoundSliderOverlayShape(
                                              overlayRadius: 20.0),
                                          thumbColor: Color(0xFF2F4F4F),
                                          overlayColor: Colors.blueGrey,
                                          disabledThumbColor: Colors.blue,
                                          disabledActiveTickMarkColor:
                                              Colors.blue,
                                          disabledActiveTrackColor: Colors.blue,
                                          activeTrackColor: Colors.blue,
                                          inactiveTrackColor: Colors.blue,
                                          trackHeight: 13.0,
                                        ),
                                        child: Slider(
                                          label: delay.toString(),
                                          value: delay.toDouble(),
                                          onChanged: (value) {
                                            setState(() {
                                              delay = value.toInt();
                                              sendData(delay.toString());
                                              print(delay);
                                            });
                                          },
                                          min: 1.0,
                                          max: 10.0,
                                        ),
                                      ),
                                    ),
                                    RaisedButton(
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(30.0))),
                                      color: Colors.blueGrey,
                                      onPressed: () {
                                        OpenFile.open(ourFile.path);
                                      },
                                      child: Text(
                                        'Click here to see saved data',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    )
                                  ],
                                ),
                        );
                      },
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    widget.device.disconnect();
  }
}
