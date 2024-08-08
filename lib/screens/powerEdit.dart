import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

// Instancia de Poderes
import 'package:fabrica_do_multiverso/script/ficha.dart' ;
import 'package:fabrica_do_multiverso/script/poderes/lib_efeitos.dart';


class powerEdit extends StatefulWidget {
  final int idPoder;
  const powerEdit({super.key, required this.idPoder});

  @override
  State<powerEdit> createState() => _powerEditState();
}

class _powerEditState extends State<powerEdit> {
  // Declaração
  TextEditingController inputTextNomePoder = TextEditingController();
  var poder = Efeito();
  var objPoder = {};

  @override

  void initState() {
    super.initState();
    _startPower(); // Carrega os dados ao iniciar o estado
  }

  void _startPower(){
    poder.reinstanciarMetodo(objPoder);  
    setState(() {
      objPoder = personagem.poderes.poderesLista[widget.idPoder];
      inputTextNomePoder.text = objPoder["nome"];
    });
  }

  //************
  //* WIDGETs
  //************

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edição do Poder')
      ),


      body: Padding(padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [

            // Nome Efeito e Graduação
            SizedBox(
              width: double.infinity,
              child: Wrap(
                alignment: WrapAlignment.spaceEvenly,
                
                spacing: 8.0, // Espaço horizontal entre os itens
                runSpacing: 5.0, // Espaço vertical entre as linhas
                children: [
                  SizedBox(
                    width: 350,
                    child: TextField(controller: inputTextNomePoder)
                  ),

                  TextButton(
                    onPressed: () async => {
                      
                      await showDialog(
                        context: context,
                        builder: ((BuildContext context) {
                          return GradPowerDialog(gradValue: objPoder["graduacao"]);
                        })
                      ),
                      //! Atualiza a Lista de poderes
                      setState(() {
                        objPoder = poder.retornaObj();
                      })
                    },

                    child: Text('${objPoder["efeito"]} ${objPoder["graduacao"]}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      )
                    )
                  ),
                ],
              ),
            ),
          ],
        ),
      )
    );
  }
}



//
// popup seta nivel da graduação do poder
//


class GradPowerDialog extends StatefulWidget {
  final int gradValue;
  GradPowerDialog({super.key, required this.gradValue});

  @override
  _GradPowerDialogState createState() => _GradPowerDialogState();
}

class _GradPowerDialogState extends State<GradPowerDialog> {
  // Declaração de Variáveis  
  final efeitos = [];
  int _gradValue = 1;

  TextEditingController inputTextPoder = TextEditingController();
  String EfeitoSelecionado = '';
  @override
  
  void initState() {
    // _title = widget.title;
    super.initState();
    _carregarDados(); // Carrega os dados ao iniciar o estado
  }
  Future<void> _carregarDados() async {
    setState(() {
      _gradValue = widget.gradValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nível de Graduação'),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            NumberPicker(
              value: _gradValue,
              minValue: 1,
              maxValue: 20, // parametrizar pelo NP posteriormente
              onChanged: (value) => setState(() => _gradValue = value),
            ),
          ]
        )
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Adicionar'),
          onPressed: () async{
            // Atualiza a Classe

            // Fecha o popup
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('Cancelar'),
          onPressed: () {
            // Fecha o popup
            Navigator.of(context).pop();
          },
        ),
      ],
      );
  }
}
