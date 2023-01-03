import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pny_driver/pages/widgets/search_bar.dart';

class AddressSearch extends SearchDelegate {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      tooltip: 'Voltar',
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container();
  }

  PlaceService placeService = PlaceService(Dio());

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder(
      future: placeService.getPlace(query),
      builder: (context, snapshot) => query == ''
          ? Container(
              padding: const EdgeInsets.all(16.0),
              child: const Text('Digite o endereço'),
            )
          : snapshot.hasData
              ? ListView.builder(
                  itemBuilder: (context, index) => ListTile(
                    // we will display the data returned from our future here
                    title: Text("${snapshot.data![index].description}"),
                    onTap: () {
                      close(context, snapshot.data[index]);
                    },
                  ),
                  itemCount: snapshot.data!.length,
                )
              : const Text('Carregando...'),
    );
  }
}
