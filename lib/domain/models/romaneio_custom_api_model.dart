// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:pny_driver/domain/models/pedido_entregue.dart';

class RomaneioEntregue {
  String codigoRomaneio;
  String codigoCliente;
  String imagemBase64;
  String dataEntrega;
  String nomeRecebedor;
  String documentoRecebedor;
  bool courier = false;
  String? codigoRastreio;
  String? servicoPostal;
  String statusEntrega;
  String statusAplicativo;
  List<PedidoEntregue> pedidos;

  RomaneioEntregue(
      {required this.codigoRomaneio,
      required this.codigoCliente,
      required this.imagemBase64,
      required this.dataEntrega,
      required this.nomeRecebedor,
      required this.documentoRecebedor,
      required this.courier,
      this.codigoRastreio,
      this.servicoPostal,
      required this.statusEntrega,
      required this.statusAplicativo,
      required this.pedidos});

  RomaneioEntregue copyWith({
    String? codigoRomaneio,
    String? codigoCliente,
    String? imagemBase64,
    String? dataEntrega,
    String? nomeRecebedor,
    String? documentoRecebedor,
    bool? courier,
    String? codigoRastreio,
    String? servicoPostal,
    String? statusEntrega,
    String? statusAplicativo,
    List<PedidoEntregue>? pedidos,
  }) {
    return RomaneioEntregue(
      codigoRomaneio: codigoRomaneio ?? this.codigoRomaneio,
      codigoCliente: codigoCliente ?? this.codigoCliente,
      imagemBase64: imagemBase64 ?? this.imagemBase64,
      dataEntrega: dataEntrega ?? this.dataEntrega,
      nomeRecebedor: nomeRecebedor ?? this.nomeRecebedor,
      documentoRecebedor: documentoRecebedor ?? this.documentoRecebedor,
      courier: courier ?? this.courier,
      codigoRastreio: codigoRastreio ?? this.codigoRastreio,
      servicoPostal: servicoPostal ?? this.servicoPostal,
      statusEntrega: statusEntrega ?? this.statusEntrega,
      statusAplicativo: statusAplicativo ?? this.statusAplicativo,
      pedidos: pedidos ?? this.pedidos,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'COD_ROMANEIO': codigoRomaneio,
      'COD_CLIENTE': codigoCliente,
      'FOTO': imagemBase64,
      'DATA_ENTREGA': dataEntrega,
      'RECEBIDO_POR': nomeRecebedor,
      'DOC_RECEBEDOR': documentoRecebedor,
      'COURIER': courier,
      'RASTREADOR': codigoRastreio,
      'SERVICO_POSTAL': servicoPostal,
      'STATUS_ENTREGA': statusEntrega,
      'STATUS_APP': statusAplicativo,
      'PEDIDOS': pedidos.map((x) => x.toMap()).toList(),
    };
  }

  factory RomaneioEntregue.fromMap(Map<String, dynamic> map) {
    return RomaneioEntregue(
      codigoRomaneio: map['COD_ROMANEIO'] as String,
      codigoCliente: map['COD_CLIENTE'] as String,
      imagemBase64: map['FOTO'] as String,
      dataEntrega: map['DATA_ENTREGA'] as String,
      nomeRecebedor: map['RECEBIDO_POR'] as String,
      documentoRecebedor: map['DOC_RECEBEDOR'] as String,
      courier: map['COURIER'] as bool,
      codigoRastreio: map['RASTREADOR'] as String?,
      servicoPostal: map['SERVICO_POSTAL'] as String?,
      statusEntrega: map['STATUS_ENTREGA'] as String,
      statusAplicativo: map['STATUS_APP'] as String,
      pedidos: List<PedidoEntregue>.from(map['PEDIDOS']
              ?.map((x) => PedidoEntregue.fromMap(x as Map<String, dynamic>)) ??
          <PedidoEntregue>[]),
    );
  }

  String toJson() => json.encode(toMap());

  factory RomaneioEntregue.fromJson(String source) =>
      RomaneioEntregue.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'codigoRomaneio: $codigoRomaneio, codigoCliente: $codigoCliente, imagemBase64: $imagemBase64, dataEntrega: $dataEntrega, nomeRecebedor: $nomeRecebedor, documentoRecebedor: $documentoRecebedor, courier: $courier, codigoRastreio: $codigoRastreio, servicoPostal: $servicoPostal, statusEntrega: $statusEntrega, statusAplicativo: $statusAplicativo, pedidos: $pedidos';
  }

  @override
  bool operator ==(covariant RomaneioEntregue other) {
    if (identical(this, other)) return true;

    return other.codigoRomaneio == codigoRomaneio &&
        other.codigoCliente == codigoCliente &&
        other.imagemBase64 == imagemBase64 &&
        other.dataEntrega == dataEntrega &&
        other.nomeRecebedor == nomeRecebedor &&
        other.documentoRecebedor == documentoRecebedor &&
        other.courier == courier &&
        other.codigoRastreio == codigoRastreio &&
        other.servicoPostal == servicoPostal &&
        other.statusEntrega == statusEntrega &&
        other.statusAplicativo == statusAplicativo &&
        listEquals(other.pedidos, pedidos);
  }

  @override
  int get hashCode {
    return codigoRomaneio.hashCode ^
        codigoCliente.hashCode ^
        imagemBase64.hashCode ^
        dataEntrega.hashCode ^
        nomeRecebedor.hashCode ^
        documentoRecebedor.hashCode ^
        courier.hashCode ^
        codigoRastreio.hashCode ^
        servicoPostal.hashCode ^
        statusEntrega.hashCode ^
        statusAplicativo.hashCode ^
        pedidos.hashCode;
  }
}
