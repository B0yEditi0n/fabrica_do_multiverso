//# Dialogo de Adição de Perícias

import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:fabrica_do_multiverso/screens/components/dropdown_com_busca.dart';

// Biblioteca de Pericias
import 'package:fabrica_do_multiverso/script/vantagens/lib_vantagens.dart';

class PopUpAddVantagem extends StatefulWidget {
  List repertorioVantagens = [];
  Map obj = {};
  PopUpAddVantagem(
      {super.key, required this.repertorioVantagens, required this.obj});

  @override
  _PopUpAddVantagemState createState() => _PopUpAddVantagemState();
}

class _PopUpAddVantagemState extends State<PopUpAddVantagem> {
  Map selectVantagem = {};
  List repertorioVantagens = [];
  int valueVantagem = 1;
  Vantagem vantagemObj = Vantagem();

  TextEditingController inputIntVantagem = TextEditingController();
  TextEditingController textDesc = TextEditingController();

  @override
  void initState() {
    // _title = widget.title;
    super.initState();
    _carregarDados(); // Carrega os dados ao iniciar o estado
  }

  void _carregarDados() async {
    repertorioVantagens = widget.repertorioVantagens;
    if(widget.obj.isEmpty){
      // Lista vazia: o seletor fica desabilitado e Adicionar não faz nada
      selectVantagem = repertorioVantagens.isEmpty ? {} : repertorioVantagens.first;
      inputIntVantagem.text = '1';
    }else{
      selectVantagem = widget.obj;
      // Parte da graduação já comprada (antes a edição voltava para 1)
      valueVantagem = widget.obj["graduacao"] ?? 1;
      inputIntVantagem.text = valueVantagem.toString();
      textDesc.text = widget.obj["txtDec"] ?? "";
    }
    
  }

  // Teto oficial da vantagem selecionada (null: sem teto)
  int? _graduacaoMaxima() => Vantagem().init(selectVantagem).graduacaoMaxima();

  void _defineGraduacao(int valor) {
    valor = Vantagem().init(selectVantagem).limitaGraduacao(valor);
    setState(() {
      valueVantagem = valor;
      if (inputIntVantagem.text != '$valor') {
        // Mantém o cursor no fim ao corrigir o valor digitado
        inputIntVantagem.value = TextEditingValue(
          text: '$valor',
          selection: TextSelection.collapsed(offset: '$valor'.length),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final int? teto = _graduacaoMaxima();
    // Lista vazia: nada a escolher nem a adicionar
    final bool semVantagem = selectVantagem.isEmpty;
    return AlertDialog(
      title: const Text('Vantagens'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            //? Seleciona a Vantagem
            widget.obj.isEmpty ?
            DropdownComBusca<Map>(
              opcoes: repertorioVantagens.map((value) => OpcaoDropdown<Map>(
                valor: value,
                rotulo: value["nome"].toString(),
              )).toList(),
              valor: semVantagem ? null : selectVantagem,
              aoMudar: (value) {
                setState(() {
                  selectVantagem = value;
                });
                _defineGraduacao(1);
              },
            ) : const SizedBox(),

            const SizedBox(height: 15),

            //? Descrição da Vantagem (se tiver)
            selectVantagem["desc"] == true ?
            TextField(
              controller: textDesc,
              decoration: const InputDecoration(
                hintText: 'Descrição',
              ),
              textAlign: TextAlign.center,
              textAlignVertical: TextAlignVertical.center,
            ) : const SizedBox(),

            //; se for graduado
            selectVantagem["graduado"] == true ?
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  tooltip: 'Diminuir graduação',
                  icon: const Icon(Icons.remove),
                  onPressed: valueVantagem > 1
                    ? () => _defineGraduacao(valueVantagem - 1)
                    : null,
                ),
                SizedBox(
                  width: 80,
                  child: TextField(
                    controller: inputIntVantagem,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    onChanged: (value) {
                      if (value.isNotEmpty) _defineGraduacao(int.parse(value));
                    },
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      helperText: teto == null
                        ? 'Nº Grad.'
                        : 'Máx. $teto',
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Aumentar graduação',
                  icon: const Icon(Icons.add),
                  // Desabilitado ao atingir o teto oficial
                  onPressed: teto == null || valueVantagem < teto
                    ? () => _defineGraduacao(valueVantagem + 1)
                    : null,
                ),
              ],
            ) : const SizedBox(),
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actionsOverflowAlignment: OverflowBarAlignment.center,
      actions: [
        TextButton(
          child: const Text("Cancelar"),
          onPressed: (){
            Navigator.of(context).pop({});
          }
        ),

        TextButton(
          onPressed: semVantagem ? null : (){
            // Checa se tem descrição
            if(selectVantagem["desc"] == true){
              selectVantagem["txtDec"] = textDesc.text;
            }

            // Checa se tem graduação
            if(selectVantagem["graduado"] == true){
              selectVantagem["graduacao"] = valueVantagem;
            }else{
              selectVantagem["graduacao"] = 1;
            }

            vantagemObj.init(selectVantagem);
            Navigator.of(context).pop(vantagemObj.returnObj());
          },
          child: const Text("Adicionar"),
        )
      ],
    );
  }
}
