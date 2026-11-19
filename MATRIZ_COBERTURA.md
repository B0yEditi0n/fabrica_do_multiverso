# Matriz de cobertura — repertório de regras × aplicativo

Fase 2 do guia de desenvolvimento. Data: 2026-11-16. Atualizada em 2026-11-19 (importação do Poder Supremo, arranjos sem efeito ativo, custo dinâmico por efeito, Imunidade/Movimento, PDF e interface para celular; arremesso opcional, modificador Perigoso e margem de crítico na Ofensiva e no PDF; popups sobre a tela de origem, centralizados e com busca).

Repertório de referência: `React-Mutants-Masterminds-Character-Sheet` (`docs/rules/mm3-effects.md` e os enums em `packages/core/src/model/enums/`). O repositório React também contém material da 4ª edição e de suplementos; aqui só conta o que é da 3ª edição.

Legenda: **OK** implementado; **Parcial** existe com lacuna; **Ausente** não existe.

## 1. Resumo

| Catálogo | Referência | No aplicativo | Situação |
|---|---|---|---|
| Efeitos-base | 40 | 40 | Todos presentes por nome; 27 com lacunas de opções ou modificadores próprios |
| Modificadores genéricos | cerca de 65 | 58 | Catálogo completo (Perigoso incluído em 2026-11-19); os que não aparecem como item são opções do efeito ou do pacote (seção 3.1) |
| Modificadores próprios de efeito | cerca de 125 | Impenetrável + 14 (Mover Objetos 4, Teleporte 10) | Parcial |
| Vantagens | 95 identificadores | 88 entradas | Catálogo completo (Velocidade do Pensamento incluída, duplicadas removidas); subtipos continuam como uma entrada com descrição |
| Perícias | 16 | 13 fixas + 3 adicionáveis | OK |
| Habilidades | 8 | 8 | OK |
| Defesas | 5 | 5 | OK (falta imunidade pela tela) |
| Estruturas de poder | 5 | 5 | Estrutura presente, custo ausente |

## 2. Efeitos

Arquivo: `assets/poderes/efeitos.json`. Classe em `lib/script/poderes/lib_efeitos.dart`.

| Efeito | ID | Classe | Situação | Lacuna |
|---|---|---|---|---|
| Aflição | E001 | EfeitoAflicao | Parcial | Sem escolha da resistência (Fortitude ou Vontade); condições em texto livre; sem Condição Extra, Cumulativo, Progressivo, Grau Limitado, Recuperação Instantânea; modificadores ofensivos não são oferecidos na tela |
| Alongamento | E002 | Efeito | OK | — |
| Ambiente | E003 | EfeitoCustoVaria | OK | 8 opções |
| Camuflagem | E004 | EfeitoCompra | Parcial | Sem Mesclar, Parcial, Passiva, Resistível |
| Característica | E005 | Efeito | OK | — |
| Característica Aumentada | PB01–PB04 | EfeitoBonus | Parcial | Perícia Aumentada (PB04) com custo 0.5 lido como inteiro; sem Característica Diminuída |
| Compreender | E007 | EfeitoCompra | OK | 6 opções |
| Comunicação | E008 | Efeito | Parcial | Sem escolha do tipo sensorial; sem Área, Rápido, Seletiva, Dependente de Sentido |
| Controle de Sorte | E009 | EfeitoCompra | Parcial | Classe de compra sem nenhuma opção cadastrada |
| Crescimento | PB05 | EfeitoCrescimento | Parcial | Lista de bônus não aparece na tela; sem Permanente |
| Criar | E011 | EfeitoOfensivo | Parcial | Sem Amarrar, Estacionário, Móvel, Proporcional |
| Cura | E012 | Efeito | Parcial | Sem Energizante, Estabilizar, Persistente, Ressurreição, Empático, Temporário |
| Dano | E013 | EfeitoDano | Parcial | Baseado em Força existe; o desconto usa a Força total, incluindo bônus de poderes (a confirmar) |
| Deflexão | E014 | Efeito | Parcial | Sem Redirecionar, Reflexão |
| Encolhimento | PB06 | EfeitoCrescimento | Parcial | Sem Atômico, Força Normal |
| Enfraquecer | E016 | EfeitoOfensivo | Parcial | Sem escolha da característica alvo nem da resistência; sem Amplo, Incurável, Progressivo, Simultâneo |
| Escavação | E017 | Efeito | OK | — |
| Ilusão | E018 | EfeitoCustoVaria | Parcial | 4 opções; sem Independente, Seletiva, Limitada a Um Alvo |
| Imortalidade | E019 | Efeito | OK | — |
| Imunidade | E020 | EfeitoCompra | Parcial | 25 opções; graduação = soma das opções, recalculada ao carregar (2026-11-17); não marca a defesa como imune na ficha; sem Limitado à Metade do Efeito |
| Intangibilidade | E021 | EfeitoCompra | Parcial | 4 graus; sem Afeta Tangível, Força Ausente |
| Invocar | E022 | Efeito | Parcial | Sem Ativo, Capangas Múltiplos, Controlado, Elo Mental, Heroico, Horda, Sacrifício, Tipo Variável, Atitude |
| Leitura Mental | E023 | EfeitoOfensivo | Parcial | Sem Elo Sensorial, Sem Esforço e as limitações de conteúdo |
| Membros Extras | E024 | Efeito | OK | — |
| Morfar | E025 | Efeito | Parcial | Sem os 4 graus de abrangência; sem Metamorfose |
| Mover Objetos | E026 | EfeitoOfensivo | OK | Modificadores da wiki incluídos em 2026-11-17 (Arma Improvisada ou Maestria em Arremesso, Dano, Direção Limitada, Limitação Material); dano total entra no limite de NP |
| Movimento | E027 | EfeitoCompra | Parcial | Classe de compra sem nenhuma opção cadastrada (a referência tem cerca de 12) |
| Natação | E028 | Efeito | OK | — |
| Nulificar | E029 | EfeitoOfensivo | Parcial | Sem Aleatório, Amplo, Simultâneo, Sem Esforço |
| Proteção | E030 | EfeitoCrescimento | OK | Soma em Resistência; Impenetrável disponível |
| Rapidez | E031 | Efeito | Parcial | Sem Limitado a Uma Tarefa, Limitado a Um Tipo |
| Regeneração | E032 | Efeito | Parcial | Sem Persistente, Fonte |
| Salto | E033 | Efeito | OK | — |
| Sentido Remoto | E034 | EfeitoCustoVaria | Parcial | 4 opções; sem Não Condutor, Simultânea, Meio |
| Sentidos | E035 | EfeitoCompra | OK | 34 opções |
| Teleporte | E036 | Efeito | OK | Modificadores da wiki incluídos em 2026-11-17 (Acurado, Estendido, Fácil, Giro, Mudar a Direção, Mudar a Velocidade, Portal, Limitado a Estendido, Meio, Tempo de Transporte); Limitado a Estendido exige Estendido |
| Transformar | E037 | EfeitoCustoVaria | OK | 4 opções |
| Variável | E038 | Efeito | Parcial | Sem controle dos 5 pontos por graduação; sem Lento |
| Velocidade | E039 | Efeito | OK | — |
| Voo | E040 | Efeito | Parcial | Sem Asas, Levitação, Planar, Plataforma, Aquático |

Também ausentes para todos os efeitos: descrição consultável (RF013) e descritores.

## 3. Modificadores

Arquivo: `assets/poderes/modificadores.json`, com quatro grupos (`gerais`, `ofensivos`, `pessoais`, `defesas`). A tela oferece `gerais` sempre, `ofensivos` para efeitos que agem sobre um alvo e `pessoais` para efeitos de alcance padrão pessoal (`Efeito.gruposModificadores`).

### 3.1 Genéricos: situação em 2026-11-16

| Modificador | Tipo | Observação |
|---|---|---|
| Acurado | Extra fixo | Coberto pelo campo Acerto do efeito ofensivo (1 ponto por +2) |
| Afeta Outros | Extra | Incluído (E063, grupo pessoais) |
| Afeta Apenas Outros | Extra +0 | Incluído (E064, grupo pessoais) |
| Área (e formas) | Extra | Incluído (E049; a forma vai no texto, cada graduação é +1 por graduação). A validação de NP para área ainda não existe |
| Ataque | Extra +0 | Coberto pela caixa Ofensivo |
| Alcance Estendido | Extra fixo | Incluído (E055) |
| Distância Aumentada | Extra | Coberto pelas setas de alcance |
| Duração Aumentada | Extra | Coberto pelas setas de duração |
| Incurável | Extra fixo | Incluído (E056) |
| Reação | Extra | Coberto pelas setas de ação |
| Resistência Alternativa | Extra +0 ou +1 | Incluído em duas entradas (E057 +0, E058 +1) |
| Sonífero | Extra +0 | Incluído (E059) |
| Sustentado | Extra +0 | Coberto pelas setas de duração |
| Baseado em Agarrar | Falha | Incluído (E060) |
| Dependente de Sentido | Falha | Incluído (E061) |
| Distância Reduzida, Ação Aumentada, Concentração, Permanente | Falha | Cobertos pelas setas |
| Impreciso | Falha fixa | Incluído (E062); a penalidade de -2 no ataque ainda não entra no acerto |
| Resistível | Falha | Incluído (E050) |
| Removível | Falha fixa | Campo do pacote, com cálculo em `lib_custos.dart` |
| Personalizado (extra e falha, fixo e por graduação) | — | Incluído (E051 a E054) |

### 3.2 Dados suspeitos no catálogo — corrigidos

| ID | Nome | Antes | Agora |
|---|---|---|---|
| E036 | Dissipação (duplicado) | — | Removido |
| E001 | Afeta Corpóreo | −1 fixo | +1 fixo por graduação, até a graduação do efeito |
| E006 | Alcance | 0 fixo | Removido: o alcance é opção do efeito e já é custeado lá |
| E007 | Aumentar Massa | 0 fixo | +1 fixo por graduação (limite de tela: 10) |
| E011 | Dimensional | 0 fixo, limite 3 | +1 fixo por graduação, limite 3 |
| E018 | Inato | +1 por graduação | +1 fixo |

### 3.3 Próprios de efeito

A referência tem cerca de 125 modificadores próprios, distribuídos por 25 efeitos. O aplicativo tem Impenetrável e, desde 2026-11-17, os de Mover Objetos (4) e Teleporte (10). As lacunas estão na coluna "Lacuna" da seção 2. O JSON de efeitos já aceita um campo `modificadores` por efeito (usado em Compreender, Dano, Sentidos, Defesa Aumentada e Proteção), então o cadastro pode ser feito sem mudar o modelo.

## 4. Vantagens, perícias e características

| Item | Situação | Lacuna |
|---|---|---|
| Vantagens | Parcial | Catálogo completo: Velocidade do Pensamento incluída (V090), duplicadas V015 e V017 removidas, descrição pedida em Oponente Favorito, Tontear e Parceiro. Benefício, Ataque Preciso e Tontear continuam como uma entrada com descrição. Não é possível comprar a mesma vantagem duas vezes com descrições diferentes |
| Equipamento | OK | 5 pontos de equipamento por graduação, com validação |
| Idiomas | Parcial | Sem a progressão de idiomas por graduação |
| Bônus de vantagens na ficha | Parcial | Ataque Corpo-a-Corpo, Ataque à Distância, Rolamento Defensivo, Iniciativa Aprimorada e Velocidade do Pensamento entram nas contas (`Ficha.iniciativa`). Margem de crítico calculada (Perigoso; o Crítico Aprimorado entra quando for ligado a um ataque, ticket 3) |
| Perícias | OK | Campo `treinado` não é usado |
| Habilidades | OK | — |
| Defesas | Parcial | Sem marcar imunidade pela tela |
| Complicações | OK | Texto livre; sem tipos sugeridos |

## 5. Estruturas e regras globais

| Regra | Situação | Arquivo |
|---|---|---|
| Custo de efeito individual | OK | `lib_efeitos.dart:291` |
| Custo fracionário (1 ponto para N graduações) | OK | `lib_efeitos.dart:373-378` |
| Efeito alternativo: 1 ponto, limitado ao custo do primário | Ausente | `lib_pacoteEfeitos.dart:162` |
| Efeito alternativo dinâmico: 2 pontos | Ausente | idem |
| Efeitos ligados: soma dos custos | Ausente | idem |
| Removível: −1 por 5 pontos; Facilmente Removível: −2 por 5 | Ausente | idem |
| Equipamento: pago em pontos de equipamento | Ausente | idem |
| Total de PP gasto e disponível (15 por NP) | Ausente | — |
| Perícia ≤ NP + 10 | OK, sem exibição | `ficha.dart:200` |
| Esquiva + Resistência, Aparar + Resistência, Fortitude + Vontade ≤ 2 × NP | OK, sem exibição | `ficha.dart:125` |
| Ataque + graduação ≤ 2 × NP | Parcial | `ficha.dart:22` |
| Efeito sem teste de ataque (área, percepção) ≤ NP | Ausente | — |
| Defesa imune ou habilidade ausente nos pares de defesa | Ausente | — |
| Bônus de arranjo | OK (regra alterada em 2026-11-17) | Todos os efeitos do arranjo são ativos e somam o bônus; não há mais seleção de efeito ativo. Fichas antigas com `"active": false` são corrigidas em `ManipulaPoderes.ativarBonusInativos` (`ficha.dart`) |
| Arranjo dinâmico com marca por efeito | OK | `CustoPoderes._custoDinamico` (`lib_custos.dart`): maior + 1 se dinâmico, +2 por alternativo dinâmico, +1 por comum; sem a marca `dinamico` todos contam como dinâmicos |
| Importação de ficha do Poder Supremo (M&M 3ª) | OK | `lib/script/importacao/importa_poder_supremo.dart`; o que não tem equivalente vira Característica ou modificador Personalizado com o mesmo custo, com aviso |
| Interface sem estouro em celular (320×568 e 360×740) | OK | `theme.dart` e telas; verificado em `test/responsividade_test.dart` |
| Popups sobre a tela de origem, centralizados, com busca nos seletores | OK (2026-11-19) | `abrir_popup.dart`, `dropdown_com_busca.dart`; verificado em `test/popups_test.dart` (320×568, 360×740 e 1280×800) |

## 6. Dependências e ordem proposta

| Etapa | Entrega | Depende de | Situação em 2026-11-16 |
|---|---|---|---|
| 1 | Testes de caracterização do motor atual e correção dos defeitos que perdem dados (salvar, carregar, exclusões) | — | Feito |
| 2 | Fábrica única de efeitos (remove os 5 `switch`) e custo de pacotes: ligados, alternativos, dinâmicos, removível, equipamento | 1 | Feito (`lib_custos.dart`) |
| 3 | Total de PP da ficha e painel de validação de NP visível, com as regras faltantes | 2 | Parcial: total, orçamento de equipamento e painel feitos; faltam área/percepção e defesa imune |
| 4 | Catálogo: modificadores genéricos ausentes, correção dos suspeitos, opções de Movimento e Controle de Sorte | 2 | Parcial: genéricos feitos; suspeitos da seção 3.2 sem decisão (só o E036 foi removido); faltam as opções de Movimento e Controle de Sorte |
| 5 | Modificadores próprios e parâmetros por efeito (resistência, condições, alvo) | 4 | Pendente |
| 6 | Vantagens: subtipos, Equipamento, Idiomas, bônus na ficha | 3 | Parcial: catálogo, Equipamento e iniciativa feitos; faltam subtipos, compra repetida, Idiomas e Crítico Aprimorado |
| 7 | Persistência local e salvamento automático de uma única ficha (sem lista de personagens, por decisão de 2026-11-16) | 1 | Feito (`armazenamento.dart`); sem persistência no navegador |
| 8 | PDF completo e consulta de regras | 3, 5 | Parcial: PDF no formato do modelo (Alquimista.docx, Prodigio.docx), com visual "ficha preta" desde 2026-11-17; falta a consulta de regras |
| 9 | Catálogos de equipamento (armas, armaduras, veículos, quartéis-generais) | 8 | Pendente, sem prioridade |
| 10 | Importação de fichas do Poder Supremo (RF015) | 2, 6 | Feito em 2026-11-17. Pendências: Perícia Aumentada (custo 0,5) e poderes internos de veículo/quartel-general entram só como custo |
| 11 | Interface para celular (RF016) | — | Feito em 2026-11-17 (tema, `SafeArea`, grades com altura fixa, testes de estouro de layout) |
| 12 | Modificadores próprios de Mover Objetos e Teleporte; copiar e colar poderes (RF017) | 4 | Feito em 2026-11-17 (`efeitos.json`, `lib_areaCopia.dart`) |
| 13 | Popups: tela de origem visível, caixas centralizadas, busca nos seletores | 11 | Feito em 2026-11-19 (`abrir_popup.dart`, `dropdown_com_busca.dart`) |

Compatibilidade com fichas salvas: as etapas acrescentam campos opcionais ao JSON (ex.: `dinamico` nos efeitos de arranjo). Exceção de 2026-11-17: a chave `active` deixou de ser gravada em `PacotesEfeitos` e passou a ser ignorada em `EfeitoBonus`. Fichas antigas continuam abrindo; os bônus que estavam desligados passam a valer.
