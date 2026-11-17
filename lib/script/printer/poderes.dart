import 'package:pdf/widgets.dart' as pw;

import 'package:fabrica_do_multiverso/script/poderes/lib_custos.dart';

//
// Importação das Classes de abstração
//
import 'package:fabrica_do_multiverso/script/printer/powerGenertic.dart';

/*
  Seção "Poderes" do PDF, no formato do modelo de ficha
  (Desenvolvimento/Repositório de Regras/Alquimista.docx e Prodigio.docx):

    Nome do Pacote
    Nome: Efeito 13, modificadores - 30 pontos
    EA: Nome: Efeito 7, modificadores - 29 pontos
    Total: 31 pontos

  Os custos de pacote vêm de CustoPoderes (lib_custos.dart).
*/
class WidPdgPoderes {
  static Future<pw.Widget> customPower(PowerGeneric objPower, Map power,
          [String prefixo = '']) async =>
      await objPower.render(power, prefixo);

  /// Rótulo dos efeitos de um pacote a partir do segundo
  static String prefixoDoTipo(String? tipo) {
    switch (tipo) {
      case "E":
        return 'EA: ';
      case "D":
        return 'EAD: ';
      case "L":
        return 'Ligado: ';
      default:
        return '';
    }
  }

  static String totalPacote(Map pacote) {
    if (CustoPoderes.eEquipamento(pacote)) {
      return 'Total: ${CustoPoderes.custoBruto(pacote)} pontos de equipamento';
    }
    String removivel = '';
    switch (pacote["removivel"] ?? 0) {
      case 1:
        removivel = ' (Removível)';
        break;
      case 2:
        removivel = ' (Facilmente Removível)';
        break;
    }
    return 'Total$removivel: ${CustoPoderes.custoItem(pacote)} pontos';
  }

  static Future<pw.Widget> packege(Map packged) async {
    List efeitos = packged["efeitos"] ?? [];
    String prefixo = prefixoDoTipo(packged["tipo"]);

    List<pw.Widget> linhas = [];
    for (int i = 0; i < efeitos.length; i++) {
      Map item = efeitos[i];
      if (CustoPoderes.ePacote(item)) {
        linhas.add(await packege(item));
      } else {
        linhas.add(
            await customPower(PowerGeneric(), item, i > 0 ? prefixo : ''));
      }
    }

    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            "${packged["nome"] ?? ''}".isEmpty
                ? "${packged["efeito"] ?? 'Pacote'}"
                : "${packged["nome"]}",
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.only(left: 8),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                ...linhas,
                pw.Text(totalPacote(packged),
                    style: pw.TextStyle(fontStyle: pw.FontStyle.italic)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Future<List<pw.Widget>> classificador(List poder) async {
    List<pw.Widget> wigetPoderes = [];

    for (int i = 0; i < poder.length; i++) {
      Map pd = poder[i];

      if (CustoPoderes.ePacote(pd)) {
        wigetPoderes.add(await packege(pd));
      } else {
        wigetPoderes.add(pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 3),
          child: await customPower(PowerGeneric(), pd),
        ));
      }
    }

    return wigetPoderes;
  }
}
