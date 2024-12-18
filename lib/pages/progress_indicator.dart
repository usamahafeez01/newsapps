import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class BlueProgressIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SpinKitFadingCube(
        color: Colors.blue,  // Set the bubble color to purple
        size: 45.0, // Adjust the size as necessary
      ),
    );
  }
}
