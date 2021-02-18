import 'package:flutter/material.dart';

class ExpandedCard extends StatelessWidget {
  ExpandedCard(
      {this.topColor,
      this.fieldName,
      this.fieldValue,
      this.image,
      this.bottomColor});
  final Color topColor;
  final String fieldName;
  final String fieldValue;
  final String image;
  final Color bottomColor;
  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Card(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 10.0),
            margin: EdgeInsets.only(bottom: 3.0),
            color: topColor,
            width: double.infinity,
            child: Text(
              '$fieldName',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Image.asset(
            image,
            height: 80.0,
          ),
          SizedBox(
            height: 10.0,
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 10.0),
            color: bottomColor,
            width: double.infinity,
            child: Text(
              '$fieldValue',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
    ));
  }
}
