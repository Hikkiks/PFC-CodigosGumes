# Testes de Refinamento

Esta pasta reúne os testes utilizados para investigar e refinar etapas específicas do projeto após as validações iniciais. As análises incluem resolução e amostragem dos perfis de relevo, geometria dos gumes, influência do espaçamento entre amostras, verificação da zona de Fresnel e inspeção dos resultados da varredura de filtros.

A pasta contém 11 scripts MATLAB, totalizando 3.173 linhas de código.

## Testes disponíveis

### Perfis de relevo e amostragem

| Script | Finalidade |
|---|---|
| `GerarRelevosLorenco85.m` | Gera os 85 perfis de relevo utilizados nas comparações finais por meio da Google Elevation API. |
| `TesteConsultaIndividualGoogleE2P1.m` | Compara o perfil salvo de E2-P1 com consultas individuais realizadas nas mesmas coordenadas. |
| `TesteMicroperfilGoogleE2P6.m` | Analisa um trecho de E2-P6 com maior densidade de pontos para investigar variações locais do relevo. |
| `TesteQuantidadeAmostrasMATLAB12.m` | Compara a identificação de gumes nos 12 enlaces utilizando diferentes quantidades de amostras. |
| `TesteResolucaoGoogleAPI.m` | Analisa a resolução informada pela Google Elevation API nos enlaces E2-P1 e E2-P6. |
| `TesteEspacamentos12Casos.m` | Reamostra os 12 perfis com diferentes espaçamentos físicos e compara a quantidade de gumes encontrada. |

### Geometria e Fresnel

| Script | Finalidade |
|---|---|
| `TesteAnaliseGeometriaGumes12.m` | Analisa características geométricas dos gumes dos 12 casos, incluindo distância, ângulo, `h` e `v`. |
| `TesteValidacaoVerificaFresnel85.m` | Valida a função `verificafresnel` nos 85 perfis por meio de uma verificação geométrica independente. |

`TesteAnaliseGeometriaGumes12.m` corresponde a uma investigação preliminar do comportamento geométrico dos obstáculos e não representa, isoladamente, a definição dos critérios finais do filtro.

### Validação dos dados e da varredura

| Script | Finalidade |
|---|---|
| `TesteValidacaoRelevos85.m` | Verifica a integridade e a consistência dos 85 perfis utilizados nas etapas finais. |
| `TesteAnalisePioresCasos85.m` | Investiga os maiores erros encontrados nas quatro configurações selecionadas da varredura dos 85 casos. |
| `TesteVerificacaoVarredura85.m` | Confere os efeitos das quatro configurações selecionadas sobre os gumes e os resultados de Giovaneli. |

## Geração dos 85 perfis

`GerarRelevosLorenco85.m` utiliza a coordenada da transmissora e as coordenadas dos receptores presentes em `dadoslorencocompleto.txt` para gerar os 85 perfis com 512 amostras.

Os arquivos são armazenados em:

```text
DadosSalvos/RelevosLorenco85/
```

seguindo a nomenclatura:

```text
DadosElevLorenco1.mat
DadosElevLorenco2.mat
...
DadosElevLorenco85.mat
```

A numeração deve permanecer associada à ordem dos registros de `dadoslorencocompleto.txt`.

## Organização dos perfis

Os arquivos `.mat` de relevo utilizam a variável `dadoselev`, organizada como uma matriz `3 × n`:

| Índice | Conteúdo |
|---|---|
| `dadoselev(1,:)` | Latitude |
| `dadoselev(2,:)` | Longitude |
| `dadoselev(3,:)` | Elevação do terreno, em metros |

Cada coluna representa uma amostra ao longo do enlace.

```matlab
latitude=dadoselev(1,:);
longitude=dadoselev(2,:);
elevacao=dadoselev(3,:);
```

O primeiro e o último pontos correspondem, respectivamente, às extremidades transmissora e receptora:

```matlab
dadoselev(:,1)
dadoselev(:,end)
```

As alturas das antenas são fornecidas separadamente durante os cálculos e não fazem parte diretamente de `dadoselev(3,:)`.

## Dados utilizados

### `DadosSalvos/DadosConclusao`

Contém os 12 perfis associados às duas emissoras e aos seis pontos receptores:

```text
DadosConclusaoE1P1.mat ... DadosConclusaoE1P6.mat
DadosConclusaoE2P1.mat ... DadosConclusaoE2P6.mat
```

Esses perfis são utilizados principalmente nos testes de geometria, resolução, amostragem e espaçamento.

### `DadosSalvos/RelevosLorenco85`

Contém os 85 perfis utilizados nas comparações com os resultados disponibilizados por Lorenço e nas validações realizadas antes das etapas finais.

### `dadoslorencocompleto.txt`

Cada linha corresponde a um dos 85 casos e contém:

| Coluna | Conteúdo |
|---|---|
| 1 | Latitude do receptor |
| 2 | Longitude do receptor |
| 3 | Resultado de Epstein-Peterson |
| 4 | Resultado de Deygout |
| 5 | Resultado de Giovaneli |
| 6 | Quantidade de gumes |

O arquivo é lido com:

```matlab
dados=textscan(arquivo,'%s %s %s %s %s %f');
```

Os valores armazenados como texto são convertidos para valores numéricos após a substituição da vírgula decimal por ponto quando necessário.

A linha correspondente ao caso `i` está associada ao perfil:

```text
DadosSalvos/RelevosLorenco85/DadosElevLorenco<i>.mat
```

## Google Elevation API

Alguns testes realizam consultas à Google Elevation API para geração ou investigação dos perfis.

A chave da API não é armazenada no código. Ela é obtida pela variável de ambiente:

```matlab
API_KEY=getenv('GOOGLE_ELEVATION_API_KEY');
```

Durante uma sessão do MATLAB, ela pode ser definida com:

```matlab
setenv('GOOGLE_ELEVATION_API_KEY','SUA_CHAVE_AQUI')
```

Os principais scripts que realizam consultas à API são:

- `GerarRelevosLorenco85.m`;
- `TesteConsultaIndividualGoogleE2P1.m`;
- `TesteMicroperfilGoogleE2P6.m`;
- `TesteResolucaoGoogleAPI.m`.

A execução desses arquivos pode consumir a cota disponível da API.

## Verificação da varredura final

`TesteAnalisePioresCasos85.m` e `TesteVerificacaoVarredura85.m` analisam as quatro configurações selecionadas após a varredura dos 85 perfis:

```text
206554
203964
200330
206074
```

Esses testes utilizam diretamente os arquivos gerados pela preparação e pela varredura final:

```text
TestesFinais/ResultadosVarredura85/PreparacaoVarredura85.mat
TestesFinais/ResultadosVarredura85/VarreduraFinalFiltros85.mat
```

`TesteAnalisePioresCasos85.m` identifica os maiores erros individuais, compara os casos extremos entre as quatro configurações e gera um ranking dos perfis mais problemáticos.

`TesteVerificacaoVarredura85.m` compara os resultados filtrados com a condição original e confere novamente métricas como erro médio, MAE, RMSE, casos alterados e quantidade de gumes removidos.

## Resultados gerados

Alguns testes produzem arquivos `.csv`, `.mat` ou imagens para auxiliar a análise.

Entre as pastas de resultados estão:

```text
ResultadosAnaliseGeometria12Casos/
ResultadosAnalisePioresCasos85/
ResultadosTesteVerificaFresnel85/
ResultadosValidacaoRelevos85/
```

Esses arquivos são resultados derivados e podem ser reproduzidos executando novamente os respectivos scripts, não sendo necessários como arquivos-fonte do projeto.

## Dependências e execução

Os testes utilizam principalmente:

- `../Funções`;
- `../DadosSalvos/DadosConclusao`;
- `../DadosSalvos/RelevosLorenco85`;
- `../dadoslorencocompleto.txt`;
- `../TestesFinais/ResultadosVarredura85`, nos testes relacionados à varredura;
- Google Elevation API, quando novas consultas são necessárias.

A maioria dos testes pode ser executada independentemente.

Caso `RelevosLorenco85` ainda não exista, `GerarRelevosLorenco85.m` deve ser executado antes dos testes que utilizam essa base.

Os testes `TesteAnalisePioresCasos85.m` e `TesteVerificacaoVarredura85.m` dependem da execução prévia das etapas de preparação e varredura dos 85 casos presentes em `TestesFinais`.

## Uso de assistência de IA

Este README e os comentários presentes nos códigos foram adicionados ou revisados com auxílio de inteligência artificial, com o objetivo de melhorar a organização, clareza e documentação do projeto.

A lógica, os métodos, os parâmetros e as decisões de implementação do código permaneceram sob responsabilidade do autor do projeto.