import 'package:flutter/material.dart';

import 'package:fabrica_do_multiverso/script/ficha.dart';
import 'package:fabrica_do_multiverso/script/ofensiva/lib_ofensiva.dart';

/// Menu Ofensiva: escolhe o que entra na Ofensiva da ficha (PDF).
class ScreenOfensiva extends StatefulWidget {
  const ScreenOfensiva({super.key});
  @override
  State<ScreenOfensiva> createState() => _ScreenOfensivaState();
}

class _ScreenOfensivaState extends State<ScreenOfensiva> {
  @override
  Widget build(BuildContext context) {
    // Linhas prontas do motor (acerto, efeito, CD e margem de crítico)
    List<Map> linhas = Ofensiva.linhas();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ofensiva'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              children: [
                SwitchListTile(
                  title: const Text('Incluir desarmado na ofensiva'),
                  subtitle: const Text(
                      'Ataque desarmado com Força no PDF e no limite de NP'),
                  value: personagem.incluirDesarmado,
                  onChanged: (valor) =>
                      setState(() => personagem.incluirDesarmado = valor),
                ),
                SwitchListTile(
                  title: const Text('Incluir arremesso na ofensiva'),
                  subtitle: const Text(
                      'Arremesso com Força no PDF e no limite de NP'),
                  value: personagem.incluirArremesso,
                  onChanged: (valor) =>
                      setState(() => personagem.incluirArremesso = valor),
                ),
                const Divider(),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('Ataques na ficha',
                      style: TextStyle(fontWeight: FontWeight.w800)),
                ),
                // Resumo: "Garras +12 (Dano 8, CD 23, Crítico 18-20)"
                for (Map linha in linhas)
                  Card(
                    child: ListTile(
                      title: Text(Ofensiva.resumo(linha)),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
