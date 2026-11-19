import 'package:fabrica_do_multiverso/script/poderes/lib_custos.dart';
import 'package:flutter/material.dart';
import 'package:fabrica_do_multiverso/screens/components/abrir_popup.dart';

//Screens
import 'package:fabrica_do_multiverso/screens/poderes/ScreenEditorPoderes.dart';
// popups
import 'package:fabrica_do_multiverso/screens/poderes/poderes/popup_addPoderes.dart';

// Lib de Poderes
import 'package:fabrica_do_multiverso/script/ficha.dart';
import 'package:fabrica_do_multiverso/script/poderes/lib_efeitos.dart';
import 'package:fabrica_do_multiverso/script/poderes/lib_pacoteEfeitos.dart';
import 'package:fabrica_do_multiverso/script/poderes/lib_areaCopia.dart';

class ControladorDePacotes extends StatefulWidget {
  final Map objPacote;

  const ControladorDePacotes({super.key, required this.objPacote});

  @override
  State<ControladorDePacotes> createState() => _ControladorDePacotesState();
}

class _ControladorDePacotesState extends State<ControladorDePacotes> {
  //# Declarações
  PacotesEfeitos pacote = PacotesEfeitos();
   
  int indexPoder = -1;
  bool retornoDePacote = true;
  Map objPacote = {};
  Map objPoder = {}; // Retorno objtido de chamadas
  List poderes = [];
  bool nomearEfeitos = true;

  // Controle de texto
  TextEditingController nomePoder = TextEditingController();
  @override
  void initState() {
    super.initState();
    _inicializarVariaveis();
  }

  void _updateAfterCreate(Efeito efeito) async {

    pacote.addPoder(efeito.retornaObj());
    setState(() {
      objPacote = pacote.retornaObj();
    });

    setState((){
      poderes = pacote.efeitos;
    });
    
  }

  void _aviso(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  void _copiar(int index) {
    AreaDeCopia.copiar(pacote.efeitos[index]);
    _aviso('Poder copiado: ${AreaDeCopia.nomeCopia}');
  }

  void _colar() {
    // Mesmas regras de aninhamento do "Adicionar"
    String? recusa = AreaDeCopia.motivoRecusa(pacote.getType());
    if (recusa != null) {
      _aviso(recusa);
      return;
    }
    pacote.addPoder(AreaDeCopia.colar(
      idPacoteDestino: pacote.idCriacao(),
      tipoDestino: pacote.getType(),
    ));
    setState(() {
      objPacote = pacote.retornaObj();
      poderes = pacote.efeitos;
    });
    _aviso('Poder colado: ${AreaDeCopia.nomeCopia}');
  }

  Future<void> _addPoderes(Map objEfeito) async{
    if(objEfeito["colar"] == true){
      _colar();
      return;
    }

    if(!["EfeitosAlternativos", "PacotesEfeitos"].contains(objEfeito["class"])){
      await personagem.poderes.instanciaPoder(objEfeito)
      .then((Efeito efeito)=>
        _updateAfterCreate(efeito)
      );
    }else{
      PacotesEfeitos enpacotado = PacotesEfeitos();
      await enpacotado.instanciarMetodo(objEfeito)
      .then((resulte) async => {
        // Apos a chamada atualiza a lista
        pacote.efeitos.add(enpacotado.retornaObj()),
        setState(() {
          objPacote = pacote.retornaObj();
        }),

        setState(() {
          poderes = pacote.efeitos;
        }),
      });
    }
  }

  void _inicializarVariaveis(){
    // inicialização do objeto
    objPacote = widget.objPacote;
    pacote.instanciarMetodo(objPacote);
    poderes.addAll(objPacote["efeitos"]);

    // define se os efeitos adionados devem ter nome
    if(["R", "E", "D"].contains(pacote.getType())){ nomearEfeitos = true; }
    if(["L"].contains(pacote.getType())){ nomearEfeitos = false; }

    nomePoder.text = pacote.nomePacote;
  }

  //# Widgets
  @override
  Widget build(BuildContext context) {
    // Voltar pelo botão do sistema também devolve o pacote editado
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if(!didPop){ Navigator.of(context).pop(pacote.retornaObj()); }
      },
      child: Scaffold(
        bottomNavigationBar: SafeArea(child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Text(
            CustoPoderes.eEquipamento(pacote.retornaObj())
              ? 'Total: ${CustoPoderes.custoBruto(pacote.retornaObj())} pontos de equipamento'
              : 'Total: ${pacote.custearAlteracoes()} pontos',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
        )),
        appBar: AppBar(
          //backgroundColor: Theme.of(context).colorScheme.inversePrimary,          
          title: objPacote["nome"] != "" 
          ? Text("${objPacote["nome"]}")
          : Text("Poderes de (${objPacote["efeito"]})"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
              onPressed: () async => {
                // Fecha A Aplicação & passando alterações
                Navigator.of(context).pop(pacote.retornaObj())
              }
          ), 
        ),

        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextField(
                controller: nomePoder,
                style: const TextStyle(
                  
                ),
                onChanged: (valor) =>{
                  pacote.nomePacote = nomePoder.text,
                  objPacote = pacote.retornaObj(),
                },
              ),
            ),
            // Falha Removível: só em pacotes simples que não são equipamento
            pacote.getType() == "R" && !CustoPoderes.eEquipamento(pacote.retornaObj())
            ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              // isExpanded: o texto longo quebra em vez de estourar a largura
              child: DropdownButton<int>(
                isExpanded: true,
                itemHeight: 56,
                value: pacote.removivel,
                items: const [
                  DropdownMenuItem(value: 0, child: Text('Não removível')),
                  DropdownMenuItem(value: 1, child: Text('Removível (-1 a cada 5 pontos)')),
                  DropdownMenuItem(value: 2, child: Text('Facilmente removível (-2 a cada 5 pontos)')),
                ],
                onChanged: (valor) => setState(() {
                  pacote.removivel = valor ?? 0;
                  objPacote = pacote.retornaObj();
                }),
              ))
            : const SizedBox(),
            Expanded(
              child: ListView.builder(
                // Espaço no fim para o botão flutuante não cobrir o último item
                padding: const EdgeInsets.only(bottom: 88),
                itemCount: poderes.length,
                itemBuilder: (BuildContext context, int index){
                  return InkWell(
                  child: Card(
                    child: 
                    Row( children: <Widget> [
                      Expanded(
                        child:
                          // Caso sejam Arranjos de EAs I


                          //# Card de Exibição dos Efeitos
                          // Exibe os poderes ativos
                          !["EfeitosAlternativos", "PacotesEfeitos"].contains(poderes[index]["class"])
                          ? ListTile(
                            title: Text(poderes[index]['nome']),
                            subtitle: Text("${poderes[index]['efeito']} ${poderes[index]['graduacao']} • ${CustoPoderes.custoBruto(poderes[index])} pontos"),
                          ) 
                          : ListTile(
                            title: Text('${poderes[index]["efeito"]}: ${poderes[index]['nome']}'),
                            subtitle: Text("${CustoPoderes.custoBruto(poderes[index])} pontos"),
                            //subtitle: Text("${poderes[index]['nome']} ${poderes[index]['custo']}"),
                          ),
                      ),
              
                      IconButton(
                        tooltip: 'Copiar poder',
                        icon: const Icon(Icons.content_copy),
                        onPressed: () => _copiar(index),
                      ),

                      IconButton(
                        icon: const  Icon(Icons.delete),
                        onPressed: () async {
                          
                          Map efeitoEnpacotado = pacote.efeitos[index];
                          // Aciona o destrutor
                          if(efeitoEnpacotado["class"] != "PacotesEfeitos"){
                            // Classe correta, para que bônus aplicados na ficha sejam retirados
                            Efeito deadPower = Efeito.porClasse(efeitoEnpacotado["class"]);
                            await deadPower.reinstanciarMetodo(pacote.efeitos[index]);
                            deadPower.destrutor();
                          }else{
                            PacotesEfeitos deadPackege = PacotesEfeitos();
                            await deadPackege.instanciarMetodo(pacote.efeitos[index]);
                            deadPackege.destrutor();
                          }

                          pacote.efeitos.removeAt(index);
                          setState(() {
                            
                            poderes = pacote.efeitos;
                          });

                          
                        }
                      )
              
                    ],)
                  ),
                  onTap: () async {
                    atualizarValores(){
                      setState(() {
                        poderes = pacote.efeitos;
                      });
                    }

                    Map? returnObjPoder;
                    Map inputObjEfeito = poderes[index];

                    if(!["EfeitosAlternativos", "PacotesEfeitos"].contains(poderes[index]["class"])){
                      
                      returnObjPoder = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => powerEdit(objEfeito: inputObjEfeito)),
                      );
                    }else{
                      returnObjPoder = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ControladorDePacotes(objPacote: inputObjEfeito)),
                      );
                    }
                    if(returnObjPoder != null && returnObjPoder.isNotEmpty){
                      pacote.efeitos[index] = returnObjPoder;
                    }
                    atualizarValores();                      
                  },
                  );
                },
                
              ),
            ),
          ],
        ),

        // add Icone

        floatingActionButton: FloatingActionButton(
          tooltip: 'Adicionar Poder',
          child: const Icon(Icons.add),
          // Ação e PopUP
          onPressed: () async => {
            objPoder = {},            
            objPoder = await abrirPopup<Map>(
              context,
              DynamicDialog(tipo: objPacote["tipo"], descNome: nomearEfeitos)
            ) ?? {},
            //! Atualiza a Lista de poderes
            if(objPoder.isNotEmpty){
              _addPoderes(objPoder)
            }            
          },
        ),
      ),
    );
  }
}