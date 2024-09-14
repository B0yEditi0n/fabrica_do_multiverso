// import 'package:bootstrap_icons/bootstrap_icons.dart';
// import 'package:flutter/material.dart';

// // Biblioteca de Pericias
// import 'package:fabrica_do_multiverso/script/ficha.dart';
// import 'package:fabrica_do_multiverso/script/pericias/pericias.dart';

// //# Dialogo de Adição de Perícias

// class PopUpAddSkill extends StatefulWidget {
//   const PopUpAddSkill({super.key});
//   @override
//   _PopUpAddSkillState createState() => _PopUpAddSkillState();
// }

// class _PopUpAddSkillState extends State<PopUpAddSkill> {
//   Map periciaSelecionada ={};
//   List<int> poderesBonusAcerto = []; // Poderes selecionados para bonus
//   Map efeitoBonusSelec   = {}; // Poderes Selecionado para dar bonus de acerto

//   List ofensivePoderes = [];
//   final List<Map<String, String>> periciaListAdd = [
//     {"id": "PA01", "nome": "Atque a Corpo-a-Corpo"},
//     {"id": "PA02", "nome": "Atque a Distância"},
//     {"id": "PA03", "nome": "Especialidade"}
//   ];

  

//   TextEditingController inputDescrPericia = TextEditingController();
  
//   @override
  
//   void initState() {
//     // _title = widget.title;
//     super.initState();
//     _carregarDados(); // Carrega os dados ao iniciar o estado
//   }
//   Future<void> _carregarDados() async {
//     periciaSelecionada = periciaListAdd.first;

//     // Efeitos Ofensivos
//     int rangeOfensive = 0; 
//     periciaSelecionada["id"] == "PA01" ? rangeOfensive = 1 : null;
//     periciaSelecionada["id"] == "PA02" ? rangeOfensive = 2 : null;
//     ofensivePoderes = personagem.pericias.returnOfensiveEfeitos(rangeOfensive);
//     if(ofensivePoderes.isNotEmpty){efeitoBonusSelec = ofensivePoderes.first;}    
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//           //backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//           title: const Text('Adicionar Poderes'),
//           leading: IconButton(
//               icon: const Icon(Icons.arrow_back),
//               onPressed: () async => {
//                     // Fecha A Aplicação & passando alterações
//                     Navigator.of(context).pop()
//                   }),
//         ),
      
//       body: Column(
//         children:[
        
//           //? Input nome da perícia ou descrição do grupo de acerto            
//           periciaSelecionada.isNotEmpty && "PA03" == periciaSelecionada["id"] 
//           ? TextField(
//             controller: inputDescrPericia,
//             decoration: const InputDecoration(
//               border: OutlineInputBorder(),
//               hintText: 'Perícias',
//             ),
//           )
//           : TextField(
//             controller: inputDescrPericia,
//             decoration: const InputDecoration(
//               border: OutlineInputBorder(),
//               hintText: 'Grupo de Acerto',
//             ),
//           ),
      
//           const SizedBox(height: 15,),
          
//           //? Input de Perícia
//           DropdownButton<Map>(
//             value: periciaSelecionada,
//             icon: const Icon(Icons.arrow_downward),
//             elevation: 16,
//             style: const TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
//             underline: Container(
//               height: 2,
//             ),
//             onChanged: (value) {
//               // caso seja um retorno atualiza a lista de Poderes
//               // Atualiza o estado das variáveis
//               setState(() {
//                 periciaSelecionada = value!;     
//                 if(periciaSelecionada["id"] != "PA03"){ // Em caso de ofensivo estruturar lista
//                   int rangeOfensive = 0;
//                   periciaSelecionada["id"] == "PA01" ? rangeOfensive = 1 : null;
//                   periciaSelecionada["id"] == "PA02" ? rangeOfensive = 2 : null;
//                   ofensivePoderes = personagem.pericias.returnOfensiveEfeitos(rangeOfensive);
//                 }
                
//               });
//             },
//             items: periciaListAdd.map<DropdownMenuItem<Map>>((value) {
//               return DropdownMenuItem<Map>(
//                 value: value,
//                 child: Text(value["nome"].toString()),
//               );
//             }).toList(),
//           ),
      
//           //? Perícia baseada ou Efeito selecionado
//           ofensivePoderes.isNotEmpty && "PA03" != periciaSelecionada["id"] ?
//           Column(
//             //mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               // ListView.builder(
//               //   padding: const EdgeInsets.all(4),
//               //   itemCount: poderesBonusAcerto.length,
//               //   itemBuilder: (BuildContext context, int index) {
//               //     return ListTile(
//               //       leading: const Icon(BootstrapIcons.fire),
//               //       title: Text(ofensivePoderes[poderesBonusAcerto[index]]["nome"].toString()),
//               //       //subtitle: Text('Music by Julie Gable. Lyrics by Sidney Stein.'),
//               //     );
//               //   }
//               // ),
//               Expanded(
//                 child: DropdownButton<Map>(
//                   value: efeitoBonusSelec,
//                   icon: const Icon(Icons.arrow_downward),
//                   elevation: 16,
//                   style: const TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
//                   underline: Container(
//                     height: 2,
//                   ),
//                   onChanged: (value) {
//                     setState(() {
//                       efeitoBonusSelec = value!;                  
//                     });
//                   },
//                   items: ofensivePoderes.map<DropdownMenuItem<Map>>((value) {
//                     return DropdownMenuItem<Map>(
//                       value: value,
//                       child: Text("${value["nome"]}: ${value["efeito"]}"),
//                     );
//                   }).toList(),
//                 ),
//               ),
//               IconButton(
//                 icon: const Icon(BootstrapIcons.plus),
//                 onPressed: (){
//                   setState(() {
//                     print(poderesBonusAcerto);
//                     poderesBonusAcerto.add(efeitoBonusSelec["index"]);                      
//                   });                    
//                 },
//               )
//             ],
//           ) : const SizedBox(),
      
//           //? Botões de cancelar e adicionar
//           Row(
//             children: [
//               TextButton(
//                 child: const Text('Adicionar'),
//                 onPressed: () async{
//                   //? Pont de Atenção
//                   // Anexa Descrição da Perícias
//                   periciaSelecionada["escopo"] = inputDescrPericia.text;
//                   // E o Poderes se Tiver
//                   //"PA03" != periciaSelecionada["id"] ?? efeitoBonusSelec
//                   // Fecha o popup
//                   Navigator.of(context).pop(periciaSelecionada);
//                 },
//               ),
      
//               TextButton(
//                 child: const Text('Cancelar'),
//                 onPressed: () {
//                   // Fecha o popup
//                   Navigator.of(context).pop(periciaSelecionada);
//                 },
//               ),
//             ],
//           )
//         ]
//       ),
//       );
//   }
// }

