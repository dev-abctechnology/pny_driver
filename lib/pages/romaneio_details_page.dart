import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:location_geocoder/location_geocoder.dart';
import 'package:pny_driver/config/custom_theme.dart';
import 'package:pny_driver/pages/widgets/search_bar.dart';
import 'package:pny_driver/pages/widgets/search_bar_widget.dart';
import 'dart:developer' as developer;
import '../domain/datasource/romaneio_datasource.dart';
import '../domain/models/romaneio_model.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location_geocoder/geocoder.dart';
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
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  final _destinationAddress = TextEditingController();
  List<GeoData> geoData = [];
  List<LatLng> polylineCoordinates = [];
  List<PolylineWayPoint> _polyLinePoints = [];
  late Romaneio romaneio;
  final Set<Marker> _marcadores = {};
  final Set<Polyline> _polylines = {};
  bool _sorted = false;
  late Address myLocation;
  bool _gpsActive = true;
  String myAddress = '';
  double _scaleFactor = 0.65;
  late GoogleMapController _mapController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    romaneio = widget.romaneio;
    _setLocationToAddres();
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
      setState(() {
        _gpsActive = false;
      });
      return Future.error('Location services are disabled.');
    });
  }

  _setLocationToAddres() async {
    final position =
        await _getGeoLocationPosition().onError((error, stackTrace) {
      _gpsActive = false;
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
    var destination =
        await _convertAddressToLatLng(address: _destinationAddress.text);
    final romaneio = widget.romaneio;

    List<ClienteRomaneio> clientes = romaneio.data.clientesRomaneio;

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
      PointLatLng(
          myLocation.coordinates.latitude!, myLocation.coordinates.longitude!),
      PointLatLng(destination.latitude, destination.longitude),
      travelMode: TravelMode.driving,
      wayPoints: _polyLinePoints,
      optimizeWaypoints: true,
    );
    if (result.points.isNotEmpty) {
      polylineCoordinates = [];
      for (var point in result.points) {
        _polylines.add(Polyline(
            polylineId: PolylineId(pointDestination.toString()),
            width: 5,
            geodesic: true,
            points: result.points
                .map((e) => LatLng(e.latitude, e.longitude))
                .toList(),
            color: Color.fromARGB(200, 33, 149, 243)));
      }
    }
    setState(() {});
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

  // void launchMap(String address) async {
  //   var latAddress = await _convertAddressToLatLng(address: address);

  //   String query = Uri.encodeComponent(address);
  //   String googleUrl = 'https://www.google.com/maps/dir//?q=$query';
  //   print(googleUrl);
  //   if (await canLaunchUrl(Uri.parse(googleUrl))) {
  //     await launchUrl(Uri.parse(googleUrl),
  //         mode: LaunchMode.externalApplication);
  //   }
  // }

  _createMarkersFromAddress() async {
    final romaneio = widget.romaneio;

    List<ClienteRomaneio> clientes = romaneio.data.clientesRomaneio;

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
              '${e.logradouro} ${e.numero}- ${e.complemento}, ${e.bairro}, ${e.cidade}, ${e.cep}, ${e.cidade}'),
          position: LatLng(data.latitude, data.longitude),
          infoWindow: InfoWindow(
            title:
                '${e.logradouro} ${e.numero}- ${e.complemento}, ${e.bairro}, ${e.cidade}, ${e.cep}, ${e.cidade}',
            onTap: () {
              showModalBottomSheet(
                  context: context,
                  builder: (context) => Container(
                        height: 200,
                        child: Column(
                          children: [
                            Text(
                                '${e.logradouro} ${e.numero}- ${e.complemento}, ${e.bairro}, ${e.cidade}, ${e.cep}, ${e.cidade}'),
                            TextButton(
                                onPressed: () {
                                  launchGoogleMaps(
                                      '${e.logradouro} ${e.numero}- ${e.complemento}, ${e.bairro}, ${e.cidade}, ${e.cep}, ${e.cidade}');
                                },
                                child: Text('Abrir no Google Maps')),
                            TextButton(
                                onPressed: () {
                                  launchWaze(
                                      '${e.logradouro} ${e.numero}- ${e.complemento}, ${e.bairro}, ${e.cidade}, ${e.cep}, ${e.cidade}');
                                },
                                child: Text('Abrir no Waze')),
                          ],
                        ),
                      ));
            },
          )));
    }

    setState(() {});
  }

  Future<List<ClienteRomaneio>> _sortWaypoints() async {
    try {
      setState(() {
        _sorted = false;
      });
      var _dio = Dio();

      final romaneio = widget.romaneio;

      List<ClienteRomaneio> clientes = romaneio.data.clientesRomaneio;

      List<EnderecoTemplate> enderecos = clientes
          .map((e) => e.enderecos
              .where((element) => element.tipo.label == 'Endereço Entrega')
              .first)
          .toList();

      String waypoints = enderecos
          .map((e) =>
              '${e.logradouro} ${e.numero}- ${e.complemento}, ${e.bairro}, ${e.cidade}, ${e.cep}, ${e.cidade}')
          .join('|');

      developer.log(waypoints);
      var destination =
          await _convertAddressToLatLng(address: _destinationAddress.text);
      final response = await _dio.get(
          'https://maps.googleapis.com/maps/api/directions/json?origin=$myAddress&destination=${destination.address}&waypoints=optimize:true|$waypoints&key=$apiKey');

      List waypointOrder = response.data['routes'][0]['waypoint_order'];

      print(clientes.first.enderecos.first.logradouro);

      _marcadores.add(Marker(
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          markerId: MarkerId(destination.address),
          position: LatLng(destination.latitude, destination.longitude),
          infoWindow: InfoWindow(title: destination.address)));

      // sort clientes endereco by waypointOrder index value
      List<ClienteRomaneio> clientesSorted = [];
      for (var i = 0; i < waypointOrder.length; i++) {
        clientesSorted.add(clientes[waypointOrder[i]]);
      }
      print(clientesSorted.first.enderecos.first.logradouro);
      return clientesSorted;
    } catch (e, s) {
      developer.log(e.toString(),
          name: 'RomaneioDetails', error: e, stackTrace: s);
      final arguments = (ModalRoute.of(context)?.settings.arguments ??
          <String, dynamic>{}) as Map;

      print(arguments);
      final romaneio = arguments['romaneio'] as Romaneio;

      List<ClienteRomaneio> clientes = romaneio.data.clientesRomaneio;
      setState(() {
        _sorted = false;
      });
      return clientes;
    }
  }

  Widget _romaneiosListWidget() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          InkWell(
              onTap: _changeScaleFactor,
              child: IconButton(
                  icon: _scaleFactor == 0.20
                      ? Icon(Icons.expand_less, color: Colors.white, size: 30)
                      : Icon(Icons.expand_more, color: Colors.white, size: 30),
                  onPressed: _changeScaleFactor)),
          AnimationLimiter(
            child: ListView.builder(
              shrinkWrap: true,
              physics: BouncingScrollPhysics(),
              itemCount: romaneio.data.clientesRomaneio.length,
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
              ),
              itemBuilder: (BuildContext context, int index) {
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 2500),
                  delay: Duration(milliseconds: 100),
                  child: SlideAnimation(
                    duration: const Duration(milliseconds: 2500),
                    curve: Curves.fastLinearToSlowEaseIn,
                    horizontalOffset: 30,
                    verticalOffset: 300,
                    child: FlipAnimation(
                      curve: Curves.fastLinearToSlowEaseIn,
                      duration: Duration(milliseconds: 3000),
                      flipAxis: FlipAxis.y,
                      child: ExpandableRomaneioClienteWidget(
                        cliente: romaneio.data.clientesRomaneio[index],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
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
      _scaleFactor = _scaleFactor == 0.20 ? 0.65 : 0.20;
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
              },
              icon: Icon(Icons.directions))
        ],
      ),
      extendBody: true,
      body: myAddress == ''
          ? Center(
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
                              onMapCreated: (controller) {
                                _mapController = controller;
                                _mapController.animateCamera(
                                  CameraUpdate.newCameraPosition(
                                    //create a cameraPosition to fit the route
                                    CameraPosition(
                                      target: LatLng(
                                          myLocation.coordinates.latitude!,
                                          myLocation.coordinates.longitude!),
                                      zoom: 10,
                                    ),
                                  ),
                                );
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
                            padding: EdgeInsets.only(top: 16),
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
                    Positioned(
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
                          validator: (value) => value!.isEmpty
                              ? 'Informe um destino final'
                              : null,
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

                            if (result != null) {
                              _clearAll();
                              _destinationAddress.text = result.description;
                            }
                            ;
                          },
                          onEditingComplete: () {
                            if (_scaleFactor == 0.65) {
                              _changeScaleFactor();
                            }
                            FocusScope.of(context)
                                .requestFocus(new FocusNode());
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
                    ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: myAddress != ''
          ? BottomAppBar(
              color: Palette.customGreyDark.withAlpha(230),
              notchMargin: 4.0,
              child: Container(
                height: 40.0,
              ),
            )
          : null,
      floatingActionButton: myAddress != ''
          ? _sorted
              ? null
              : FloatingActionButton.extended(
                  backgroundColor: Palette.persianasColor,
                  label: Row(
                    children: [
                      Icon(
                        Icons.route_outlined,
                        color: Palette.customGreyDark,
                      ),
                      Text('Rota',
                          style: TextStyle(color: Palette.customGreyDark))
                    ],
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      //loading
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              content: Row(
                                children: [
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
                        _sort().then((value) => Navigator.of(context).pop());
                      } catch (e, s) {
                        _erroSnackBar(e.toString());
                        Navigator.of(context).pop();
                      }
                    }
                  },
                )
          : null,
    );
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

class ExpandableRomaneioClienteWidget extends StatefulWidget {
  final ClienteRomaneio cliente;

  const ExpandableRomaneioClienteWidget({super.key, required this.cliente});

  @override
  State<ExpandableRomaneioClienteWidget> createState() =>
      _ExpandableRomaneioClienteWidgetState();
}

class _ExpandableRomaneioClienteWidgetState
    extends State<ExpandableRomaneioClienteWidget> {
  bool _expanded = false;

  void _handleExpand() {
    setState(() {
      _expanded = !_expanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    EnderecoTemplate enderecoUm = widget.cliente.enderecos
        .where((element) => element.tipo.label == 'Endereço Entrega')
        .first;
    ClienteRomaneio cliente = widget.cliente;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: _expanded
          ? Card(
              elevation: 5,
              child: InkWell(
                onTap: () {
                  _handleExpand();
                },
                child: Column(
                  children: [
                    ListTile(
                      subtitle: Text(
                        cliente.nome,
                      ),
                      title: Text(
                        '${enderecoUm.logradouro!}, ${enderecoUm.numero!} - ${enderecoUm.bairro!} - ${enderecoUm.cidade!}',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                        ),
                      ),
                      trailing: IconButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed('/chegada');
                          },
                          icon: Icon(Icons.check_circle_outline)),
                    ),
                    GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: cliente.pedidosDevenda.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 2,
                      ),
                      itemBuilder: (BuildContext context, int index) {
                        var Pedido = cliente.pedidosDevenda[index];
                        return Card(
                          elevation: 5,
                          child: Column(
                            children: [
                              ListTile(
                                title: Text('pedido: ' + Pedido.codigo),
                                subtitle: Text('itens: ' +
                                    Pedido.ctn00010.length.toString()),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            )
          : Container(
              child: Card(
                  elevation: 5,
                  child: InkWell(
                    onTap: _handleExpand,
                    child: ListTile(
                        title: Text(enderecoUm.logradouro! +
                            ', ' +
                            enderecoUm.numero! +
                            ' - ' +
                            enderecoUm.bairro! +
                            ' - ' +
                            enderecoUm.cidade!),
                        subtitle: Text('código: ' + cliente.codigo)),
                  ))),
    );
  }
}
