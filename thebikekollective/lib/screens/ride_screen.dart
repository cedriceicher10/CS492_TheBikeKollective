import 'package:flutter/material.dart';
import 'package:practice1/components/formatted_text.dart';
import '../components/styles.dart';
import '../components/ride_screen_body.dart';

class RideScreen extends StatelessWidget {
  const RideScreen({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: rideScreenTitle(),
        backgroundColor: Color(s_jungleGreen),
          centerTitle: true,
      ),
      body: RideScreenBody(),
    );
  }

  Widget rideScreenTitle() {
    return FormattedText(
      text: 'Enjoy the Ride!',
      size: s_fontSizeExtraLarge,
      color: Colors.white,
      font: s_font_AmaticSC,
      weight: FontWeight.bold,
    );
  }
}