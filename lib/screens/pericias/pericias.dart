import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:fabrica_do_multiverso/script/poderes/lib_efeitos.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Biblioteca de Pericias
import 'package:fabrica_do_multiverso/script/ficha.dart';
import 'package:fabrica_do_multiverso/script/pericias/pericias.dart';

class screenPericias extends StatefulWidget {
  const screenPericias({super.key});
  @override
  _screenPericiasState createState() => _screenPericiasState();
}

class _screenPericiasState extends State<screenPericias> {
  List<Map> ListaPercias = []; // Pericias Adiconais
  Pericia pericia = Pericia(); // Classe de Manipulação
  Map mapPericiaReturn = {};   // Mapa de Retorno
  int custoTotal = 0;          // Custo total

  List<TextEditingController> listInputs = [];

  //* Constante de estilo
  TextStyle headPericias = const TextStyle(fontFamily: "Impact", height: 45);

  @override
  void initState() {
    super.initState();
    _initProg();
    _initialStete();
  }

  _initProg() {
    List classPericias = personagem.pericias.ListaPercias;
    for (Map mapPericias in classPericias) {
      ListaPercias.add(mapPericias);
    }
  }
  
  _updateValues(){
    custoTotal = personagem.pericias.calculaTotal();
  }
  _initialStete() {
    setState(() {
      // define custo total
      custoTotal = personagem.pericias.calculaTotal();

      // Instancia campos de input
      for (Map p in ListaPercias) {
          listInputs.add(TextEditingController(text: p["valor"].toString()));
      }
    });
    return 1;
  }

  @override
  void dispose() {
    //! adição do Chat GPT ao código
    // Certifica-se de descartar todos os controladores ao finalizar
    for (var controller in listInputs) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    //print(screenWidth); // deixar guardado para futuros debug
    int crossAxisCount = 2;
    crossAxisCount = screenWidth > 700 ? 2 : 1;
    return Scaffold(
        appBar: AppBar(
          //backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('Pericias'),
          leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () async => {
                    // Fecha A Aplicação & passando alterações
                    Navigator.of(context).pop()
                  }),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
            // Grid de Pericias
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: GridView.builder(
                  //; configurações de grid
                  //; para deixar mais proximo de uma ficha 2 colunas de pericias
                   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount, // Define o número de colunas
                    crossAxisSpacing: 8,  // Espaço horizontal entre os itens
                    mainAxisSpacing: 1.0,  // Espaço vertical entre os itens
                    childAspectRatio: 2.5,
                                
                    
                  ),
                                
                  itemCount: ListaPercias.length,
                  itemBuilder: (context, index) {
                    Pericia periria = Pericia();
                    periria.init(ListaPercias[index]);
                    
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                                
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(ListaPercias[index]["nome"]),
                          const SizedBox(height: 1),
                          SizedBox(
                            width: 150,
                            height: 100,
                            child: Row(
                              children: [
                            
                                SizedBox(
                                  width: 50,
                                  child: TextField(
                                    controller: listInputs[index],
                                    keyboardType: TextInputType.number,
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                    textAlign: TextAlign.center,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                    ),
                                    onChanged: (value) =>{
                                      if(int.tryParse(value) != null){
                                        personagem.pericias.ListaPercias[index]["valor"] = int.parse(value),
                                      },                                
                                      // _updateValues(),
                                      setState(() {
                                        custoTotal = personagem.pericias.calculaTotal();
                                      }),
                                    }
                                  ),
                                ),
                            
                                const SizedBox(width: 10),
                            
                                Text("Total: ${pericia.bonusTotal()}"),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(
              child: Text('Total: ${custoTotal.toString()}')
            )
          ]
                ),
        ),

      //# Botão de Adicionar novas Perícias
      floatingActionButton: FloatingActionButton(
          tooltip: 'Adicionar Poder',
          child: const Icon(Icons.add),
          // Ação e PopUP
          onPressed: () async => {
            // Fecha o popup
            mapPericiaReturn = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PopUpAddSkill())
            ),
          },
        ),
    );
  }
}


//# Dialogo de Adição de Perícias


class PopUpAddSkill extends StatefulWidget {
  const PopUpAddSkill({super.key});
  @override
  _PopUpAddSkillState createState() => _PopUpAddSkillState();
}

class _PopUpAddSkillState extends State<PopUpAddSkill> {
  Map periciaSelecionada ={};
  List<int> poderesBonusAcerto = []; // Poderes selecionados para bonus
  Map efeitoBonusSelec   = {}; // Poderes Selecionado para dar bonus de acerto

  List ofensivePoderes = [];
  final List<Map<String, String>> periciaListAdd = [
    {"id": "PA01", "nome": "Atque a Corpo-a-Corpo"},
    {"id": "PA02", "nome": "Atque a Distância"},
    {"id": "PA03", "nome": "Especialidade"}
  ];

  

  TextEditingController inputDescrPericia = TextEditingController();
  
  @override
  
  void initState() {
    // _title = widget.title;
    super.initState();
    _carregarDados(); // Carrega os dados ao iniciar o estado
  }
  Future<void> _carregarDados() async {
    periciaSelecionada = periciaListAdd.first;

    // Efeitos Ofensivos
    int rangeOfensive = 0; 
    periciaSelecionada["id"] == "PA01" ? rangeOfensive = 1 : null;
    periciaSelecionada["id"] == "PA02" ? rangeOfensive = 2 : null;
    ofensivePoderes = personagem.pericias.returnOfensiveEfeitos(rangeOfensive);
    if(ofensivePoderes.isNotEmpty){efeitoBonusSelec = ofensivePoderes.first;}    
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Perícia Adicional'),


      content: SingleChildScrollView(
        child: 
          Column(
            children: <Widget>[
              //? Input nome da perícia ou descrição do grupo de acerto            
              periciaSelecionada.isNotEmpty && "PA03" == periciaSelecionada["id"] 
              ? TextField(
                controller: inputDescrPericia,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Perícias',
                ),
              )
              : TextField(
                controller: inputDescrPericia,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Grupo de Acerto',
                ),
              ),
          
              const SizedBox(height: 15,),
              
              //? Input de Perícia
              DropdownButton<Map>(
                value: periciaSelecionada,
                icon: const Icon(Icons.arrow_downward),
                elevation: 16,
                style: const TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
                underline: Container(
                  height: 2,
                ),
                onChanged: (value) {
                  // caso seja um retorno atualiza a lista de Poderes
                  // Atualiza o estado das variáveis
                  setState(() {
                    periciaSelecionada = value!;     
                    if(periciaSelecionada["id"] != "PA03"){ // Em caso de ofensivo estruturar lista
                      int rangeOfensive = 0;
                      periciaSelecionada["id"] == "PA01" ? rangeOfensive = 1 : null;
                      periciaSelecionada["id"] == "PA02" ? rangeOfensive = 2 : null;
                      ofensivePoderes = personagem.pericias.returnOfensiveEfeitos(rangeOfensive);
                    }
                    
                  });
                },
                items: periciaListAdd.map<DropdownMenuItem<Map>>((value) {
                  return DropdownMenuItem<Map>(
                    value: value,
                    child: Text(value["nome"].toString()),
                  );
                }).toList(),
              ),
          
              //? Perícia baseada ou Poderes selecionado
              ofensivePoderes.isNotEmpty && "PA03" != periciaSelecionada["id"] ?
              Column(
                children: [
                  //? Poderes alvo de bonus
                  SizedBox(
                    height: 150,
                    width: 300,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(4),
                      itemCount: poderesBonusAcerto.length,
                      itemBuilder: (BuildContext context, int index) {
                        return InkWell(
                          child: Column(children: [
                            //; Efeitos Adiconados a Perícia
                            ListTile(
                              title: Text(ofensivePoderes[poderesBonusAcerto[index]]['nome']),
                              subtitle: Text(ofensivePoderes[poderesBonusAcerto[index]]['efeito']),
                            ) 
                          ],)
                        );
                      }
                    ),
                  ),
                  DropdownButton<Map>(
                    value: efeitoBonusSelec,
                    icon: const Icon(Icons.arrow_downward),
                    elevation: 16,
                    style: const TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
                    underline: Container(
                      height: 2,
                    ),
                    onChanged: (value) {
                      setState(() {
                        efeitoBonusSelec = value!;                  
                      });
                    },
                    items: ofensivePoderes.map<DropdownMenuItem<Map>>((value) {
                      return DropdownMenuItem<Map>(
                        value: value,
                        child: Text("${value["nome"]}: ${value["efeito"]}"),
                      );
                    }).toList(),
                  ),
                  IconButton(
                    icon: const Icon(BootstrapIcons.plus),
                    onPressed: (){
                      setState(() {
                        print(poderesBonusAcerto);
                        poderesBonusAcerto.add(efeitoBonusSelec["index"]);                      
                      });                    
                    },
                  )
                ],
              ) : const SizedBox(),
            ]
          ),
        ),
        actions: [
          //? Botões de cancelar e adicionar
          TextButton(
            child: const Text('Adicionar'),
            onPressed: () async{
              //? Pont de Atenção
              // Anexa Descrição da Perícias
              periciaSelecionada["escopo"] = inputDescrPericia.text;
              // E o Poderes se Tiver
              //"PA03" != periciaSelecionada["id"] ?? efeitoBonusSelec
              // Fecha o popup
              Navigator.of(context).pop(periciaSelecionada);
            },
          ),
                
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () {
              // Fecha o popup
              Navigator.of(context).pop(periciaSelecionada);
            },
          )
        ],
      );
  }
}

