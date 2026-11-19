import 'package:fabrica_do_multiverso/script/poderes/lib_efeitos.dart';
import 'package:fabrica_do_multiverso/script/poderes/lib_pacoteEfeitos.dart';
import 'package:fabrica_do_multiverso/script/poderes/lib_custos.dart';
import 'package:fabrica_do_multiverso/script/poderes/lib_areaCopia.dart';
import 'package:flutter/material.dart';
import 'package:fabrica_do_multiverso/screens/components/abrir_popup.dart';

// Screens de poderes
import 'package:fabrica_do_multiverso/screens/poderes/ScreenEditorPoderes.dart';
import 'package:fabrica_do_multiverso/screens/poderes/ScreenControlePacote.dart';
import 'package:fabrica_do_multiverso/screens/poderes/poderes/popup_addPoderes.dart';

// Instancia de Poderes
import 'package:fabrica_do_multiverso/script/ficha.dart';

class ScreenPoderes extends StatefulWidget {
  const ScreenPoderes({super.key});

  @override
  State<ScreenPoderes> createState() => _ScreenPoderesState();
}

class _ScreenPoderesState extends State<ScreenPoderes> {
  // Declaração de Variáveis
  List poderes = [];
  Map objEfeito = {};
  @override

  void initState() {
    super.initState();
    _carregarDados(); // Carrega os dados ao iniciar o estado
  }
  Future<void> _carregarDados() async {
    // Carrega poderes já instanciados
    setState(() {
      //List poderes = [];
      poderes = personagem.poderes.listaDePoderes();  
    });
  }
  void _aviso(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  void _copiar(int index) {
    AreaDeCopia.copiar(personagem.poderes.poderesLista[index]);
    _aviso('Poder copiado: ${AreaDeCopia.nomeCopia}');
  }

  void _colar() {
    String? recusa = AreaDeCopia.motivoRecusa(null);
    if (recusa != null) {
      _aviso(recusa);
      return;
    }
    personagem.poderes.poderesLista.add(AreaDeCopia.colar());
    _carregarDados();
    _aviso('Poder colado: ${AreaDeCopia.nomeCopia}');
  }

  Future _addPoderes(Map objPoder) async{
    if(objEfeito["colar"] == true){
      _colar();
      return;
    }
    if(!["EfeitosAlternativos", "PacotesEfeitos"].contains(objEfeito["class"])){
      await personagem.poderes.novoPoder(objEfeito["nome"], objEfeito["e_id"], objEfeito["class"]);
    }else{
      await personagem.poderes.novoPacote(objEfeito["nome"], objEfeito["tipo"], objEfeito["efeito"], objEfeito["removivel"] ?? 0);
    }
    _carregarDados();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          //backgroundColor: Theme.of(context).colorScheme.inversePrimary,          
          title: const Text("Poderes"),
        ),

        bottomNavigationBar: SafeArea(child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Text(
            'Total: ${personagem.poderes.calculaTotal()}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
        )),

        body: ListView.builder(
          // Espaço no fim para o botão flutuante não cobrir o último item
          padding: const EdgeInsets.only(bottom: 88),
          itemCount: poderes.length,
          itemBuilder: (BuildContext context, int index){
            return InkWell(
            child: Column(
              children: [
                Card(
                  child: 
                  Row( children: <Widget> [
                    Expanded(
                      child:
                        //# Card de Exibição
                        // Exibe os poderes ativos
                        !["EfeitosAlternativos", "PacotesEfeitos"].contains(poderes[index]["class"]) 
                        ? ListTile(
                          title: Text(poderes[index]['nome']),
                          subtitle: Text("${poderes[index]['efeito']} ${poderes[index]['graduacao']} • ${CustoPoderes.custoItem(personagem.poderes.poderesLista[index])} pontos"),
                        ) 
                        : ListTile(
                          title: Text('${poderes[index]["efeito"]}: ${poderes[index]['nome']}'),
                          subtitle: Text(CustoPoderes.eEquipamento(personagem.poderes.poderesLista[index])
                            ? "${CustoPoderes.custoBruto(personagem.poderes.poderesLista[index])} pontos de equipamento"
                            : "${CustoPoderes.custoItem(personagem.poderes.poderesLista[index])} pontos"),
                        ),
                    ),
                
                    IconButton(
                      tooltip: 'Copiar poder',
                      icon: const Icon(Icons.content_copy),
                      onPressed: () => _copiar(index),
                    ),

                    IconButton(
                      icon: const  Icon(Icons.delete),
                      onPressed: ()async {
                        // Aciona o destrutor
                        Map objInit = personagem.poderes.poderesLista[index];

                        if(objInit["class"] != "PacotesEfeitos"){
                          Efeito killPower = Efeito.porClasse(objInit["class"]);
                          await killPower.reinstanciarMetodo(objInit);
                          killPower.destrutor();
                        }else{
                          PacotesEfeitos killEfeitos = PacotesEfeitos();
                          await killEfeitos.instanciarMetodo(objInit);
                          killEfeitos.destrutor();
                        }

                        personagem.poderes.poderesLista.removeAt(index);
                        setState(() {
                          poderes = personagem.poderes.listaDePoderes();  
                        });
                      }
                    ),
                  ],
                  )
                ),
                ["EfeitosAlternativos", "PacotesEfeitos"].contains(poderes[index]["class"]) 
                ? Padding(
                  padding: const EdgeInsets.only(left: 30.0),
                  child: Card(
                    child: ListView.builder(
                      itemCount: poderes[index]["efeitos"].length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, indexE) {
                        return ListTile(
                          title: poderes[index]["efeitos"][indexE]["nome"] != "" 
                          ? Text("${poderes[index]["efeitos"][indexE]["nome"]}: ${poderes[index]["efeitos"][indexE]["efeito"]}")
                          : Text("${poderes[index]["efeitos"][indexE]["efeito"]}")
                        );
                      }
                    )
                  ),
                ) : const SizedBox()
              ],
            ),
            onTap: () async{
               atualizarValores(){
                setState(() {
                  poderes = personagem.poderes.listaDePoderes();
                });
              }
              Map? returnObjPoder;
              Map inputObjEfeito = personagem.poderes.poderesLista[index];
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
              };
              // Voltar pelo botão do sistema não devolve nada: mantém o poder
              if(returnObjPoder != null && returnObjPoder.isNotEmpty){
                personagem.poderes.poderesLista[index] = returnObjPoder;
              }

              // Atualiza os Poderes
              atualizarValores();
              
            },
            );
          },
          
        ),

        //# Icone de Adicionar Novos Poderes

        floatingActionButton: FloatingActionButton(
          tooltip: 'Adicionar Poder',
          child: const Icon(Icons.add),
          // Ação e PopUP
          onPressed: () async => {
            objEfeito = {},
            objEfeito = await abrirPopup<Map>(
              context,
              DynamicDialog(tipo: "", descNome: true),
            ) ?? {},
            //! Atualiza a Lista de poderes
            if(objEfeito.isNotEmpty){
              _addPoderes(objEfeito)
            }            
          },
        ),
    );
  }
}