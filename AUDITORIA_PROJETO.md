# Auditoria do projeto — Fábrica do Multiverso

Fase 1 do guia de desenvolvimento. Data: 2026-11-16. Nenhum código do aplicativo foi alterado.

Fontes usadas:

- `fabrica_do_multiverso` (este repositório), commit `4fe9e73`.
- `React-Mutants-Masterminds-Character-Sheet` (referência funcionando): `docs/rules/mm3-effects.md`, `skills/poder-supremo-rules/references/*`, `packages/core/src/model/enums/*`.
- `wiki_mm3_markdown` e `Desenvolvimento/Repositório de Regras` (texto das regras).

O repertório de referência é o repositório React, complementado pela wiki (confirmado em 2026-11-16; a menção a `mutants_and_mastermind_public_index` no guia era um engano e foi corrigida).

## 1. Estado de build e testes

| Verificação | Resultado |
|---|---|
| `flutter pub get` (Flutter 3.47.1, Dart 3.13.1) | OK. 45 pacotes com versão mais nova disponível. |
| `flutter analyze` | 0 erros, 55 avisos. |
| `flutter test` | Não concluiu: ficou mais de 10 minutos sem saída e foi interrompido. |
| Testes existentes | `test/widget_test.dart` não tem nenhum `test()`; é um rascunho com `dev.debugger()`. `test/main.dart` está vazio. |

Na prática o projeto não tem testes automatizados.

O `pub get` regravou os arquivos gerados de plugins em `linux/`, `macos/` e `windows/` (diferença só de fim de linha) e criou `.dart_tool/` e `.flutter-plugins-dependencies`, que não estão no `.gitignore`.

## 2. Arquitetura

| Camada | Caminho | Papel |
|---|---|---|
| Regras | `lib/script/` | Classes de cálculo. As telas consultam o singleton global `personagem` (`ficha.dart:1141`). |
| Telas | `lib/screens/` | Uma tela por módulo, navegação por Drawer (`main.dart:46-55`). |
| Catálogos | `assets/*.json` | Efeitos, modificadores, pacotes, vantagens, perícias. |
| Exportação | `lib/script/download.dart`, `lib/screens/components/printer.dart`, `lib/script/printer/` | ZIP com JSON e imagem; PDF. |

A ficha é guardada como listas de `Map` (o mesmo formato do JSON exportado). As classes (`Habilidade`, `Defesa`, `Pericia`, `Vantagem`, `Efeito` e filhas, `PacotesEfeitos`) são instanciadas sobre o `Map` a cada cálculo.

Hierarquia de efeitos (`lib/script/poderes/lib_efeitos.dart`):

- `Efeito`
  - `EfeitoEscolha` → `EfeitoCompra` (opções somam graduação), `EfeitoCustoVaria` (opções somam custo-base)
  - `EfeitoOfensivo` → `EfeitoDano`, `EfeitoAflicao`
  - `EfeitoBonus` → `EfeitoCrescimento`

A seleção da classe por `switch` está copiada em cinco lugares: `ficha.dart:802`, `ficha.dart:894`, `lib_efeitos.dart:99`, `lib_pacoteEfeitos.dart:176` e `ScreenPoderes.dart:83`.

## 3. Matriz de auditoria

| Funcionalidade | Existe | Situação | Arquivos | Prioridade |
|---|---|---|---|---|
| Habilidades | Sim | Funciona. Custo 2/grad., ausente = −10, bônus de poderes separados. | `script/habilidades/lib_habilidades.dart`, `ScreenHabilidades.dart` | Alta |
| Defesas | Sim | Parcial. Custo e soma com habilidade funcionam. Não há como marcar imunidade pela tela. | `script/defesas/lib_defesas.dart`, `ScreenDefesas.dart` | Alta |
| Perícias | Sim | Parcial. 13 perícias fixas mais ataque e especialidade. Bugs ao excluir e ao recarregar ficha. | `script/pericias/lib_pericias.dart`, `ScreenPericias.dart`, `pericias/functions/addPericias.dart` | Alta |
| Vantagens | Sim | Parcial. Catálogo com 89 entradas; bugs de edição e exclusão; sem vínculo com Equipamento e Idiomas. | `script/vantagens/lib_vantagens.dart`, `ScreenVantagens.dart`, `assets/vantagens.json` | Alta |
| Complicações | Sim | Funciona (título e descrição). | `ScreenComplicacoes.dart` | Média |
| Efeitos de poder | Sim | Parcial. Os 40 efeitos do livro existem; vários sem opções nem modificadores próprios. | `assets/poderes/efeitos.json`, `lib_efeitos.dart` | Crítica |
| Extras e falhas | Sim | Parcial. 42 modificadores genéricos; nenhum modificador próprio de efeito. Ver `MATRIZ_COBERTURA.md`. | `assets/poderes/modificadores.json`, `popup_addModificadores.dart` | Crítica |
| Arranjos (efeitos alternativos) | Estrutura | Sem custo. `PacotesEfeitos.custearAlteracoes()` devolve 0 (`lib_pacoteEfeitos.dart:162-171`). | `lib_pacoteEfeitos.dart`, `ScreenControlePacote.dart` | Crítica |
| Efeitos ligados | Estrutura | Sem custo e sem validação de compatibilidade. | idem | Alta |
| Removível e Equipamento | Estrutura | Campo `removivel` existe, não é calculado nem editável; o valor 4 de Equipamentos é perdido em `ficha.dart:851`. | idem | Alta |
| Cálculo de PP total | Não | Não existe total gasto contra disponível. Só há totais por seção e um rótulo `15×NP` no PDF (`printer.dart:100`). | — | Crítica |
| Validação de NP | Sim | Parcial. Calcula perícias, pares de defesa e ataques, mas o resultado não é mostrado: o popup de erros é um esqueleto (`logErros.dart:24`). | `ficha.dart:17-379` | Crítica |
| Salvar e carregar | Sim | Parcial. Exporta e importa ZIP. Sem salvamento automático, sem lista de personagens, sem "novo personagem". (Atualização de 2026-11-16: decidido que o aplicativo gerencia uma única ficha por vez; há salvamento automático e "Nova ficha", sem lista de personagens.) | `download.dart`, `main.dart:156-166` | Alta |
| PDF | Sim | Parcial. Faltam PP total, custo de pacotes, descrições, escopo de perícias, texto das vantagens. | `printer.dart`, `script/printer/*` | Média |
| Consulta de regras | Não | Nenhuma tela mostra a descrição de efeitos ou modificadores. | — | Média |
| Testes | Não | Ver seção 1. | `test/` | Crítica |

## 4. Motor de regras: o que está correto e o que não está

Custo de um efeito (`Efeito.custearAlteracoes`, `lib_efeitos.dart:291-389`):

- A fórmula `((base + extras − falhas) × graduação) + fixos` está implementada.
- O custo fracionário está certo: custo por graduação 0 vira 1 ponto para 2 graduações, −1 vira 1 para 3.
- O custo mínimo de 1 ponto está aplicado.
- Ação, alcance e duração são tratados por setas na tela, e não como modificadores. Funciona, mas a regra de transições permitidas está duplicada na tela (`powerEdit/functions_controlEdition.dart`).

Problemas encontrados no motor:

| Problema | Onde | Verificado |
|---|---|---|
| Pacotes custam 0: arranjos, ligados, removível e equipamento não entram em nenhuma conta. | `lib_pacoteEfeitos.dart:162` | Sim |
| Não existe o custo de efeito alternativo (1 ponto, ou 2 no dinâmico) nem o teto pelo efeito primário. | — | Sim |
| `EfeitoOfensivo` calcula duração como diferença simples de índices, diferente da regra da classe base. | `lib_efeitos.dart:694` | Sim (leitura) |
| Perícia Aumentada tem `custo_base` 0.5, lido como `int`. Deve falhar em tempo de execução. | `efeitos.json` PB04, `lib_efeitos.dart:366` | Não executado |
| `getCritico()` faz `int.parse` de uma lista; falha se for chamado. | `lib_efeitos.dart:664` | Não executado |
| `instanciarMetodo` das filhas não espera o `super` (falta `await`). | `lib_efeitos.dart:521, 888`, `ficha.dart:922` | Sim (leitura) |
| Validação de ataque não cobre efeitos de área ou percepção (limite = NP) nem ataques desarmados. | `ficha.dart:22-123` | Sim |
| O validador guarda o NP no momento da criação e não acompanha edições. | `ficha.dart:20`, `main.dart:68` | Sim (leitura) |
| Limite de troca de 50% do NP não aparece nas regras consultadas. | `ficha.dart:110` | Regra a confirmar |
| Custo de vantagens ignora Idiomas e Equipamento (5 pontos de equipamento por graduação). | `lib_vantagens.dart` | Sim |

## 5. Regras de negócio dentro das telas

Violam a diretriz de centralizar no motor:

- Transições de ação, duração e alcance: `powerEdit/functions_controlEdition.dart`.
- Quais subpacotes cada pacote aceita: `popup_addPoderes.dart:38-81`.
- Controle do efeito ativo do arranjo: `ScreenControlePacote.dart:44-66, 116-122, 178-186, 216-224`.
- Habilidade ausente: `ScreenHabilidades.dart:119-133`.
- Limite de graduação de vantagem: `addVantagens.dart:105-138`.
- Catálogo de perícias extras: `addPericias.dart:28-34, 221-232`.
- Quais classes aceitam modificadores ofensivos e graduação: `ScreenEditorPoderes.dart:66-69, 90, 222-223`.
- Contas do PDF (ataque, iniciativa, CD, crítico): `printer.dart:203-363`.

## 6. Defeitos encontrados nas telas

Levantados por leitura do código, sem execução.

Perda ou corrupção de dados:

- Salvar quebra o JSON se algum texto tiver aspas (`download.dart:22`).
- Recarregar a ficha transforma especialidades em perícia comum, perdendo o escopo (`ficha.dart:987-989`).
- Cancelar o upload apaga a imagem (`main.dart:163-165`).
- O PDF reordena a lista de vantagens da ficha (`printer.dart:401`).

Travamentos prováveis:

- Voltar pelo botão do sistema devolve `null` para variáveis não nulas em `ScreenPoderes.dart:141-151`, `ScreenControlePacote.dart:248-258`, `ScreenComplicacoes.dart:75-82`, `ScreenPericias.dart:219, 276`, `ScreenEditorPoderes.dart:227, 735, 783`.
- Excluir especialidade passa `null` para `deletePericiaWhere` (`ScreenPericias.dart:204`).
- Editar perícia de ataque depois de carregar ficha: `List<dynamic>` atribuída a `List<String>` (`addPericias.dart:78`).
- `.first` em lista possivelmente vazia: `addVantagens.dart:39`, `popup_OptPoderes.dart:55`, `popup_CaracteristicaAumentada.dart:45`, `popup_addModificadores.dart:77`.
- Excluir efeito de um arranjo não encolhe a lista de ativos (`ScreenControlePacote.dart:213-223`).
- `dev.debugger()` e `print` executam a cada poder impresso no PDF (`powerGenertic.dart:175, 178`).

Comportamento errado:

- Vantagem fica impossível de excluir depois de editada (`lib_vantagens.dart:42`, `ScreenVantagens.dart:117`).
- Editar vantagem volta a graduação para 1 (`addVantagens.dart:43, 208`).
- Modificadores ofensivos só são oferecidos para Dano, não para Aflição nem para os demais efeitos de ataque (`ScreenEditorPoderes.dart:67`).
- A lista de bônus de Crescimento nunca aparece (`ScreenEditorPoderes.dart:702`).
- Custo não é atualizado na tela depois de marcar Ofensivo, Acerto ou Baseado em Força (`ScreenEditorPoderes.dart:278-285, 503-524`).
- Iniciativa no PDF conta qualquer vantagem com "iniciativa" no nome, incluindo Tomar Iniciativa (`printer.dart:240-246`).
- `personagem.init()` é chamado dentro de `build` sem `await`, e há `setState` dentro de `build` (`main.dart:39, 87`).

## 7. Conclusão

A base é aproveitável: o modelo de dados, a fórmula de custo de efeito individual e a estrutura de telas estão no lugar. O que impede o aplicativo de ser usado como ficha completa, em ordem de impacto:

1. Não há total de pontos de poder nem custo de pacotes (arranjos, ligados, removível, equipamento).
2. A validação de NP existe mas não é exibida, e está incompleta.
3. O catálogo de modificadores cobre só os genéricos.
4. Salvar e carregar têm defeitos que perdem dados, e não há persistência local.
5. Não há testes.

A ordem de implementação proposta está em `MATRIZ_COBERTURA.md`, seção 6.
