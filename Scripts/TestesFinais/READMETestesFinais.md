# Testes Finais

Esta pasta reúne as etapas finais de preparação, calibração por varredura, seleção e avaliação dos filtros de gumes, além das verificações complementares realizadas com dados da NTIA.

A pasta contém 18 scripts MATLAB.

## Fluxo principal

```text
Dados de entrada
        ↓
Preparação
        ↓
Varredura dos filtros
        ↓
Análise das tendências e seleção
        ↓
Avaliação das configurações escolhidas
```

As etapas de preparação armazenam cálculos que permanecem constantes durante as varreduras, evitando a repetição de operações para cada configuração avaliada.

## Preparação e varredura

| Script | Finalidade |
|---|---|
| `PreparacaoVarredura85.m` | Prepara os 85 perfis para a varredura principal. |
| `VarreduraFinalFiltros85.m` | Executa a varredura dos filtros nos 85 casos e calcula as métricas de análise. |
| `PreparacaoVarredura12Casos.m` | Prepara os 12 casos medidos em campo. |
| `VarreduraFinalFiltros12Casos.m` | Executa a grade de filtros nos 12 casos e gera os rankings utilizados na seleção. |

A grade final combina:

```text
46 valores de h
18 valores de v
17 valores de ângulo
15 valores de distância

Total: 211.140 configurações
```

## Análises dos 85 casos

| Script | Finalidade |
|---|---|
| `TesteTendenciaMAE85.m` | Analisa a tendência do MAE em função dos parâmetros do filtro. |
| `TesteTendenciaGumes85.m` | Analisa a influência dos parâmetros sobre a quantidade de gumes. |
| `TesteFiltrosSelecionados85.m` | Compara as quatro configurações selecionadas. |
| `TesteComparacao85GumesIguais.m` | Analisa os casos com a mesma quantidade de gumes da referência de Lorenço. |
| `TesteDeygoutDavis85.m` | Compara o Deygout convencional com a correção de Causebrook e Davis. |

Configurações selecionadas:

```text
206554
203964
200330
206074
```

## Análise dos 12 casos medidos em campo

| Script | Finalidade |
|---|---|
| `TesteFinalSemFiltro.m` | Analisa os 12 casos antes da aplicação dos filtros. |
| `TesteComparacao5Configuracoes12Casos.m` | Compara as quatro configurações dos 85 casos com a configuração selecionada nos 12 casos. |
| `TesteAnaliseRegiao67399.m` | Analisa a região ao redor da configuração 67399. |
| `TesteTendenciaFiltros12Casos.m` | Analisa as tendências de erro e quantidade de gumes. |

A configuração selecionada especificamente nos 12 casos foi:

```text
Configuração 67399

h = 0.25 m
v = 0.09
ângulo = 0.75°
distância = 100 m
```

Como os próprios 12 casos foram utilizados em sua seleção, esse resultado não constitui uma validação independente do filtro.

### Ranking equilibrado

A configuração 67399 foi selecionada pelo ranking implementado em `VarreduraFinalFiltros12Casos.m`:

```text
RankEquilibrado = (RankMedido + RankLorenco + RankGumes) / 3
```

Os rankings consideram métricas de erro em relação aos valores medidos e aos resultados de Lorenço, além da correspondência na quantidade de gumes.

## Verificação complementar com a NTIA

Essa etapa utiliza apenas o processo base do software, sem aplicação dos filtros desenvolvidos e sem ajuste de parâmetros para aproximação dos valores da NTIA.

| Script | Finalidade |
|---|---|
| `GerarRelevosNTIA50.m` | Gera os 50 cenários sintéticos utilizados na comparação com Vogler. |
| `TesteVerificacaoNTIA50.m` | Realiza a análise dos 50 cenários sintéticos. |
| `TesteVerificacaoNTIA50Software.m` | Complementa a verificação utilizando o processo base do software. |
| `GerarRelevosNTIA63Google.m` | Reconstrói os trajetos da 63rd Street utilizando a Google Elevation API. |
| `TesteVerificacaoNTIAReais.m` | Compara os resultados da 63rd Street com os dados medidos da NTIA. |

As análises utilizam `indexgumess(...,false)` e as funções originais `perdaepstein`, `perdadeygout` e `perdagiovaneli`.

Os resultados da NTIA são tratados como verificação complementar de consistência, e não como uma nova validação do software.

## Resultados das varreduras

As principais saídas são armazenadas em:

```text
ResultadosVarredura85/
ResultadosVarredura12Casos/
```

Arquivos `.csv`, `.mat` e imagens derivados das análises podem ser regenerados executando novamente os respectivos scripts e não precisam ser armazenados como código-fonte do projeto.

## Ordem de execução

### 85 casos

```text
PreparacaoVarredura85.m
        ↓
VarreduraFinalFiltros85.m
        ↓
Testes de tendência e seleção
        ↓
TesteFiltrosSelecionados85.m
```

### 12 casos

```text
PreparacaoVarredura12Casos.m
        ↓
VarreduraFinalFiltros12Casos.m
        ↓
Testes de tendência e região
        ↓
TesteComparacao5Configuracoes12Casos.m
```

### NTIA

```text
GerarRelevosNTIA50.m
        ↓
Testes de verificação dos 50 casos

GerarRelevosNTIA63Google.m
        ↓
TesteVerificacaoNTIAReais.m
```

## Dependências

Os scripts utilizam principalmente:

- `../Funções`;
- `../DadosSalvos/DadosConclusao`;
- `../DadosSalvos/RelevosLorenco85`;
- `../dadoslorencocompleto.txt`.

## Uso de assistência de IA

Este README e os comentários dos códigos foram adicionados ou revisados com auxílio de inteligência artificial para melhorar a organização e a documentação.

O ChatGPT também foi utilizado como ferramenta auxiliar na triagem dos resultados da varredura dos 85 casos. As configurações sugeridas foram posteriormente verificadas diretamente a partir dos resultados gerados no MATLAB.

A lógica, os métodos, os parâmetros, a interpretação dos resultados e as decisões finais permaneceram sob responsabilidade do autor.