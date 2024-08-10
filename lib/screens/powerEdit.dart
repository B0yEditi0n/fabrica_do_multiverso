import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

// Instancia de Poderes
import 'package:fabrica_do_multiverso/script/ficha.dart' ;
import 'package:fabrica_do_multiverso/script/poderes/lib_efeitos.dart';

// Variável de Manipulação de Poderes
var poder = Efeito();

// Function para auxiliar a manipulação da Tela
int alteraAcao(int valorAtual, int passo){
  // passo pode ser positivo ou negativo
  int acaoID = poder.returnObjDefault()["acao"];
  List editID = <int>[];
  int index = -1;

  // Opções de Edião
  switch(acaoID){
    case 0:
      editID = [1, 2, 3];
    case 1:
      editID = [1, 4];
      break;
    case 2:
      editID = [1, 2];
      break;
    case 3 || 4:
      editID = [1, 2, 3, 4];
      break;
  }
  
  // Determina a posição do valor Atual
  index = editID.indexWhere((id) => id == valorAtual);
  // Progride em um passo
  if(index + passo < editID.length && (index + passo) >= 0){
    return editID[index + passo];
  }

  return valorAtual;
}

int alteraDuracao(int valorAtual, int passo){
  // passo pode ser positivo ou negativo
  int duracaoID = poder.returnObjDefault()["duracao"];
  List editID = <int>[];
  int index = -1;

  // Opções de Edião
  switch(duracaoID){
    case 1 || 2: 
      editID = [1, 2];
      break;
    case 0 || 3 || 4:
      editID = [0, 2, 3, 4];
      break;
  }
  
  
  

  // Determina a posição do valor Atual
  index = editID.indexWhere((id) => id == valorAtual);
  print(index + passo < editID.length && (index + passo) >= 0);
  // Progride em um passo
  if(index + passo < editID.length && (index + passo) >= 0){
    print(editID[index + passo]);
    return editID[index + passo];
  }

  return valorAtual;

}

int alteraAlcance(int valorAtual, int passo){
  // passo pode ser positivo ou negativo
  int alcanceID = poder.returnObjDefault()["alcance"];
  List editID = <int>[];
  int index = -1;

  // Opções de Edião
  switch(alcanceID){
    case 1 || 2 || 3:
      editID = [1, 2, 3];
      break;
  }

  // Determina a posição do valor Atual
  index = editID.indexWhere((id) => id == valorAtual);
  // Progride em um passo
  if(index + passo < editID.length && (index + passo) >= 0){
    return editID[index + passo];
  }

  return valorAtual;

}

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
  bool EsconderText = false;
  
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
        centerTitle: true,
        title: const Text('Edição do Poder'),
        leading: IconButton(
        icon: Icon(Icons.arrow_back),
          onPressed: () async => {
            // Salva Alterações
            setState(() {
              personagem.poderes.poderesLista[widget.idPoder] = poder.retornaObj();
            }),
            
            // Fecha A Aplicação
            Navigator.of(context).pop()
          }
        ), 
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
            // Ação, Alcance e Duração
            SizedBox(
              width: double.infinity,
              child: Wrap(
                alignment: WrapAlignment.spaceEvenly,
                children: [
                  Row(
                    // *****************
                    //      Ação
                    // *****************
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_circle_left),
                        onPressed: (){
                          // Chama função externa devido ao tamanho
                          // da lógica de validação
                          int novoValor = alteraAcao(objPoder["acao"], -1);
                          setState(() {
                            poder.alteraAcao(novoValor);
                            objPoder = poder.retornaObj();
                            txtAcao = poder.returnStrAcao();
                          });
                        }
                      ),

                      SizedBox(
                        width: 80,
                        child: Text(
                          txtAcao, // Atual ação
                          textAlign: TextAlign.center,
                        ),
                      ),                      

                      IconButton(
                        icon: const Icon(Icons.arrow_circle_right),
                        onPressed: (){
                          // Chama função externa devido ao tamanho
                          // da lógica de validação
                          int novoValor = alteraAcao(objPoder["acao"], 1);
                          setState(() {
                            poder.alteraAcao(novoValor);
                            objPoder = poder.retornaObj();
                            txtAcao = poder.returnStrAcao();
                          });
                        }
                      ),
                    ],
                  ),

                  // *****************
                  //     Alcance
                  // *****************

                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_circle_left),
                        onPressed: (){
                          int novoValor = alteraAlcance(objPoder["alcance"], -1);
                          setState(() {
                            poder.alteraAlcance(novoValor);
                            objPoder = poder.retornaObj();
                            txtAlcance = poder.returnStrAlcance();
                          });
                        }
                      ),

                      SizedBox(
                        width: 80,
                        child: Text(
                          txtAlcance, // Atual Alcance
                          textAlign: TextAlign.center,
                        ),
                      ),                      

                      IconButton(
                        icon: const Icon(Icons.arrow_circle_right),
                        onPressed: (){
                          // Chama função externa devido ao tamanho
                          // da lógica de validação
                          int novoValor = alteraAlcance(objPoder["alcance"], 1);
                          setState(() {
                            poder.alteraAlcance(novoValor);
                            objPoder = poder.retornaObj();
                            txtAlcance = poder.returnStrAlcance();
                          });
                        }
                      ),
                    ],
                  ),
                  
                  // *****************
                  //     Duração
                  // *****************
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_circle_left),
                        onPressed: (){
                          int novoValor = alteraDuracao(objPoder["duracao"], -1);
                          setState(() {
                            poder.alteraDuracao(novoValor);
                            objPoder = poder.retornaObj();
                            txtDuracao = poder.returnStrDuracao();
                            // Talvez altere a ação
                            txtAcao = poder.returnStrAcao();
                          });
                        }
                      ),

                      SizedBox(
                        width: 100,
                        child: Text(
                          txtDuracao, // Atual Duracao
                          textAlign: TextAlign.center,
                        ),
                      ),                      

                      IconButton(
                        icon: const Icon(Icons.arrow_circle_right),
                        onPressed: (){
                          // Chama função externa devido ao tamanho
                          // da lógica de validação
                          int novoValor = alteraDuracao(objPoder["duracao"], 1);
                          setState(() {
                            poder.alteraDuracao(novoValor);
                            objPoder = poder.retornaObj();
                            txtDuracao = poder.returnStrDuracao();
                            // Talvez altere a ação
                            txtAcao = poder.returnStrAcao();
                          });
                        }
                      ),
                    ],
                  )
                ],
              ),
            ),

            // Parametrizar Widgets Visiveis e Invisiveis
            SizedBox(
              child: Visibility(
                visible: EsconderText, 
                child: Text("Invisible"),
                
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

