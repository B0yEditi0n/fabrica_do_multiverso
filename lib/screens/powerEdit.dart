import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

// Instancia de Poderes
import 'package:fabrica_do_multiverso/script/ficha.dart' ;
import 'package:fabrica_do_multiverso/script/poderes/lib_efeitos.dart';

// Variável de Manipulação de Poderes
var poder = Efeito();

class powerEdit extends StatefulWidget {
  final int idPoder;
  const powerEdit({super.key, required this.idPoder});

  @override
  State<powerEdit> createState() => _powerEditState();
}

class _powerEditState extends State<powerEdit> {
  // Declaração
  var objPoder = {};
  String txtAcao = "";
  String txtAlcance = "";
  String txtDuracao = "";
  
  // Inputs de controle
  TextEditingController inputTextNomePoder = TextEditingController();
  

  

  @override

  void initState() {
    super.initState();
    _startPower(); // Carrega os dados ao iniciar o estado
  }

  void _startPower(){
    setState(() {
      objPoder = personagem.poderes.poderesLista[widget.idPoder];
      poder.reinstanciarMetodo(objPoder);  
      inputTextNomePoder.text = objPoder["nome"];

      // Converte as Variáveis para texto
      txtAcao    = poder.returnStrAcao();
      txtAlcance = poder.returnStrAlcance();
      txtDuracao = poder.returnStrDuracao();
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
                    child: TextField(
                      controller: inputTextNomePoder,
                      onChanged: (String value) async{
                        poder.nome = value;
                        objPoder["nome"] = value;
                      },
                    )
                  ), 

                  TextButton(
                    onPressed: () async => {
                      
                      await showDialog(
                        context: context,
                        builder: ((BuildContext context) {
                          return GradPowerDialog(gradValue: objPoder["graduacao"], titulo: 'Valor de Graduação  ',);
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
            // Ação e Duração e Alcance
            SizedBox(
              width: double.infinity,
              child: Wrap(
                alignment: WrapAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () async => {
                      
                      await showDialog(
                        context: context,
                        builder: ((BuildContext context) {
                          return EditValue(initValue: objPoder["acao"], tipo: 'A',);
                        })
                      ),
                      //! Atualiza a Lista de poderes
                      setState(() {
                        objPoder = poder.retornaObj();
                      })
                    },
                    child: const Text("Ação"),
                  )
                ],
              ),
            )

          ],
        ),
      )
    );
  }
}



//****************************************** */
// Pop Up Seta Nivel da Graduação do Poder
//****************************************** */


class GradPowerDialog extends StatefulWidget {
  final int gradValue;
  final String titulo;
  GradPowerDialog({super.key, required this.gradValue, required this.titulo});

  @override
  _GradPowerDialogState createState() => _GradPowerDialogState();
}

class _GradPowerDialogState extends State<GradPowerDialog> {
  // Declaração de Variáveis  
  final efeitos = [];
  int _gradValue = 1;
  String titulo = '';

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
      titulo     = widget.titulo;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(titulo),
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
          child: const Text('Ok'),
          onPressed: () async{
            // Atualiza a Classe
            poder.graduacao = _gradValue;
            // Fecha o popup
            Navigator.of(context).pop();
          },
        ),
      ],
      );
  }
}


//************************************** */
// Pop Up para editar Ação Duração Alcance
//************************************** */


class EditValue extends StatefulWidget {
  final int initValue;
  final String tipo;
  EditValue({super.key, required this.initValue, required this.tipo});

  @override
  _EditValueState createState() => _EditValueState();
}

class _EditValueState extends State<EditValue> {
  // Declaração de Variáveis  
  int _valueChange = 1;
  String titulo = '';

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
      _valueChange = widget.initValue;
      // Range Iniciais 

      switch (widget.tipo) {
        case "A": // Ação
          titulo = "Ação";
          break;
        case "D": // Duração
          titulo = "Duração";
          break;
        case "R": // Alacance
          titulo = "Alcance";
          break;
      }
      
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(titulo),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            NumberPicker(
              value: _valueChange,
              minValue: 1,
              maxValue: 20, // parametrizar pelo NP posteriormente
              onChanged: (value) => setState(() => _valueChange = value),
            ),
          ]
        )
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Ok'),
          onPressed: () async{
            // Atualiza a Classe
            //poder.graduacao = _gradValue;
            // Fecha o popup
            Navigator.of(context).pop();
          },
        ),
      ],
      );
  }
}
