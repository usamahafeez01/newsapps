import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class PurpleProgressIndicator extends StatelessWidget {
  const PurpleProgressIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return SpinKitCircle(
      color: Colors.purple,  // Set the bubble color to purple
      size: 45.0,  // Adjust the size as necessary
    );


  }


}
