import 'package:flutter/material.dart';
import 'package:pny_driver/domain/datasource/historico.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({
    Key? key,
  }) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late HistoricoRepository historicoRepository;
  late final ScrollController _scrollController;

  final loading = ValueNotifier(true);

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(infinityScrolling);
    historicoRepository = HistoricoRepository();
    loadRomaneio();
  }

  infinityScrolling() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !loading.value) {
      loadRomaneio();
    }
  }

  @override
  void dispose() {
    super.dispose();

    _scrollController.dispose();
  }

  loadRomaneio() async {
    loading.value = true;
    await historicoRepository.getRomaneiosHistorico();
    loading.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: historicoRepository,
      builder: (context, child) {
        return Stack(
          children: [
            ListView.separated(
              controller: _scrollController,
              itemCount: historicoRepository.historico.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final romaneio = historicoRepository.historico[index];
                // 2022-03-08T00:00:00.000Z convert to date dd/MM/yyyy

                String date = romaneio.deliveryDate;
                String year = date.substring(0, 4);
                String month = date.substring(5, 7);
                String day = date.substring(8, 10);
                String dateFormated = "$day/$month/$year";

                return ListTile(
                  title: Text(romaneio.code),
                  subtitle: Text(// romaneio.deliveryDate convert to date
                      dateFormated),
                );
              },
            ),
            loadingIndicatorWidget(),
          ],
        );
      },
      child: Container(color: Colors.red),
    );
  }

  loadingIndicatorWidget() {
    return ValueListenableBuilder(
        valueListenable: loading,
        builder: (context, isLoad, _) {
          return (isLoad)
              ? Positioned(
                  left: (MediaQuery.of(context).size.width / 2) - 25,
                  bottom: 24,
                  child: const SizedBox(
                    width: 50,
                    height: 50,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  ),
                )
              : Container();
        });
  }
}

class Shimmer {
  const Shimmer._();

  static Widget fromColors({
    required Color baseColor,
    required Color highlightColor,
    Widget? child,
    double? period,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            baseColor,
            highlightColor,
            baseColor,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: child,
    );
  }
}
