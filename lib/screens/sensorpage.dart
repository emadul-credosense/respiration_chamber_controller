// import 'dart:async';
// import 'dart:convert' show utf8;
// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_blue/flutter_blue.dart';
// import 'package:respiration_chamber_controller/customwidget/ExpandedCard.dart';
// import 'package:syncfusion_flutter_charts/charts.dart';
//
// import 'chartsdata.dart';
//
// class SensorPage extends StatefulWidget {
//   const SensorPage({Key key, this.device}) : super(key: key);
//   final BluetoothDevice device;
//
//   @override
//   _SensorPageState createState() => _SensorPageState();
// }
//
// class _SensorPageState extends State<SensorPage> {
//   final String SERVICE_UUID = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
//   final String CHARACTERISTIC_UUID = "beb5483e-36e1-4688-b7f5-ea07361b26a8";
//   bool isReady = false;
//   Stream<List<int>> stream;
//   BluetoothCharacteristic targetCharacteristics;
//   @override
//   void initState() {
//     super.initState();
//     bool isReady = false;
//     ConnectToDevice();
//   }
//
//   ConnectToDevice() async {
//     if (widget.device == null) {
//       _pop();
//       return;
//     }
//
//     new Timer(const Duration(seconds: 15), () {
//       if (!isReady) {
//         disconnectFromDevice();
//         _pop();
//       }
//     });
//
//     await widget.device.connect();
//     discoverServices();
//   }
//
//   disconnectFromDevice() {
//     if (widget.device == null) {
//       _pop();
//       return;
//     }
//     widget.device.disconnect();
//   }
//
//   discoverServices() async {
//     if (widget.device == null) {
//       _pop();
//       return;
//     }
//
//     List<BluetoothService> services = await widget.device.discoverServices();
//     services.forEach((service) {
//       if (service.uuid.toString() == SERVICE_UUID) {
//         service.characteristics.forEach((characteristic) {
//           if (characteristic.uuid.toString() == CHARACTERISTIC_UUID) {
//             characteristic.setNotifyValue(!characteristic.isNotifying);
//             stream = characteristic.value;
//             targetCharacteristics = characteristic;
//
//             setState(() {
//               isReady = true;
//               // writeData('1');
//             });
//           }
//         });
//       }
//     });
//
//     if (!isReady) {
//       // _pop()
//     }
//   }
//
//   _pop() {
//     Navigator.of(context).pop(true);
//   }
//
//   String _dataParser(List<int> datafromdevice) {
//     return utf8.decode(datafromdevice);
//   }
//
//   writeData(String data) async {
//     if (targetCharacteristics == null) return;
//     List<int> bytes = utf8.encode(data);
//     await targetCharacteristics.write(bytes);
//   }
//
//   bool switchOn = false;
//   String currentvalue = '0';
//   var text = ['...', '...', '...', '...'];
//   var dataT = [0.0, 0.0];
//   var dataH = [0.0, 0.0];
//   var dataP = [0.0, 0.0];
//   var dataS = [0.0, 0.0];
//
//   List<dataSet> temperature = [];
//   List<dataSet> humidity = [];
//   List<dataSet> pressure = [];
//   List<dataSet> soilMoisture = [];
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       child: Scaffold(
//         appBar: AppBar(
//           title: Text('Respiration chamber'),
//         ),
//         body: SingleChildScrollView(
//           dragStartBehavior: DragStartBehavior.start,
//           scrollDirection: Axis.vertical,
//           child: Center(
//             child: !isReady
//                 ? Text('Waiting for data........')
//                 : Container(
//                     child: StreamBuilder<List<int>>(
//                       stream: stream,
//                       builder: (BuildContext context,
//                           AsyncSnapshot<List<int>> snapshot) {
//                         if (snapshot.hasError) {
//                           Timer(Duration(seconds: 2), () {
//                             print('done');
//                           });
//                           return Text('Error: ${snapshot.error}');
//                         }
//                         if (snapshot.connectionState ==
//                             ConnectionState.active) {
//                           currentvalue = _dataParser(snapshot.data);
//                           text = currentvalue.split('+');
//                           // dataT.add(double.parse(text[0]));
//                           // dataH.add(double.parse(text[1]));
//                           // dataP.add(double.parse(text[2]));
//                           // dataS.add(double.parse(text[3]));
//
//                           final dateTime = DateTime.now();
//                           String time =
//                               "${dateTime.hour}.${dateTime.minute}.${dateTime.second}";
//                           temperature.add(dataSet(time, double.parse(text[0])));
//                           humidity.add(dataSet(time, double.parse(text[1])));
//                           pressure.add(dataSet(time, double.parse(text[2])));
//                           soilMoisture
//                               .add(dataSet(time, double.parse(text[3])));
//                         }
//                         return Column(
//                           children: [
//                             Row(
//                               children: [
//                                 Expanded(
//                                   flex: 6,
//                                   child: Container(
//                                       padding: EdgeInsets.only(left: 20.0),
//                                       child: Text(
//                                         switchOn
//                                             ? 'Tap to close chamber'
//                                             : 'Tap to open chamber',
//                                         style: TextStyle(
//                                             fontWeight: FontWeight.bold,
//                                             fontSize: 18.0),
//                                       )),
//                                 ),
//                                 Expanded(
//                                   child: Switch(
//                                       inactiveTrackColor: Colors.redAccent,
//                                       inactiveThumbColor: Colors.red,
//                                       activeColor: Colors.green,
//                                       value: switchOn,
//                                       onChanged: (value) {
//                                         setState(() {
//                                           switchOn = value;
//                                           if (!value) {
//                                             writeData('closed');
//                                           } else {
//                                             writeData('open');
//                                           }
//
//                                           print(value);
//
//                                           // Todo 1: need to put on changed code here
//                                         });
//                                       }),
//                                 ),
//                               ],
//                             ),
//                             // Row(
//                             //   children: [
//                             //     ExpandedCard(
//                             //       topColor: Colors.grey,
//                             //       fieldName: 'Temperature',
//                             //       fieldValue: '${text[0]}°',
//                             //       image: 'img/temperature.png',
//                             //       bottomColor: Colors.black12,
//                             //     ),
//                             //     ExpandedCard(
//                             //       topColor: Colors.grey,
//                             //       fieldValue: '${text[1]}%',
//                             //       fieldName: 'Humidity',
//                             //       image: 'img/humidity.png',
//                             //       bottomColor: Colors.black12,
//                             //     )
//                             //   ],
//                             // ),
//                             // Row(
//                             //   children: [
//                             //     ExpandedCard(
//                             //       topColor: Colors.grey,
//                             //       fieldName: 'Pressure',
//                             //       fieldValue: '${text[2]}Pa',
//                             //       image: 'img/barometer.png',
//                             //       bottomColor: Colors.black12,
//                             //     ),
//                             //     ExpandedCard(
//                             //       topColor: Colors.grey,
//                             //       fieldValue: '${text[3]}%',
//                             //       fieldName: 'Soil Moisture',
//                             //       image: 'img/moisture-wicking-fabric.png',
//                             //       bottomColor: Colors.black12,
//                             //     ),
//                             //
//                             //
//                             //
//                             //   ],
//                             // ),
//                             Expanded(
//                               child: SfCartesianChart(
//                                 primaryXAxis: CategoryAxis(),
//                                 // Chart title
//                                 title:
//                                     ChartTitle(text: 'Temperature Sensor Data'),
//                                 // Enable legend
//                                 legend: Legend(isVisible: false),
//                                 // Enable tooltip
//                                 tooltipBehavior: TooltipBehavior(enable: true),
//                                 series: <ChartSeries<dataSet, String>>[
//                                   LineSeries<dataSet, String>(
//                                       dataSource: temperature,
//                                       xValueMapper: (dataSet sales, _) =>
//                                           sales.time,
//                                       yValueMapper: (dataSet sales, _) =>
//                                           sales.data,
//                                       // Enable data label
//                                       dataLabelSettings:
//                                           DataLabelSettings(isVisible: true))
//                                 ],
//                               ),
//                             ),
//                             // Expanded(
//                             //   child: SfCartesianChart(
//                             //     primaryXAxis: CategoryAxis(),
//                             //     // Chart title
//                             //     title: ChartTitle(
//                             //         text: 'Half yearly sales analysis'),
//                             //     // Enable legend
//                             //     legend: Legend(isVisible: true),
//                             //     // Enable tooltip
//                             //     tooltipBehavior: TooltipBehavior(enable: true),
//                             //     series: <ChartSeries<dataSet, String>>[
//                             //       LineSeries<dataSet, String>(
//                             //           dataSource: humidity,
//                             //           xValueMapper: (dataSet sales, _) =>
//                             //               sales.time,
//                             //           yValueMapper: (dataSet sales, _) =>
//                             //               sales.data,
//                             //           // Enable data label
//                             //           dataLabelSettings:
//                             //               DataLabelSettings(isVisible: true))
//                             //     ],
//                             //   ),
//                             // ),
//                             // Expanded(
//                             //   child: SfCartesianChart(
//                             //     primaryXAxis: CategoryAxis(),
//                             //     // Chart title
//                             //     title: ChartTitle(
//                             //         text: 'Half yearly sales analysis'),
//                             //     // Enable legend
//                             //     legend: Legend(isVisible: true),
//                             //     // Enable tooltip
//                             //     tooltipBehavior: TooltipBehavior(enable: true),
//                             //     series: <ChartSeries<dataSet, String>>[
//                             //       LineSeries<dataSet, String>(
//                             //           dataSource: pressure,
//                             //           xValueMapper: (dataSet sales, _) =>
//                             //               sales.time,
//                             //           yValueMapper: (dataSet sales, _) =>
//                             //               sales.data,
//                             //           // Enable data label
//                             //           dataLabelSettings:
//                             //               DataLabelSettings(isVisible: true))
//                             //     ],
//                             //   ),
//                             // ),
//                             // Expanded(
//                             //   child: SfCartesianChart(
//                             //     primaryXAxis: CategoryAxis(),
//                             //     // Chart title
//                             //     title: ChartTitle(
//                             //         text: 'Half yearly sales analysis'),
//                             //     // Enable legend
//                             //     legend: Legend(isVisible: true),
//                             //     // Enable tooltip
//                             //     tooltipBehavior: TooltipBehavior(enable: true),
//                             //     series: <ChartSeries<dataSet, String>>[
//                             //       LineSeries<dataSet, String>(
//                             //           dataSource: soilMoisture,
//                             //           xValueMapper: (dataSet sales, _) =>
//                             //               sales.time,
//                             //           yValueMapper: (dataSet sales, _) =>
//                             //               sales.data,
//                             //           // Enable data label
//                             //           dataLabelSettings:
//                             //               DataLabelSettings(isVisible: true))
//                             //     ],
//                             //   ),
//                             // ),
//                           ],
//                         );
//                       },
//                     ),
//                   ),
//           ),
//         ),
//       ),
//     );
//   }
// }
