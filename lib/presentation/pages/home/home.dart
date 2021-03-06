import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ubermove/presentation/blocs/user/bloc.dart';
import 'package:ubermove/presentation/blocs/user/state.dart';
import 'package:ubermove/presentation/pages/home/specifyDestination.dart';
import 'package:ubermove/presentation/widgets/button.dart';
import 'package:ubermove/presentation/widgets/date_picker.dart';
import 'package:ubermove/presentation/widgets/input.dart';
import 'package:geolocator/geolocator.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Completer<GoogleMapController> _controller = Completer();
  Position _currentPosition;
  String _permissionStatus;

  Future<CameraPosition> _cameraPositionFuture;
  String _currentWeight = "";
  DateTime date = DateTime(2020);
  TimeOfDay time = TimeOfDay(hour: 0, minute: 0);

  // final LatLng _center = const LatLng(-12.0749822, -77.0449321);

  @override
  void initState() {
    super.initState();
    _cameraPositionFuture = setCameraPosition();
    // streamController = StreamController.broadcast();
  }

  Future navigateToSpecifyDestination(context) async {
    DateTime dateTime =
        DateTime(date.year, date.month, date.day, time.hour, time.minute);
    Navigator.pushNamed(context, SpecifyDestination.PATH, arguments: {
      "originCameraPosition": _kGooglePlex,
      "weight": int.parse(_currentWeight),
      "date": dateTime
    });

    //Navigator.push(context, MaterialPageRoute(builder: (context) => TransportDetail()));
  }

  Future<Position> _getCurrentLocation() async {
    // if (await Permission.location.isUndetermined) {
    final Geolocator geolocator = Geolocator()
      ..forceAndroidLocationManager = true;

    print("aaaaa1");
    final position = await geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    print("2222");
    // setState(() {
    //   _currentPosition = position;
    // });
    print(position);
    return position;
  }

  Future<GeolocationStatus> getPermission(Geolocator geolocator) async {
    // final Geolocator geolocator = Geolocator()
    //   ..forceAndroidLocationManager = true;

    final status = await geolocator.checkGeolocationPermissionStatus();
    // _permissionStatus = status.toString();
    return status;
  }

  Future<CameraPosition> setCameraPosition() async {
    final myPosition = await _getCurrentLocation();
    if (myPosition == null) return _kGooglePlex;

    _kGooglePlex = CameraPosition(
      // target: LatLng(_currentPosition.latitude, _currentPosition.longitude),
      target: LatLng(myPosition.latitude, myPosition.longitude),
      zoom: 17.4746,
    );

    return _kGooglePlex;
  }

  Future<GeolocationStatus> checkInternetStatus() async {
    GeolocationStatus geolocationStatus =
        await Geolocator().checkGeolocationPermissionStatus();
    return geolocationStatus;
  }

  static CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );
  static final CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  void showSnackbar(String message, int type) {
    final snackbar = SnackBar(
      content: Text(message ?? 'Error'),
      backgroundColor: type == 0 ? Colors.redAccent : Colors.green,
    );
    Scaffold.of(context).showSnackBar(snackbar);
  }

  @override
  Widget build(BuildContext context) {
    final userBloc = context.bloc<UserBloc>();
    // Future<CameraPosition> _cameraPositionFurure = setCameraPosition();

    return BlocConsumer<UserBloc, UserState>(
      listener: (context, state) {
        if (state.createJobEvent.loading) return;
        if (state.createJobEvent.success == true) {
          showSnackbar("Se registro exitosamente la solicitud", 1);
          userBloc.resetCreateJob();
        }
      },
      builder: (context, state) => Flex(
        direction: Axis.vertical,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: Text(
              'Transporte',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: RangeDatePicker(
              time: time,
              date: date,
              onSaveTime: (selectedTime) {
                setState(() {
                  time = selectedTime;
                });
              },
              onSaveDate: (selectedDate) {
                setState(() {
                  date = selectedDate;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: Input(
              keyboardType: TextInputType.number,
              hintText: "Peso de la carga",
              onChanged: (value) {
                setState(() {
                  _currentWeight = value;
                  print(_currentWeight);
                });
              },
            ),
          ),
          Expanded(
              child: Stack(
            children: <Widget>[
              FutureBuilder<CameraPosition>(
                future: _cameraPositionFuture,
                builder: (constext, snapshot) {
                  if (snapshot.hasData) {
                    return GoogleMap(
                      mapType: MapType.normal,
                      initialCameraPosition: snapshot.data,
                      // myLocationButtonEnabled: false,
                      // zoomControlsEnabled: false,
                      onMapCreated: (GoogleMapController controller) {
                        _controller.complete(controller);
                      },
                      markers: Set<Marker>.of([
                        Marker(
                            markerId: MarkerId("dasss"),
                            position: snapshot.data.target)
                      ]),
                      // onMapCreated: _onMapCreated,
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                          "No se puede mostrar el mapa porque faltan permisos"),
                    );
                  }
                  return Center(child: CircularProgressIndicator());
                },
              ),
              Positioned(
                bottom: 0,
                width: MediaQuery.of(context).size.width - 40,
                child: Center(
                  child: Container(
                    width: 200,
                    padding: EdgeInsets.only(bottom: 20),
                    child: Button(
                      "CONTINUAR",
                      onPressed: () {
                        final weightI = int.tryParse(_currentWeight);
                        if (weightI == null || weightI * 1 == 0) {
                          showSnackbar("El campo peso es obligatorio", 0);
                        } else
                          navigateToSpecifyDestination(context);
                      },
                    ),
                  ),
                ),
              )
            ],
          )),
          SizedBox(height: 20)
        ],
      ),
    );
  }
}
