// ignore_for_file: avoid_print

import 'package:pny_driver/shared/models/seletor_model.dart';

class Romaneio {
  late final String id;

  late final String code;
  late final RomaneioData data;

  Romaneio({required this.id, required this.code, required this.data});

  Romaneio.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    code = json["code"];
    data = (json["data"] == null ? null : RomaneioData.fromJson(json["data"]))!;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["id"] = id;
    data["code"] = code;
    data["data"] = this.data.toJson();
    return data;
  }
}

class RomaneioData {
  late final String? idVeiculo;
  late final String? meioDeTransporte;
  late final String? numeroPaletes;
  late final List<String?> statusGHS;
  late final List<String?> statusApp;
  late final String? entregaPrevista;
  late final String? coletadoEm;
  late final SeletorT driver;
  late final String? volumeTotal;
  late final String? coletaDocumento;
  late final String? coletaNome;
  late final String? enderecoRetirada;
  late final String? localRetirada;
  late final String? empresa;
  late final String? clientConsulta;
  late final String? scenario;
  late final String? seloSeguranca;
  late final String? observacoesGerais;
  late final String? dataCriacao;
  late List<ClienteRomaneio> clientesRomaneio;
  late final String? ultimaIntegracaoRecebidoGHS;
  late final String? ultimaIntegracaoEnvioGHS;
  late final String? observacoesCabecalho;

  RomaneioData(
      {required this.idVeiculo,
      required this.meioDeTransporte,
      required this.numeroPaletes,
      required this.statusGHS,
      required this.statusApp,
      required this.dataCriacao,
      required this.clientesRomaneio,
      required this.ultimaIntegracaoRecebidoGHS,
      required this.entregaPrevista,
      required this.coletadoEm,
      required this.driver,
      required this.volumeTotal,
      required this.coletaDocumento,
      required this.coletaNome,
      required this.enderecoRetirada,
      required this.localRetirada,
      required this.empresa,
      required this.clientConsulta,
      required this.scenario,
      required this.ultimaIntegracaoEnvioGHS,
      required this.observacoesCabecalho,
      required this.observacoesGerais,
      required this.seloSeguranca});

  RomaneioData.fromJson(Map<String, dynamic> json) {
    idVeiculo = json["ipt_00012"];
    meioDeTransporte = json["ipt_00011"];
    numeroPaletes = json["ipt_00010"];
    statusGHS = (json["slt_00002"] == null
        ? null
        : List<String>.from(json["slt_00002"]))!;

    statusApp =
        (json["slt_00003"] == null ? [] : List<String>.from(json["slt_00003"]));

    dataCriacao = json["slt_00001"];
    clientesRomaneio = (json["ctn_00007"] == null
        ? null
        : (json["ctn_00007"] as List)
            .map((e) => ClienteRomaneio.fromJson(e))
            .toList())!;
    ultimaIntegracaoRecebidoGHS = json["slt_00008"];
    entregaPrevista = json["slt_00006"];
    coletadoEm = json["slt_00007"];
    driver = (json["slt_00005"] == null
        ? null
        : SeletorT.fromJson(json["slt_00005"]))!;
    volumeTotal = json["ipt_00009"];
    coletaDocumento = json["ipt_00008"];
    coletaNome = json["ipt_00007"];
    enderecoRetirada = json["ipt_00006"];
    localRetirada = json["ipt_00005"];
    empresa = json["ipt_00004"];
    clientConsulta = json["ipt_00003"];
    scenario = json["ipt_00002"];
    ultimaIntegracaoEnvioGHS = json["slt_00011"];
    observacoesCabecalho = json["ipt_00015"];
    observacoesGerais = json["ipt_00014"];
    seloSeguranca = json["ipt_00013"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["ipt_00012"] = idVeiculo;
    data["ipt_00011"] = meioDeTransporte;
    data["ipt_00010"] = numeroPaletes;
    data["slt_00002"] = statusGHS;
    data["slt_00003"] = statusApp;
    data["slt_00001"] = dataCriacao;
    data["ctn_00007"] = clientesRomaneio.map((e) => e.toJson()).toList();
    data["slt_00008"] = ultimaIntegracaoRecebidoGHS;
    data["slt_00006"] = entregaPrevista;
    data["slt_00007"] = coletadoEm;
    data["slt_00005"] = driver.toJson();
    data["ipt_00009"] = volumeTotal;
    data["ipt_00008"] = coletaDocumento;
    data["ipt_00007"] = coletaNome;
    data["ipt_00006"] = enderecoRetirada;
    data["ipt_00005"] = localRetirada;
    data["ipt_00004"] = empresa;
    data["ipt_00003"] = clientConsulta;
    data["ipt_00002"] = scenario;
    data["slt_00011"] = ultimaIntegracaoEnvioGHS;
    data["ipt_00015"] = observacoesCabecalho;
    data["ipt_00014"] = observacoesGerais;
    data["ipt_00013"] = seloSeguranca;
    return data;
  }
}

class ClienteRomaneio {
  late final String codigo;
  late final String jId;
  late final String regiaoEntrega;
  late final String telefoneEntrega;
  late final SeletorT courier;
  late final String entregaPrevista;
  late final List<EnderecoTemplate> enderecos;
  late final List<RomaneioPedidoDeVenda> pedidosDevenda;
  late final String contato;
  late final String? observacoesGeraisEntrega;
  late final String formaPagamento;
  late final String condicaoPagamento;
  late final String vendedor;
  late final String? inscricaoMunicipal;
  late final String? inscricaoEstadual;
  late final String cnpj;
  late final String nome;
  late String imagem;
  late bool entregue;

  ClienteRomaneio(
      {required this.codigo,
      required this.jId,
      required this.regiaoEntrega,
      required this.telefoneEntrega,
      required this.courier,
      required this.entregaPrevista,
      required this.enderecos,
      required this.pedidosDevenda,
      required this.contato,
      required this.observacoesGeraisEntrega,
      required this.formaPagamento,
      required this.condicaoPagamento,
      required this.vendedor,
      required this.inscricaoMunicipal,
      required this.inscricaoEstadual,
      required this.cnpj,
      required this.nome,
      required this.imagem,
      required this.entregue});

  ClienteRomaneio.fromJson(Map<String, dynamic> json) {
    codigo = json["ipt_00001"];
    jId = json["j_id"];
    regiaoEntrega = json["ipt_00011"];
    telefoneEntrega = json["ipt_00010"];
    courier = (json["slt_00003"] == null
        ? null
        : SeletorT.fromJson(json["slt_00003"]))!;
    entregaPrevista = json["slt_00001"];
    enderecos = (json["ctn_00008"] == null
        ? null
        : (json["ctn_00008"] as List)
            .map((e) => EnderecoTemplate.fromJson(e))
            .toList())!;
    pedidosDevenda = (json["ctn_00009"] == null
        ? null
        : (json["ctn_00009"] as List)
            .map((e) => RomaneioPedidoDeVenda.fromJson(e))
            .toList())!;
    contato = json["ipt_00009"];
    formaPagamento = json["ipt_00008"];
    condicaoPagamento = json["ipt_00007"];
    vendedor = json["ipt_00006"];
    inscricaoMunicipal = json["ipt_00005"];
    inscricaoEstadual = json["ipt_00004"];
    observacoesGeraisEntrega = json["ipt_00012"];
    cnpj = json["ipt_00003"];
    nome = json["ipt_00002"];
    imagem = json["cst_00001"] != null ? json["cst_00001"]['data'] : '';
    entregue = json["cst_00001"] != null ? true : false;
    print(imagem);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["ipt_00001"] = codigo;
    data["j_id"] = jId;
    data["ipt_00011"] = regiaoEntrega;
    data["ipt_00010"] = telefoneEntrega;
    data["slt_00003"] = courier.toJson();
    data["slt_00001"] = entregaPrevista;
    data["ctn_00008"] = enderecos.map((e) => e.toJson()).toList();
    data["ctn_00009"] = pedidosDevenda.map((e) => e.toJson()).toList();
    data["ipt_00009"] = contato;
    data["ipt_00008"] = formaPagamento;
    data["ipt_00007"] = condicaoPagamento;
    data["ipt_00006"] = vendedor;
    data["ipt_00005"] = inscricaoMunicipal;
    data["ipt_00004"] = inscricaoEstadual;
    data["ipt_00012"] = observacoesGeraisEntrega;
    data["ipt_00003"] = cnpj;
    data["ipt_00002"] = nome;
    imagem != ''
        ? data["cst_00001"]['data'] = imagem
        : data["cst_00001"] = null;
    data["entregue"] = entregue;
    return data;
  }
}

class RomaneioPedidoDeVenda {
  late final String codigo;
  late final String jId;
  late final String entregaPrevista;
  late final List<ItemPedidoDeVenda> ctn00010;
  late final String dataCriacao;
  late final String? referencia;
  late final String pcp;
  late final String numeroOrcamento;

  RomaneioPedidoDeVenda(
      {required this.codigo,
      required this.jId,
      required this.entregaPrevista,
      required this.ctn00010,
      required this.dataCriacao,
      required this.referencia,
      required this.pcp,
      required this.numeroOrcamento});

  RomaneioPedidoDeVenda.fromJson(Map<String, dynamic> json) {
    codigo = json["ipt_00001"].toString();
    jId = json["j_id"];
    entregaPrevista = json["slt_00002"];
    ctn00010 = (json["ctn_00010"] == null
        ? <ItemPedidoDeVenda>[]
        : (json["ctn_00010"] as List)
            .map((e) => ItemPedidoDeVenda.fromJson(e))
            .toList());
    dataCriacao = json["slt_00001"];
    referencia = json["ipt_00004"];
    pcp = json["ipt_00003"];
    numeroOrcamento = json["ipt_00002"].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["ipt_00001"] = codigo;
    data["j_id"] = jId;
    data["slt_00002"] = entregaPrevista;
    data["ctn_00010"] = ctn00010.map((e) => e.toJson()).toList();
    data["slt_00001"] = dataCriacao;
    data["ipt_00004"] = referencia;
    data["ipt_00003"] = pcp;
    data["ipt_00002"] = numeroOrcamento;
    return data;
  }
}

class ItemPedidoDeVenda {
  late final String codigoPV;
  late final String? modelo;
  late final String jId;
  late final String tecido;
  late final String metroQuadradoCobrado;
  late final String altura;
  late final String largura;
  late final String quantidade;
  late final String unidade;
  late final String? observacaoOpcionais;
  late final String? observacaoAcionamentos;
  late final String descricao;
  late final String? observacao1;
  late final String? fotoBase64;
  late final String codigoProduto;
  late final String tipo;
  late final int itm;
  late final String? numeroF;

  ItemPedidoDeVenda(
      {required this.codigoPV,
      required this.modelo,
      required this.jId,
      required this.tecido,
      required this.metroQuadradoCobrado,
      required this.altura,
      required this.largura,
      required this.quantidade,
      required this.unidade,
      required this.observacaoOpcionais,
      required this.observacaoAcionamentos,
      required this.descricao,
      required this.observacao1,
      this.fotoBase64,
      required this.codigoProduto,
      required this.tipo,
      required this.itm,
      required this.numeroF});

  ItemPedidoDeVenda.fromJson(Map<String, dynamic> json) {
    codigoPV = json["ipt_00001"];
    modelo = json["ipt_00012"];
    jId = json["j_id"];
    tecido = json["ipt_00011"].toString();
    metroQuadradoCobrado = json["ipt_00010"].toString();
    altura = json["ipt_00009"].toString();
    largura = json["ipt_00008"].toString();
    quantidade = json["ipt_00007"].toString();
    unidade = json["ipt_00006"].toString();
    observacaoOpcionais = json["ipt_00017"];
    observacaoAcionamentos = json["ipt_00016"];
    descricao = json["ipt_00004"];
    observacao1 = json["ipt_00015"];
    fotoBase64 = json["cst_00001"];
    codigoProduto = json["ipt_00003"];
    tipo = json["ipt_00014"];
    itm = json["ipt_00002"];
    numeroF = json["ipt_00013"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["ipt_00001"] = codigoPV;
    data["ipt_00012"] = modelo;
    data["j_id"] = jId;
    data["ipt_00011"] = tecido;
    data["ipt_00010"] = metroQuadradoCobrado;
    data["ipt_00009"] = altura;
    data["ipt_00008"] = largura;
    data["ipt_00007"] = quantidade;
    data["ipt_00006"] = unidade;
    data["ipt_00017"] = observacaoOpcionais;
    data["ipt_00016"] = observacaoAcionamentos;
    data["ipt_00004"] = descricao;
    data["ipt_00015"] = observacao1;
    data["cst_00001"] = fotoBase64;
    data["ipt_00003"] = codigoProduto;
    data["ipt_00014"] = tipo;
    data["ipt_00002"] = itm;
    data["ipt_00013"] = numeroF;
    return data;
  }
}

class EnderecoTemplate {
  late final String? logradouro;
  late final String? jId;
  late final String? cidade;
  late final SeletorT tipo;
  late final String? estadoUF;
  late final String? bairro;
  late final String? complemento;
  late final String? cep;
  late final String? numero;

  EnderecoTemplate(
      {required this.logradouro,
      required this.jId,
      required this.cidade,
      required this.tipo,
      required this.estadoUF,
      required this.bairro,
      required this.complemento,
      required this.cep,
      required this.numero});

  EnderecoTemplate.fromJson(Map<String, dynamic> json) {
    logradouro = json["ipt_00001"];
    jId = json["j_id"];
    cidade = json["ipt_00007"];
    tipo = (json["slt_00001"] == null
        ? null
        : SeletorT.fromJson(json["slt_00001"]))!;
    estadoUF = json["ipt_00006"];
    bairro = json["ipt_00005"];
    complemento = json["ipt_00004"];
    cep = json["ipt_00003"];
    numero = json["ipt_00002"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["ipt_00001"] = logradouro;
    data["j_id"] = jId;
    data["ipt_00007"] = cidade;
    data["slt_00001"] = tipo.toJson();
    data["ipt_00006"] = estadoUF;
    data["ipt_00005"] = bairro;
    data["ipt_00004"] = complemento;
    data["ipt_00003"] = cep;
    data["ipt_00002"] = numero;
    return data;
  }
}

class ImagemJarvis {
  late final String code;
  late final String name;
  late final String data;

  ImagemJarvis({required this.code, required this.name, required this.data});

  ImagemJarvis.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    name = json['name'];
    data = json['data'];
  }
}
