import 'package:flutter/material.dart';
import 'package:fabrica_do_multiverso/screens/components/dropdown_com_busca.dart';
import 'package:flutter/services.dart'; 
import 'dart:convert';

// Instancia de Poderes
import 'package:fabrica_do_multiverso/script/ficha.dart';
import 'package:fabrica_do_multiverso/script/poderes/lib_areaCopia.dart';

//# Dialogo Adicionar Poderes

class DynamicDialog extends StatefulWidget {
  String tipo = "";
  bool descNome = true;
  DynamicDialog({super.key, required this.tipo, required this.descNome});
  @override
  _DynamicDialogState createState() => _DynamicDialogState();
}

class _DynamicDialogState extends State<DynamicDialog> {
  final List<Map> efeitos = [];
  String efeitoSelecionado = '';
  Map objEfeito = {};
  TextEditingController inputTextPoder = TextEditingController();
  
  @override
  
  void initState() {
    // _title = widget.title;
    super.initState();
    _carregarDados(); // Carrega os dados ao iniciar o estado
  }
  Future<void> _carregarDados() async {
    // Carrega o Efeitos
    String jsonEfeitos = await rootBundle.loadString('assets/poderes/efeitos.json');
    String jsonPacotes = await rootBundle.loadString('assets/poderes/pacotes.json');
    List<dynamic> objEfeitos = jsonDecode(jsonEfeitos);
    List<dynamic> objPacotes = jsonDecode(jsonPacotes);

    if(widget.tipo == ""){ // chamada normal
      objEfeitos.addAll(objPacotes);
    }else{ // é um pacote que chama
      //? nota de atenção alguns Pacotes podem adicionar
      //? alguns tipos de sub pacotes
      if(["E", "D"].contains(widget.tipo)){
        // Efeitos Alternativos podem incluir apenas efefeitos ligados
        int linkIndex = objPacotes.indexWhere((obj)=> obj["e_id"] == "P005");
        objEfeitos.add(objPacotes[linkIndex]);
      }
      
      if("R" == widget.tipo){
        // Removivel pode conter efeitos ligados e EA

        // EA
        int index = objPacotes.indexWhere((obj)=> obj["e_id"] == "P003");
        objEfeitos.add(objPacotes[index]);

        // EAD
        index = objPacotes.indexWhere((obj)=> obj["e_id"] == "P004");
        objEfeitos.add(objPacotes[index]);
        
        // Efeitos Ligados
        index = objPacotes.indexWhere((obj)=> obj["e_id"] == "P005");
        objEfeitos.add(objPacotes[index]);

      }

      if("F" == widget.tipo){
        // Formas pode conter efeitos ligados e EA

        // EA
        int index = objPacotes.indexWhere((obj)=> obj["e_id"] == "P003");
        objEfeitos.add(objPacotes[index]);

        // EAD
        index = objPacotes.indexWhere((obj)=> obj["e_id"] == "P004");
        objEfeitos.add(objPacotes[index]);
        
        // Efeitos Ligados
        index = objPacotes.indexWhere((obj)=> obj["e_id"] == "P005");
        objEfeitos.add(objPacotes[index]);

      }
    }

    // O popup pode ter sido fechado durante a leitura
    if(!mounted) return;

    // Converte o JSON em objetos
    setState(() {
      Map efeito = {};
      for(efeito in objEfeitos){
        efeitos.add(efeito);
      }

      // Lista vazia: o seletor fica desabilitado
      if(efeitos.isNotEmpty){
        efeitoSelecionado = efeitos.first["e_id"];
        objEfeito = efeitos.first;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Adicionar Poderes'),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
          
            //* Entrada do Nome
            TextField(
              controller: inputTextPoder,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Nome do poder',
              ),
            ),

            const SizedBox(height: 15,),

            DropdownComBusca<String>(
              opcoes: efeitos.map((value) => OpcaoDropdown<String>(
                valor: value["e_id"].toString(),
                rotulo: value["efeito"].toString(),
              )).toList(),
              valor: efeitoSelecionado.isEmpty ? null : efeitoSelecionado,
              aoMudar: (value) {
                setState(() {
                  efeitoSelecionado = value;
                  // Atualiza o selecionado
                  int index = efeitos.indexWhere((mod) => mod["e_id"] == efeitoSelecionado);
                  if(index >= 0) objEfeito = efeitos[index];
                });
              },
            )
          ]
        )
      ),
      
      actionsAlignment: MainAxisAlignment.center,
      actionsOverflowAlignment: OverflowBarAlignment.center,
      actions: <Widget>[
        // Colar o poder copiado (área de cópia em lib_areaCopia.dart)
        if(AreaDeCopia.temCopia)
          TextButton.icon(
            icon: const Icon(Icons.content_paste),
            label: Text('Colar: ${AreaDeCopia.nomeCopia}',
              overflow: TextOverflow.ellipsis),
            onPressed: () => Navigator.of(context).pop({"colar": true}),
          ),

        TextButton(
          child: const Text('Adicionar'),
          onPressed: () async{
            //? Pont de Atenção
            // os efeitos devem já aqui ser
            // instanciados na classe correta
            objEfeito["nome"] = inputTextPoder.text;
            // Fecha o popup
            Navigator.of(context).pop(objEfeito);
          },
        ),

        TextButton(
          child: const Text('Cancelar'),
          onPressed: () {
            // Fecha o popup
            Navigator.of(context).pop({});
          },
        ),
      ],
      );
  }
}
