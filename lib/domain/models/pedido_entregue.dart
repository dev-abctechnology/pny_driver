// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class PedidoEntregue {
  String codigoPedidoDeVenda;
  String imagemBase64;
  String statusAplicativo;
  String statusEntrega;
  String detalhamento;

  PedidoEntregue(
    this.codigoPedidoDeVenda,
    this.imagemBase64,
    this.statusAplicativo,
    this.statusEntrega,
    this.detalhamento,
  );

  PedidoEntregue copyWith({
    String? codigoPedidoDeVenda,
    String? imagemBase64,
    String? statusAplicativo,
    String? statusEntrega,
    String? detalhamento,
  }) {
    return PedidoEntregue(
      codigoPedidoDeVenda ?? this.codigoPedidoDeVenda,
      imagemBase64 ?? this.imagemBase64,
      statusAplicativo ?? this.statusAplicativo,
      statusEntrega ?? this.statusEntrega,
      detalhamento ?? this.detalhamento,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'COD_PV': codigoPedidoDeVenda,
      'FOTO': imagemBase64,
      'STATUS_APP': statusAplicativo,
      'STATUS_ENTREGA': statusEntrega,
      'DETALHAMENTO': detalhamento,
    };
  }

  factory PedidoEntregue.fromMap(Map<String, dynamic> map) {
    return PedidoEntregue(
      map['COD_PV'] as String,
      map['FOTO'] as String,
      map['STATUS_APP'] as String,
      map['STATUS_ENTREGA'] as String,
      map['DETALHAMENTO'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory PedidoEntregue.fromJson(String source) =>
      PedidoEntregue.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'codigoPedidoDeVenda: $codigoPedidoDeVenda, imagemBase64: $imagemBase64, statusAplicativo: $statusAplicativo, statusEntrega: $statusEntrega, detalhamento: $detalhamento';
  }

  @override
  bool operator ==(covariant PedidoEntregue other) {
    if (identical(this, other)) return true;

    return other.codigoPedidoDeVenda == codigoPedidoDeVenda &&
        other.imagemBase64 == imagemBase64 &&
        other.statusAplicativo == statusAplicativo &&
        other.statusEntrega == statusEntrega &&
        other.detalhamento == detalhamento;
  }

  @override
  int get hashCode {
    return codigoPedidoDeVenda.hashCode ^
        imagemBase64.hashCode ^
        statusAplicativo.hashCode ^
        statusEntrega.hashCode ^
        detalhamento.hashCode;
  }
}
