import 'package:pny_driver/shared/models/seletor_model.dart';

class Romaneio {
  late final String id;
  late final String ckc;

  late final String code;
  late final RomaneioData data;

  Romaneio(
      {required this.id,
      required this.ckc,
      required this.code,
      required this.data});

  Romaneio.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    ckc = json["ckc"];
    code = json["code"];
    data = (json["data"] == null ? null : RomaneioData.fromJson(json["data"]))!;
  }
}

class RomaneioData {
  late final String idVeiculo;
  late final String meioDeTransporte;
  late final String numeroPaletes;
  late final List<String> statusGHS;
  late final String entregaPrevista;
  late final String coletadoEm;
  late final SeletorT driver;
  late final String volumeTotal;
  late final String coletaDocumento;
  late final String coletaNome;
  late final String enderecoRetirada;
  late final String localRetirada;
  late final String empresa;
  late final String clientConsulta;
  late final String scenario;
  late final String seloSeguranca;
  late final String observacoesGerais;
  late final String dataCriacao;
  late final List<ClienteRomaneio> clientesRomaneio;
  late final String ultimaIntegracaoRecebidoGHS;
  late final String ultimaIntegracaoEnvioGHS;
  late final String observacoesCabecalho;

  RomaneioData(
      {required this.idVeiculo,
      required this.meioDeTransporte,
      required this.numeroPaletes,
      required this.statusGHS,
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
  late final String observacoesGeraisEntrega;
  late final String formaPagamento;
  late final String condicaoPagamento;
  late final String vendedor;
  late final String inscricaoMunicipal;
  late final String inscricaoEstadual;
  late final String cnpj;
  late final String nome;

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
      required this.nome});

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
  }
}

class RomaneioPedidoDeVenda {
  late final String codigo;
  late final String jId;
  late final String entregaPrevista;
  late final List<ItemPedidoDeVenda> ctn00010;
  late final String dataCriacao;
  late final String referencia;
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
    codigo = json["ipt_00001"];
    jId = json["j_id"];
    entregaPrevista = json["slt_00002"];
    ctn00010 = (json["ctn_00010"] == null
        ? null
        : (json["ctn_00010"] as List)
            .map((e) => ItemPedidoDeVenda.fromJson(e))
            .toList())!;
    dataCriacao = json["slt_00001"];
    referencia = json["ipt_00004"];
    pcp = json["ipt_00003"];
    numeroOrcamento = json["ipt_00002"];
  }
}

class ItemPedidoDeVenda {
  late final String codigoPV;
  late final String modelo;
  late final String jId;
  late final String tecido;
  late final String metroQuadradoCobrado;
  late final String altura;
  late final String largura;
  late final String quantidade;
  late final String unidade;
  late final String observacaoOpcionais;
  late final String observacaoAcionamentos;
  late final String descricao;
  late final String observacao1;
  late final String? fotoBase64;
  late final String codigoProduto;
  late final String tipo;
  late final int itm;
  late final String numeroF;

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
    tecido = json["ipt_00011"];
    metroQuadradoCobrado = json["ipt_00010"];
    altura = json["ipt_00009"];
    largura = json["ipt_00008"];
    quantidade = json["ipt_00007"];
    unidade = json["ipt_00006"];
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
}

class EnderecoTemplate {
  late final String logradouro;
  late final String jId;
  late final String cidade;
  late final SeletorT tipo;
  late final String estadoUF;
  late final String bairro;
  late final String complemento;
  late final String cep;
  late final String numero;

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
}
