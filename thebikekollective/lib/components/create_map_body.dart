import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'styles.dart';
import 'formatted_text.dart';
import 'dart:developer';

const Color MarkerColor = Color(s_jungleGreen);


Future<List<BikeMarker>> GetBikes( BuildContext context ) async{
  List<BikeMarker> bikeMarkers = <BikeMarker>[];
  var bikes = [];

  QuerySnapshot querySnapshot = await FirebaseFirestore
                                      .instance
                                      .collection('bikes')
                                      .get();

  // Convert to Bike object
  querySnapshot.docs.forEach((doc) {
    Bike bike = new Bike(
        name: doc['Name'],
        imagePath: doc['imageURL'],
        lat: doc['Latitude'],
        long: doc['Longitude'],
        description: doc['Description'],
        condition: doc['Condition']
    );
    bikes.add(bike);
    bikeMarkers.add(new BikeMarker(bike: bike));
  });

  return bikeMarkers;
}

List<BikeMarker> ConvertMarkers(BuildContext context, List<BikeMarker> bmFuture){
  var list = <BikeMarker>[];
  bmFuture.forEach((item){
      list.add(item);
  });
  return list;
}


class CreateMapBody extends StatefulWidget{
  CreateMapBody({Key? key}) : super(key: key);


  @override
  _CreateMapBody createState() => _CreateMapBody();
}


class _CreateMapBody extends State<CreateMapBody>{
    List<BikeMarker> bikes = <BikeMarker>[];
    final PopupController _popupLayerController = PopupController();

    // Zoom functions from chunhunghan's answer here:
    // https://stackoverflow.com/questions/64034365/flutter-map-zoom-not-updating

    double currentZoom = 13.0;
    MapController? mapController = new MapController();
    LatLng currentCenter = LatLng(39.276, -74.576);

    void _zoom() {
      currentZoom = currentZoom - 1;
      mapController!.move(currentCenter, currentZoom);
    }

    @override
    Widget build(BuildContext context){
      List<BikeMarker> markerList = <BikeMarker>[];
      return FutureBuilder<List<BikeMarker>>(
        future: GetBikes(context),
        builder: (context, snapshot){
          List<BikeMarker>? returnData;
          if(snapshot.connectionState == ConnectionState.done){
            if(snapshot.hasData){
              returnData = snapshot.data;
              returnData!.forEach((el){
                markerList.add(el);
              });
            }

            return Scaffold(
              body: FlutterMap(
                  mapController: new MapController(),
                  options: MapOptions(
                      onMapCreated: (c){
                        mapController = c;
                      },
                      center: currentCenter,
                      zoom: currentZoom,
                      interactiveFlags: InteractiveFlag.all,
                      onTap: (a, b)
                      {
                        _popupLayerController.hideAllPopups();
                      }
                    // debug: true,
                  ),
                  children: <Widget>[
                    TileLayerWidget(
                        options:
                        TileLayerOptions(
                          overrideTilesWhenUrlChanges: false,
                          urlTemplate:
                          "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png?source=${DateTime.now().millisecondsSinceEpoch}",
                          subdomains: ['a', 'b', 'c'],
                          attributionBuilder: (_) {
                            return Text("© OpenStreetMap contributors");
                          },
                          additionalOptions: {},
                        )),
                    PopupMarkerLayerWidget(options: PopupMarkerLayerOptions(

                      // Based off example_popup_with_data.dart from
                      // flutter_map_marker_popup repository (the
                      // plugin used here)
                      // https://github.com/rorystephenson/flutter_map_marker_popup/blob/master/example/lib/example_popup_with_data.dart
                      markers: markerList,
                      popupSnap: PopupSnap.mapTop,
                      popupAnimation: PopupAnimation.fade(duration: Duration(milliseconds: 300)),
                      popupController: _popupLayerController,
                      popupBuilder: (_, Marker marker) {
                        if (marker is BikeMarker) {
                          return BikeMarkerPopup(bike: marker.bike);
                        }
                        return Card(child: const Text('Not a bike'));
                      },
                      markerTapBehavior: MarkerTapBehavior.custom((marker, popupController) => {
                        popupController.hideAllPopups(),
                        popupController.togglePopup(marker),
                      }
                      )
                    ),
                    )
                  ]),
              floatingActionButton: FloatingActionButton(
                onPressed: _zoom,
                tooltip: 'Zoom',
                backgroundColor: Color(s_jungleGreen),
                child: Icon(Icons.zoom_out_map_outlined),
              ),
            );

          }
          return Center(child: Text('Loading...'));
        }
      );

    }
  }

class Bike {
  static const double size = 25;

  Bike({
    required this.name,
    required this.imagePath,
    required this.lat,
    required this.long,
    required this.description,
    required this.condition
  });

  final String name;
  final String imagePath;
  final double lat;
  final double long;
  final String description;
  final String condition;
}



class BikeMarker extends Marker {
  BikeMarker({required this.bike})
      : super(
    anchorPos: AnchorPos.align(AnchorAlign.top),
    height: Bike.size,
    width: Bike.size,
    point: LatLng(bike.lat, bike.long),
    builder: (BuildContext ctx) => Icon(Icons.location_pin,
        color: MarkerColor,
        size:30),

  );

  final Bike bike;
}

class BikeMarkerPopup extends StatelessWidget {
  const BikeMarkerPopup({Key? key, required this.bike})
      : super(key: key);
  final Bike bike;

  @override
  Widget build(BuildContext context) {
    if(!isLandscape(context)){
      return portraitLayout(context, bike);
    } else {
      return landscapeLayout(context, bike);
    }

  }
}

Container portraitLayout(BuildContext context, bike){
  return Container(
    width: double.infinity,
    child: Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child:
      Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(8),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Column(
                      children: <Widget>[
                        Image(image: NetworkImage(bike.imagePath),
                            width:150 * imageSizeFactor(context),
                            height:150 * imageSizeFactor(context)),

                      ]
                  ),

                  Column(
                      children: <Widget>[
                        Text(
                            bike.name,
                            style:
                            TextStyle(fontWeight:FontWeight.bold),
                            textAlign: TextAlign.end
                        ),
                        SizedBox(height: 8),
                        Text('${bike.description}'),
                        SizedBox(height: 8),
                        Text('Condition: ${bike.condition}'),
                        SizedBox(height: 8),
                        rideButton(context, "Ride me!", 100, 25)
                      ])
                ]
            )
          )


        ],
      ),
    ),
  );
}

Container landscapeLayout(BuildContext context, bike){
  return Container(
    alignment: Alignment.topLeft,
    height: double.infinity,
    child: Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child:
      Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[

            Padding(
              padding: EdgeInsets.only(left: 8, top: 4, right: 8, bottom: 4),
              child: Column(              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                    Image(image: NetworkImage(bike.imagePath),
                      width:150 * imageSizeFactor(context),
                      height:150 * imageSizeFactor(context)),
                    Column(
                        children: <Widget>[
                          Text(bike.name, style:
                          TextStyle(fontWeight:FontWeight.bold),
                              textAlign: TextAlign.end),
                          SizedBox(height: 8),
                          Text('${bike.description}'),
                          SizedBox(height: 8),
                          Text('Condition: ${bike.condition}'),
                          SizedBox(height: 8),
                          rideButton(context, "Ride me!", 100, 25)
                        ])
              ]
            )
          )
        ],
      ),
    ),
  );
}

Widget rideButton(BuildContext context, String text,
    double buttonWidth, double buttonHeight) {
  return ElevatedButton(
      onPressed: () {
        return;
      },
      child: rideButtonText(text),
      style: ElevatedButton.styleFrom(
          primary: Color(s_jungleGreen),
          fixedSize: Size(buttonWidth, buttonHeight)));
}

Widget rideButtonText(String text) {
  return FormattedText(
    text: text,
    size: s_fontSizeSmall,
    color: Colors.white,

    weight: FontWeight.bold,
  );
}

double imageSizeFactor(BuildContext context) {
  if (MediaQuery.of(context).orientation == Orientation.portrait) {
    return 1;
  } else {
    return 1;
  }
}

bool isLandscape(BuildContext context) {
  if (MediaQuery.of(context).orientation == Orientation.landscape) {
    return true;
  } else {
    return false;
  }
}

double headspaceFactor(BuildContext context) {
  if (MediaQuery.of(context).orientation == Orientation.portrait) {
    return 60;
  } else {
    return 20;
  }
}


