import 'package:pny_driver/domain/models/pedido_entregue.dart';

class QueueRequest {
  final List<PedidoEntregue> _queue = [];

  void add(PedidoEntregue pedidoEntregue) {
    _queue.add(pedidoEntregue);
  }

  PedidoEntregue? get() {
    if (_queue.isNotEmpty) {
      return _queue.removeAt(0);
    }
    return null;
  }

  bool isEmpty() {
    return _queue.isEmpty;
  }

  int size() {
    return _queue.length;
  }

  void clear() {
    _queue.clear();
  }

  List<PedidoEntregue> get queue => _queue;

  @override
  String toString() {
    return 'QueueRequest{_queue: $_queue}';
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'queue': _queue.map((x) => x.toMap()).toList(),
    };
  }
}
