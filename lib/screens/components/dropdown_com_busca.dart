//# Seletor com busca (substitui o DropdownButton dos popups)
//
// Fechado, mostra o item escolhido (o nome longo quebra a linha). Ao tocar,
// abre uma caixa centralizada com o campo "Buscar…" no topo, já com foco, e
// a lista filtrada abaixo. A busca ignora maiúsculas e acentos ("acao"
// encontra "Ação"). Tocar fora da caixa fecha sem mudar a escolha.

import 'package:flutter/material.dart';

import 'package:fabrica_do_multiverso/screens/components/abrir_popup.dart';

class OpcaoDropdown<T> {
  final T valor;
  final String rotulo;
  final String? grupo;      // cabeçalho (ex.: "Extras"); null: sem grupo
  final bool habilitado;    // desabilitado aparece cinza e não seleciona

  const OpcaoDropdown({
    required this.valor,
    required this.rotulo,
    this.grupo,
    this.habilitado = true,
  });
}

// Minúsculas e sem acentos, para comparar o texto da busca
String normalizarBusca(String texto) {
  const de = 'ÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇáàâãäéèêëíìîïóòôõöúùûüç';
  const para = 'AAAAAEEEEIIIIOOOOOUUUUCaaaaaeeeeiiiiooooouuuuc';
  StringBuffer b = StringBuffer();
  for (int i = 0; i < texto.length; i++) {
    int idx = de.indexOf(texto[i]);
    b.write(idx >= 0 ? para[idx] : texto[i]);
  }
  return b.toString().toLowerCase().trim();
}

// Opções cujo rótulo contém o termo (sem acento nem caixa), na ordem original
List<OpcaoDropdown<T>> filtrarOpcoes<T>(
    List<OpcaoDropdown<T>> opcoes, String termo) {
  final String t = normalizarBusca(termo);
  if (t.isEmpty) return List.of(opcoes);
  return opcoes.where((o) => normalizarBusca(o.rotulo).contains(t)).toList();
}

class DropdownComBusca<T> extends StatelessWidget {
  final List<OpcaoDropdown<T>> opcoes;
  final T? valor;
  final ValueChanged<T> aoMudar;
  final String dicaBusca;

  const DropdownComBusca({
    super.key,
    required this.opcoes,
    required this.valor,
    required this.aoMudar,
    this.dicaBusca = 'Buscar…',
  });

  OpcaoDropdown<T>? get _selecionada {
    for (final o in opcoes) {
      if (o.valor == valor) return o;
    }
    return null;
  }

  Future<void> _abrirLista(BuildContext context) async {
    final OpcaoDropdown<T>? escolhida = await showDialog<OpcaoDropdown<T>>(
      context: context,
      barrierDismissible: true, // só escolha: nada digitado se perde
      barrierColor: Colors.black54,
      builder: (ctx) => Dialog(
        child: ConstrainedBox(
          constraints: restricoesPopup(MediaQuery.sizeOf(ctx)),
          child: _ListaComBusca<T>(opcoes: opcoes, dicaBusca: dicaBusca),
        ),
      ),
    );
    if (escolhida != null && escolhida.habilitado) {
      aoMudar(escolhida.valor);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool vazio = opcoes.isEmpty;
    final OpcaoDropdown<T>? sel = _selecionada;
    return InkWell(
      onTap: vazio ? null : () => _abrirLista(context),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 56),
        child: InputDecorator(
          isEmpty: sel == null,
          decoration: InputDecoration(
            enabled: !vazio,
            suffixIcon: const Icon(Icons.arrow_drop_down),
          ),
          child: Text(sel?.rotulo ?? ''),
        ),
      ),
    );
  }
}

class _ListaComBusca<T> extends StatefulWidget {
  final List<OpcaoDropdown<T>> opcoes;
  final String dicaBusca;

  const _ListaComBusca({super.key, required this.opcoes, required this.dicaBusca});

  @override
  State<_ListaComBusca<T>> createState() => _ListaComBuscaState<T>();
}

class _ListaComBuscaState<T> extends State<_ListaComBusca<T>> {
  String termo = '';

  // Itens e cabeçalhos na ordem de exibição; grupos sem resultado somem
  List<Object> _linhas() {
    final List<OpcaoDropdown<T>> filtradas = filtrarOpcoes(widget.opcoes, termo);
    final Map<String?, List<OpcaoDropdown<T>>> porGrupo = {};
    for (final o in filtradas) {
      porGrupo.putIfAbsent(o.grupo, () => []).add(o);
    }
    final List<Object> linhas = [];
    porGrupo.forEach((grupo, itens) {
      if (grupo != null) linhas.add(grupo);
      linhas.addAll(itens);
    });
    return linhas;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData tema = Theme.of(context);
    final List<Object> linhas = _linhas();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            autofocus: true,
            decoration: InputDecoration(
              hintText: widget.dicaBusca,
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
            ),
            onChanged: (valor) => setState(() => termo = valor),
          ),
        ),
        Flexible(
          child: linhas.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('Nenhum resultado', textAlign: TextAlign.center),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: linhas.length,
                  itemBuilder: (context, i) {
                    final Object linha = linhas[i];
                    if (linha is String) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                        child: Text(
                          linha,
                          style: tema.textTheme.titleSmall
                              ?.copyWith(color: tema.colorScheme.primary),
                        ),
                      );
                    }
                    final OpcaoDropdown<T> o = linha as OpcaoDropdown<T>;
                    return ListTile(
                      minTileHeight: 56,
                      enabled: o.habilitado,
                      title: Text(o.rotulo),
                      onTap: o.habilitado
                          ? () => Navigator.of(context).pop(o)
                          : null,
                    );
                  },
                ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
