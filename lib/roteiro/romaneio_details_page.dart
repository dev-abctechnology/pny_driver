import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:location_geocoder/location_geocoder.dart';
import 'package:pny_driver/config/custom_theme.dart';
import 'package:pny_driver/config/google_maps_theme.dart';
import 'package:pny_driver/domain/models/direction_suggestion.dart';
import 'package:pny_driver/domain/models/romaneio_custom_api_model.dart';
import 'package:pny_driver/domain/models/romaneio_general_store.dart';
import 'package:pny_driver/pages/widgets/expandable_card_romaneio.dart';
import 'package:pny_driver/pages/widgets/search_bar.dart';
import 'package:pny_driver/pages/widgets/search_bar_widget.dart';
import 'package:pny_driver/roteiro/store/roteiro_store.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'dart:developer' as developer;
import '../domain/models/romaneio_model.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:url_launcher/url_launcher.dart';

import '../shared/enviroment.dart';

class RomaneioDetails extends StatefulWidget {
  final Romaneio romaneio;

  const RomaneioDetails({super.key, required this.romaneio});

  @override
  State<RomaneioDetails> createState() => _RomaneioDetailsState();
}

class _RomaneioDetailsState extends State<RomaneioDetails> {
  final _formKey = GlobalKey<FormState>();
  final _destinationAddress = TextEditingController();
  List<GeoData> geoData = [];
  List<LatLng> polylineCoordinates = [];
  List<PolylineWayPoint> _polyLinePoints = [];
  late Romaneio romaneio;
  final Set<Marker> _marcadores = {};
  final Set<Polyline> _polylines = {};
  bool _sorted = false;
  bool _showDeliveryOrder = false;
  late Address myLocation;
  String myAddress = '';
  double _scaleFactor = 0.65;
  late GoogleMapController _mapController;

  @override
  void initState() {
    super.initState();

    romaneio = widget.romaneio;
    // romaneio = romaneioDelivery;
    timeAndDistance = {};
    _setLocationToAddres();
    store = RomaneioGeneralController();
  }

  _saveTravel(
      {suggestion,
      date,
      romaneio,
      required List<RomaneioEntregue> entregas,
      destination}) async {
    var data = RomaneioGeneral(
        directionSuggestion: suggestion,
        date: date,
        romaneio: romaneio,
        romaneiosEntregues: entregas,
        destination: destination);
    var response = await store.saveTravel(data);

    if (response) {
      print('Salvo com sucesso');
    } else {
      print('Erro ao salvar');
    }
  }

  Future<Position> _getGeoLocationPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
  }

  _getPositionHandler() {
    _getGeoLocationPosition().then((value) {}).onError((error, stackTrace) {
      return Future.error('Location services are disabled.');
    });
  }

  _setLocationToAddres() async {
    final position =
        await _getGeoLocationPosition().onError((error, stackTrace) {
      return Future.error('Location services are disabled.');
    });
    final address = await LocatitonGeocoder(apiKey)
        .findAddressesFromCoordinates(
            Coordinates(position.latitude, position.longitude));
    myAddress = address.first.addressLine!;
    myLocation = address.first;
    _marcadores.add(Marker(
        markerId: const MarkerId('Minha Localização'),
        position: LatLng(position.latitude, position.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: const InfoWindow(title: 'Minha Localização')));
    setState(() {});
  }

  Future<GeoData> _convertAddressToLatLng({required String address}) async {
    try {
      GeoData data = await Geocoder2.getDataFromAddress(
          address: address, googleMapApiKey: apiKey);
      return data;
    } catch (e) {
      _destinationAddress.text = '';
      setState(() {
        _sorted = false;
      });
      return _erroSnackBar('Endereço não encontrado - $address');
    }
  }

  _erroSnackBar(String error) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(error),
      backgroundColor: Colors.red,
    ));
  }

  _createPolylines() async {
    try {
      var destination =
          await _convertAddressToLatLng(address: _destinationAddress.text);

      List<ClienteRomaneio> clientes = widget.romaneio.data.clientesRomaneio;
      clientes.removeWhere((element) => element.imagem != '');

      List<EnderecoTemplate> enderecos = clientes
          .map((e) => e.enderecos
              .where((element) => element.tipo.label == 'Endereço Entrega')
              .first)
          .toList();

      _polyLinePoints = [];
      for (var e in enderecos) {
        _polyLinePoints.add(
          PolylineWayPoint(
            location:
                '${e.logradouro} ${e.numero}- ${e.complemento}, ${e.bairro}, ${e.cidade}, ${e.cep}, ${e.cidade}',
            stopOver: false,
          ),
        );
      }

      PolylinePoints polylinePoints = PolylinePoints();

      var pointDestination =
          PointLatLng(destination.latitude, destination.longitude);
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        apiKey,
        PointLatLng(myLocation.coordinates.latitude!,
            myLocation.coordinates.longitude!),
        PointLatLng(destination.latitude, destination.longitude),
        travelMode: TravelMode.driving,
        wayPoints: _polyLinePoints,
        optimizeWaypoints: true,
      );
      if (result.points.isNotEmpty) {
        polylineCoordinates = [];
        for (PointLatLng point in result.points) {
          _polylines.add(Polyline(
              polylineId: PolylineId(pointDestination.toString()),
              width: 5,
              geodesic: true,
              points: result.points
                  .map((e) => LatLng(e.latitude, e.longitude))
                  .toList(),
              color: const Color.fromARGB(200, 33, 149, 243)));
        }
      }
      setState(() {});
    } catch (e) {
      _erroSnackBar('Não foi possível traçar a rota');
    }
  }

  void launchWaze(String address) async {
    var infoAddress = await _convertAddressToLatLng(address: address);

    var url =
        'waze://?ll=${infoAddress.latitude.toString()},${infoAddress.longitude.toString()}';
    var fallbackUrl =
        'https://waze.com/ul?ll=${infoAddress.latitude.toString()},${infoAddress.longitude.toString()}&navigate=yes';
    try {
      bool launched =
          await launch(url, forceSafariVC: false, forceWebView: false);
      if (!launched) {
        await launch(fallbackUrl, forceSafariVC: false, forceWebView: false);
      }
    } catch (e) {
      await launch(fallbackUrl, forceSafariVC: false, forceWebView: false);
    }
  }

  void launchGoogleMaps(String address) async {
    var infoAddress = await _convertAddressToLatLng(address: address);

    var url =
        'google.navigation:q=${infoAddress.latitude.toString()},${infoAddress.longitude.toString()}';
    var fallbackUrl =
        'https://www.google.com/maps/search/?api=1&query=${infoAddress.latitude.toString()},${infoAddress.longitude.toString()}';
    try {
      bool launched =
          await launch(url, forceSafariVC: false, forceWebView: false);
      if (!launched) {
        await launch(fallbackUrl, forceSafariVC: false, forceWebView: false);
      }
    } catch (e) {
      await launch(fallbackUrl, forceSafariVC: false, forceWebView: false);
    }
  }

  _createMarkersFromAddress() async {
    List<ClienteRomaneio> clientes = romaneio.data.clientesRomaneio;

    clientes.removeWhere((element) => element.imagem != '');

    List<EnderecoTemplate> enderecos = clientes
        .map((e) => e.enderecos
            .where((element) => element.tipo.label == 'Endereço Entrega')
            .first)
        .toList();

    String waypoints = enderecos
        .map((e) =>
            '${e.logradouro} ${e.numero}- ${e.complemento}, ${e.bairro}, ${e.cidade}, ${e.cep}, ${e.cidade}')
        .join('|');

    for (EnderecoTemplate e in enderecos) {
      GeoData data = await _convertAddressToLatLng(
          address:
              '${e.logradouro} ${e.numero}- ${e.complemento}, ${e.bairro}, ${e.cidade}, ${e.cep}, ${e.cidade}');
      geoData.add(data);
      _marcadores.add(Marker(
          markerId: MarkerId(
            '${e.logradouro} ${e.numero}- ${e.complemento ?? ''}, ${e.bairro}, ${e.cidade}, ${e.cep}, ${e.cidade}',
          ),
          onTap: () {
            _navigationApplication(e);
          },
          position: LatLng(data.latitude, data.longitude),
          infoWindow: InfoWindow(
            title:
                '${e.logradouro} ${e.numero}- ${e.complemento}, ${e.bairro}, ${e.cidade}, ${e.cep}, ${e.cidade}',
          )));
    }

    setState(() {});
  }

  Future<dynamic> _navigationApplication(EnderecoTemplate e) {
    return showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.3,
        minChildSize: 0.3,
        maxChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Palette.customGreyDark.withAlpha(245),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          height: 400,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Escolha o aplicativo de navegação',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Palette.persianasColor),
                ),
              ),
              //button with icon from network
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    iconSize: 75,
                    icon: Image.network(
                      'https://www.agenciavirtualreality360.com.br/wp-content/uploads/2022/02/waze-1024x1024.png',
                      fit: BoxFit.cover,
                    ),
                    onPressed: () {
                      launchWaze(
                          '${e.logradouro} ${e.numero}- ${e.complemento}, ${e.bairro}, ${e.cidade}, ${e.cep}, ${e.cidade}');
                    },
                  ),
                  IconButton(
                    iconSize: 75,
                    onPressed: () {
                      launchGoogleMaps(
                          '${e.logradouro} ${e.numero}- ${e.complemento}, ${e.bairro}, ${e.cidade}, ${e.cep}, ${e.cidade}');
                    },
                    icon: Image.network(
                      'https://cdn-icons-png.flaticon.com/512/2642/2642502.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  late Map timeAndDistance;
  late DirectionSuggestion directionSuggestion;
  Future<List<ClienteRomaneio>> _sortWaypoints() async {
    try {
      setState(() {
        _sorted = true;
        _showDeliveryOrder = true;
      });
      var dio = Dio();

      final romaneio = widget.romaneio;

      List<ClienteRomaneio> clientes = romaneio.data.clientesRomaneio;

      List<EnderecoTemplate> enderecos =
          _identifyDeliveryAddress(clientes).toList();

      String waypoints = _setWaypointsStringWithAllAddress(enderecos).join('|');

      developer.log(waypoints);
      var destination =
          await _convertAddressToLatLng(address: _destinationAddress.text);
      final response = await dio.get(
          'https://maps.googleapis.com/maps/api/directions/json?origin=$myAddress&destination=${destination.address}&waypoints=optimize:true|$waypoints&key=$apiKey');

      directionSuggestion = DirectionSuggestion.fromJson(response.data);

      // print the sum of the distance as kilometers and time as minutes of every leg
      var allDistanceKm = _convertDistanceValue();
      var allTimeMinutes = _convertDurationValue();

      if (allTimeMinutes > 60) {
        var hours = allTimeMinutes ~/ 60;
        var minutes = allTimeMinutes % 60;
        timeAndDistance['time'] = '${hours}h ${minutes.toStringAsFixed(0)}';
        timeAndDistance['distance'] = allDistanceKm.toStringAsFixed(0);
      } else {
        timeAndDistance = {
          'distance': allDistanceKm.toStringAsFixed(2),
          'time': allTimeMinutes.toStringAsFixed(2)
        };
      }

      setState(() {});
      List waypointOrder = directionSuggestion.routes.first.waypointOrder;

      // print(clientes.first.enderecos.first.logradouro);

      _setMarkers(destination);

      // sort clientes endereco by waypointOrder index value
      List<ClienteRomaneio> clientesSorted = [];
      for (var i = 0; i < waypointOrder.length; i++) {
        clientesSorted.add(clientes[waypointOrder[i]]);
      }
      // print(clientesSorted.first.enderecos.first.logradouro);
      return clientesSorted;
    } catch (e, s) {
      developer.log(e.toString(),
          name: 'RomaneioDetails', error: e, stackTrace: s);

      // print(arguments);
      final romaneio = widget.romaneio;

      List<ClienteRomaneio> clientes = romaneio.data.clientesRomaneio;
      setState(() {
        _sorted = false;
      });
      return clientes;
    }
  }

  double _convertDurationValue() {
    return (directionSuggestion.routes[0].legs
            .map((e) => e.duration.value)
            .reduce((value, element) => value + element) /
        60);
  }

  double _convertDistanceValue() {
    return (directionSuggestion.routes[0].legs
            .map((e) => e.distance.value)
            .reduce((value, element) => value + element) /
        1000);
  }

  Iterable<String> _setWaypointsStringWithAllAddress(
      List<EnderecoTemplate> enderecos) {
    return enderecos.map((e) =>
        '${e.logradouro} ${e.numero}- ${e.complemento}, ${e.bairro}, ${e.cidade}, ${e.cep}, ${e.cidade}');
  }

  Iterable<EnderecoTemplate> _identifyDeliveryAddress(
          List<ClienteRomaneio> clientes) =>
      clientes.map((e) => e.enderecos
          .where((element) => element.tipo.label == 'Endereço Entrega')
          .first);

  bool _setMarkers(GeoData destination) {
    return _marcadores.add(Marker(
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        markerId: MarkerId(destination.address),
        position: LatLng(destination.latitude, destination.longitude),
        infoWindow: InfoWindow(title: destination.address)));
  }

  late RomaneioGeneralController store;
  final GlobalKey<SlideActionState> _slideActionKey = GlobalKey();

  Widget _romaneiosListWidget() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Stack(children: [
        Column(
          children: [
            timeAndDistance.isNotEmpty
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Distância: ${timeAndDistance['distance']} km',
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Palette.persianasColor),
                        ),
                        Text(
                          'Tempo: ${timeAndDistance['time']} min',
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Palette.persianasColor),
                        ),
                      ],
                    ),
                  )
                : Container(),
            InkWell(
                onTap: _changeScaleFactor,
                child: IconButton(
                    icon: _scaleFactor == 0.25
                        ? const Icon(Icons.expand_less,
                            color: Colors.white, size: 30)
                        : const Icon(Icons.expand_more,
                            color: Colors.white, size: 30),
                    onPressed: _changeScaleFactor)),
            _sorted
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SlideAction(
                      key: _slideActionKey,
                      innerColor: Palette.customGreyDark,
                      outerColor: Palette.persianasColor,
                      onSubmit: () async {
                        print('Slide Action');
                        try {
                          _saveTravel(
                              date: DateTime.now(),
                              destination: _destinationAddress.text,
                              entregas: [],
                              romaneio: romaneio,
                              suggestion: directionSuggestion);

                          var travel = await store.getTravel();

                          print(travel.date);
                          print(travel.destination);
                          print(travel.directionSuggestion.status);
                          print(travel.romaneio.data.clientesRomaneio.length);

                          store.deleteTravel();
                        } catch (e, s) {
                          developer.log(e.toString(),
                              name: 'RomaneioDetails', error: e, stackTrace: s);
                        }

                        _slideActionKey.currentState!.reset();
                      },
                      child: const Text('Deslize para iniciar a rota'),
                    ),
                  )
                : Container(),
            AnimationLimiter(
              child: ListView.builder(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: romaneio.data.clientesRomaneio.length,
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                ),
                itemBuilder: (BuildContext context, int index) {
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 2500),
                    delay: const Duration(milliseconds: 100),
                    child: SlideAnimation(
                      duration: const Duration(milliseconds: 2500),
                      curve: Curves.fastLinearToSlowEaseIn,
                      horizontalOffset: 30,
                      verticalOffset: 300,
                      child: FlipAnimation(
                        curve: Curves.fastLinearToSlowEaseIn,
                        duration: const Duration(milliseconds: 3000),
                        flipAxis: FlipAxis.y,
                        child: ExpandableRomaneioClienteWidget(
                          cliente: romaneio.data.clientesRomaneio[index],
                          deliveryOrder: _showDeliveryOrder,
                          index: index,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ]),
    );
  }

  void _clearAll() {
    _marcadores.clear();
    polylineCoordinates.clear();
    _polylines.clear();
    geoData.clear();
    setState(() {});
  }

  void _changeScaleFactor() {
    setState(() {
      _scaleFactor = _scaleFactor == 0.25 ? 0.65 : 0.25;
    });
  }

  var searchSuggestion = PlaceService(Dio());

  Future _searchSuggestion(String? value) async {
    var _searchResult;

    if (value != null && value.isNotEmpty) {
      var result = await searchSuggestion.getPlace(value);
      if (result != null) {
        setState(() {
          _searchResult = result;
        });
        return _searchResult;
      }

      return null;
    }
  }

  var _delegate = AddressSearch();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Romaneio'),
        actions: [
          IconButton(
              onPressed: () async {
                _getPositionHandler();
                developer.log(_marcadores.toString());
              },
              icon: const Icon(Icons.directions))
        ],
      ),
      extendBody: true,
      body: myAddress == ''
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Form(
              key: _formKey,
              child: SafeArea(
                child: Stack(
                  alignment: AlignmentDirectional.bottomCenter,
                  children: [
                    myAddress == ''
                        ? Text(myAddress)
                        : Container(
                            child: GoogleMap(
                              zoomControlsEnabled: false,
                              myLocationEnabled: true,
                              tiltGesturesEnabled: false,
                              rotateGesturesEnabled: false,
                              scrollGesturesEnabled: true,
                              onMapCreated: (controller) {
                                _mapController = controller;
                                _mapController
                                    .setMapStyle(jsonEncode(customTheme));
                              },
                              polylines: _polylines,
                              markers: _marcadores,
                              initialCameraPosition: CameraPosition(
                                target: LatLng(myLocation.coordinates.latitude!,
                                    myLocation.coordinates.longitude!),
                                zoom: 15,
                              ),
                            ),
                          ),
                    Positioned(
                      bottom: 0,
                      child: AnimatedContainer(
                        height:
                            MediaQuery.of(context).size.height * _scaleFactor,
                        width: MediaQuery.of(context).size.width,
                        duration: const Duration(milliseconds: 1800),
                        curve: Curves.fastLinearToSlowEaseIn,
                        child: Container(
                            padding: const EdgeInsets.only(top: 16),
                            decoration: BoxDecoration(
                              color: Palette.customGreyDark.withAlpha(230),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                            ),
                            child: _romaneiosListWidget()),
                      ),
                    ),
                    _headerForm(),
                  ],
                ),
              ),
            ),
      floatingActionButton: myAddress != ''
          ? _sorted
              ? null
              : FloatingActionButton.extended(
                  backgroundColor: Palette.persianasColor,
                  label: Row(
                    children: const [
                      Icon(
                        Icons.route_outlined,
                        color: Palette.customGreyDark,
                      ),
                      Text('Rota',
                          style: TextStyle(color: Palette.customGreyDark))
                    ],
                  ),
                  onPressed: () async {
                    _validateForms();
                  },
                )
          : null,
    );
  }

  Widget _headerForm() {
    return Positioned(
      top: 0,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Palette.customGreyDark.withAlpha(230),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        width: MediaQuery.of(context).size.width,
        height: 80,
        child: TextFormField(
          readOnly: true,
          validator: (value) =>
              value!.isEmpty ? 'Informe um destino final' : null,
          onTap: () async {
            if (_scaleFactor == 0.65) {
              _changeScaleFactor();

              // // This will change the text displayed in the
            }
            final PlacePrediction result = await showSearch(
              context: context,
              delegate: _delegate,
              query: _destinationAddress.text,
            );

            setState(() {
              timeAndDistance.clear();
            });
            if (result != null) {
              _clearAll();
              _destinationAddress.text = result.description;
            }
          },
          onEditingComplete: () {
            if (_scaleFactor == 0.65) {
              _changeScaleFactor();
            }
            FocusScope.of(context).requestFocus(FocusNode());
          },
          controller: _destinationAddress,
          decoration: InputDecoration(
            fillColor: Colors.white,
            filled: true,
            hintText: 'Endereço de Destino',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }

  _validateForms() {
    if (_formKey.currentState!.validate()) {
      //loading
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Row(
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(
                    width: 10,
                  ),
                  Text('Calculando rota...')
                ],
              ),
            );
          });

      try {
        _sort().then((value) {
          Navigator.of(context).pop();
          //animate the camera to fit the markers
          _mapController.animateCamera(
            CameraUpdate.newLatLngBounds(
              LatLngBounds(
                southwest: LatLng(
                    directionSuggestion.routes.last.bounds.southwest.lat,
                    directionSuggestion.routes.last.bounds.southwest.lng),
                northeast: LatLng(
                    directionSuggestion.routes.last.bounds.northeast.lat,
                    directionSuggestion.routes.last.bounds.northeast.lng),
              ),
              100,
            ),
          );
        });
      } catch (e, s) {
        _erroSnackBar(e.toString());
        developer.log(e.toString(), stackTrace: s);

        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _sort() async {
    _clearAll();
    var sorted = await _sortWaypoints();
    setState(() {
      _setLocationToAddres();
      romaneio.data.clientesRomaneio.clear();
      romaneio.data.clientesRomaneio.addAll(sorted);
    });
    _createMarkersFromAddress();
    _createPolylines();
    _changeScaleFactor();
  }
}
