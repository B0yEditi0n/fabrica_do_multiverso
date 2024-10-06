import 'package:fabrica_do_multiverso/script/poderes/lib_efeitos.dart';
import 'package:flutter/material.dart';

// Screens de poderes
import 'package:fabrica_do_multiverso/screens/poderes/ScreenEditorPoderes.dart';
import 'package:fabrica_do_multiverso/screens/poderes/poderes/popup_addPoderes.dart';
import 'package:fabrica_do_multiverso/screens/poderes/ScreenControlePacote.dart';

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
  Future _addPoderes(Map objPoder) async{
    if(objEfeito["classe_manipulacao"] != "PacotesEfeitos"){
      await personagem.poderes.novoPoder(objEfeito["nome"], objEfeito["e_id"], objEfeito["classe_manipulacao"]);
    }else{
      await personagem.poderes.novoPacote(objEfeito["nome"], objEfeito["tipo"], objEfeito["efeito"]);
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

        body: ListView.builder(
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
                        poderes[index]["classe_manipulacao"] != "PacotesEfeitos" 
                        ? ListTile(
                          title: Text(poderes[index]['nome']),
                          subtitle: Text("${poderes[index]['efeito']} ${poderes[index]['graduacao']}"),
                        ) 
                        : ListTile(
                          title: Text('${poderes[index]["efeito"]}: ${poderes[index]['nome']}'),                        
                        ),
                    ),
                
                    IconButton(
                      icon: const  Icon(Icons.delete),
                      onPressed: (){
                        // Aciona o destrutor
                        Map objInit = personagem.poderes.poderesLista[index];
                        Efeito killPower;
                        switch (objInit["class"]){
                          case "EfeitoBonus":
                            killPower = EfeitoBonus();
                            break;
                          case "EfeitoCrescimento":
                            killPower = EfeitoCrescimento();
                            break;
                          default:
                            killPower = Efeito();
                        }
                        killPower.reinstanciarMetodo(objInit);
                        killPower.destrutor();

                        personagem.poderes.poderesLista.removeAt(index);
                        setState(() {
                          poderes = personagem.poderes.listaDePoderes();  
                        });
                      }
                    ),
                  ],
                  )
                ),
                poderes[index]["classe_manipulacao"] == "PacotesEfeitos" 
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
              Map returnObjPoder = {};
              Map inputObjEfeito = personagem.poderes.poderesLista[index];
              if(poderes[index]["classe_manipulacao"] != "PacotesEfeitos"){
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
              personagem.poderes.poderesLista[index] = returnObjPoder;

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
            objEfeito = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DynamicDialog(tipo: "", descNome: true),
              )
            ),
            //! Atualiza a Lista de poderes
            if(objEfeito.isNotEmpty){
              _addPoderes(objEfeito)
            }            
          },
        ),
    );
  }
}