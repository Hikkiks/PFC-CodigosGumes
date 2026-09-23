# Testes Finais

Esta pasta reúne as etapas finais de preparação, varredura, seleção e validação dos filtros de gumes utilizados no projeto.

A pasta contém 13 scripts MATLAB, totalizando 5.411 linhas de código.

## Fluxo principal

Os testes finais seguem, de forma geral, o fluxo:

```text
Dados de entrada
        ↓
Preparação
        ↓
Varredura dos filtros
        ↓
Análise das tendências e seleção
        ↓
Validação das configurações escolhidas
```

As etapas de preparação armazenam cálculos que permanecem constantes durante as varreduras, evitando repetir operações como carregamento dos perfis, correção do relevo, identificação original dos gumes e preparação das geometrias para cada configuração avaliada.

## Preparação e varredura

| Script | Finalidade |
|---|---|
| `PreparacaoVarredura85.m` | Prepara os 85 perfis e os dados necessários para a varredura principal. |
| `VarreduraFinalFiltros85.m` | Executa a varredura dos filtros sobre os 85 casos e calcula as métricas utilizadas na análise das configurações. |
| `PreparacaoVarredura12Casos.m` | Prepara os 12 casos de campo, incluindo as condições com e sem a verificação adicional de Fresnel. |
| `VarreduraFinalFiltros12Casos.m` | Executa a mesma grade de filtros nos 12 casos, tanto sem Fresnel quanto com Fresnel. |

A grade final contém combinações de quatro parâmetros:

- limite de `h`;
- limite de `v`;
- limite angular;
- limite de distância.

São avaliadas:

```text
46 valores de h
18 valores de v
17 valores de ângulo
15 valores de distância
```

totalizando:

```text
211.140 configurações
```

## Análises dos 85 casos

| Script | Finalidade |
|---|---|
| `TesteTendenciaMAE85.m` | Analisa a tendência do MAE em função de `h`, `v` e limite angular nas configurações sem limite de distância. |
| `TesteTendenciaGumes85.m` | Analisa a influência desses parâmetros sobre a quantidade de gumes mantidos. |
| `TesteFiltrosSelecionados85.m` | Reexecuta e compara as quatro configurações selecionadas nos 85 perfis. |
| `TesteComparacao85GumesIguais.m` | Avalia separadamente os casos em que a quantidade de gumes identificada coincide com a referência de Lorenço. |
| `TesteDeygoutDavis85.m` | Compara o Deygout convencional com a correção de Causebrook e Davis nos 85 casos. |

As quatro configurações selecionadas na análise dos 85 casos são:

```text
206554
203964
200330
206074
```

## Validação nos 12 casos

| Script | Finalidade |
|---|---|
| `TesteFinalSemFiltro.m` | Estabelece a condição de referência dos 12 casos antes da aplicação dos filtros. |
| `TesteComparacao5Configuracoes12Casos.m` | Compara as quatro configurações selecionadas nos 85 casos com a configuração selecionada especificamente nos 12 casos. |
| `TesteAnaliseRegiao67399.m` | Analisa a região de parâmetros ao redor da configuração 67399 e sua versão equivalente sem limite de distância. |
| `TesteTendenciaFiltros12Casos.m` | Analisa as tendências de MAE e quantidade de gumes em função dos parâmetros do filtro nos 12 casos. |

A quinta configuração utilizada nessa comparação é:

```text
Configuração 67399

h = 0.25 m
v = 0.09
ângulo = 0.75°
distância = 100 m
```

Essa configuração foi selecionada a partir da análise específica dos 12 casos e é comparada com as quatro configurações provenientes da varredura dos 85 perfis.

## Resultados das varreduras

As etapas principais utilizam as pastas:

```text
ResultadosVarredura85/
ResultadosVarredura12Casos/
```

Entre os arquivos utilizados pelas análises posteriores estão:

```text
ResultadosVarredura85/
├── PreparacaoVarredura85.mat
├── VarreduraFinalFiltros85.mat
└── ResumoTodasConfiguracoes.csv
```

e:

```text
ResultadosVarredura12Casos/
├── PreparacaoVarredura12Casos.mat
├── ResumoVarredura12CasosSemFresnel.csv
└── ResumoVarredura12CasosComFresnel.csv
```

Outros arquivos `.csv`, `.mat` e imagens produzidos pelos testes são resultados derivados e podem ser regenerados executando novamente os respectivos scripts.

Essas saídas não são necessárias como código-fonte do projeto e não precisam ser armazenadas no repositório.

## Ordem de execução

Para reproduzir as varreduras principais dos 85 casos:

```text
PreparacaoVarredura85.m
        ↓
VarreduraFinalFiltros85.m
        ↓
Testes de tendência e seleção
        ↓
TesteFiltrosSelecionados85.m
```

Para os 12 casos:

```text
PreparacaoVarredura12Casos.m
        ↓
VarreduraFinalFiltros12Casos.m
        ↓
TesteAnaliseRegiao67399.m
TesteTendenciaFiltros12Casos.m
        ↓
TesteComparacao5Configuracoes12Casos.m
```

`TesteFinalSemFiltro.m`, `TesteComparacao85GumesIguais.m` e `TesteDeygoutDavis85.m` correspondem a verificações específicas e podem ser executados separadamente quando seus dados de entrada estiverem disponíveis.

## Dependências

Os scripts utilizam principalmente:

- `../Funções`;
- `../DadosSalvos/DadosConclusao`;
- `../DadosSalvos/RelevosLorenco85`;
- `../dadoslorencocompleto.txt`.

As análises posteriores às varreduras dependem também dos arquivos gerados em `ResultadosVarredura85` ou `ResultadosVarredura12Casos`.

## Uso de assistência de IA

Este README e os comentários presentes nos códigos foram adicionados ou revisados com auxílio de inteligência artificial, com o objetivo de melhorar a organização, clareza e documentação do projeto.

A lógica, os métodos, os parâmetros e as decisões de implementação do código permaneceram sob responsabilidade do autor do projeto.