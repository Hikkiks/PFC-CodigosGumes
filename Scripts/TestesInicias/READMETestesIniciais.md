# Testes Iniciais

Esta pasta reúne os testes utilizados durante as etapas iniciais de desenvolvimento e validação do projeto. Eles verificam a obtenção e o tratamento dos perfis de relevo, a identificação dos gumes, a consideração das zonas de Fresnel, os cálculos geométricos e os três modelos de difração implementados.

A pasta contém 14 scripts MATLAB, totalizando 2.121 linhas de código.

## Testes disponíveis

### Relevo e geometria

| Script | Finalidade |
|---|---|
| `TestesElevacoes.m` | Compara os perfis obtidos pela Google Elevation API e pelo MATLAB. |
| `TesteCurvaturaTerra.m` | Compara o perfil original com o perfil após a correção do raio efetivo da Terra. |
| `TestesDistancias.m` | Verifica a influência da representação das distâncias na identificação dos gumes nos 12 casos. |
| `TesteValidacaoCalculoH85.m` | Valida o cálculo da altura relativa `h` utilizada nas geometrias de difração nos 85 perfis. |

### Identificação de gumes e Fresnel

| Script | Finalidade |
|---|---|
| `TesteIndexgumess.m` | Testa visualmente a identificação dos gumes em um perfil de desenvolvimento. |
| `TesteGumesCasoIndividual.m` | Permite analisar individualmente a identificação de gumes em um dos 12 casos de campo. |
| `TesteComparacaoAlgoritmosGumes.m` | Compara `indexgumess` com o algoritmo `traca_caminho` utilizado por Lorenço. |
| `TesteComparacaoComSemFresnel.m` | Compara a identificação de gumes com e sem a verificação adicional da zona de Fresnel. |

### Modelos de difração

| Script | Finalidade |
|---|---|
| `TesteEpstein.m` | Testa o cálculo e a representação do modelo de Epstein-Peterson. |
| `TesteDeygout.m` | Testa o cálculo e a representação do modelo de Deygout. |
| `TesteGiovaneli.m` | Testa o cálculo e a representação do modelo de Giovaneli. |
| `TestePerdaComparacao.m` | Compara os três modelos utilizando o mesmo perfil e conjunto de gumes. |

### Comparações com Lorenço

| Script | Finalidade |
|---|---|
| `TesteComparacao85SemFiltro.m` | Compara os três modelos e a quantidade de gumes com os resultados de Lorenço nos 85 perfis, sem aplicação de filtros. |
| `TesteComparacaoElevacoes85.m` | Analisa os casos em que a quantidade de gumes identificada é igual à registrada por Lorenço. |

Neste último teste, a igualdade se refere à **quantidade de gumes**, não necessariamente aos mesmos índices ou posições.

## Organização dos dados

### Perfis de relevo

Os perfis armazenados nos arquivos `.mat` utilizam a variável `dadoselev`, organizada como uma matriz `3 × n`:

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

O primeiro e o último pontos representam, respectivamente, as extremidades transmissora e receptora:

```matlab
dadoselev(:,1)
dadoselev(:,end)
```

As alturas das antenas não fazem parte diretamente de `dadoselev(3,:)` e são adicionadas separadamente quando necessárias.

As distâncias entre as amostras também não são armazenadas na matriz. Quando utilizadas, são calculadas a partir das coordenadas geográficas.

### `DadosSalvos/DadosFab`

Contém perfis preparados ou fabricados durante o desenvolvimento, utilizados principalmente nos testes individuais das funções e dos modelos.

### `DadosSalvos/DadosConclusao`

Contém os 12 perfis associados aos dois transmissores e aos seis pontos receptores:

```text
DadosConclusaoE1P1.mat ... DadosConclusaoE1P6.mat
DadosConclusaoE2P1.mat ... DadosConclusaoE2P6.mat
```

### `DadosSalvos/RelevosLorenco85`

Contém os 85 perfis utilizados nas comparações com os resultados de Lorenço:

```text
DadosElevLorenco1.mat
DadosElevLorenco2.mat
...
DadosElevLorenco85.mat
```

A numeração deve permanecer associada à ordem dos registros de `dadoslorencocompleto.txt`.

## Formato de `dadoslorencocompleto.txt`

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

Os resultados dos modelos são convertidos para valores numéricos após a substituição da vírgula decimal por ponto:

```matlab
epsteinlorenco=str2double(strrep(dados{3},',','.'));
deygoutlorenco=str2double(strrep(dados{4},',','.'));
giovanelilorenco=str2double(strrep(dados{5},',','.'));
gumeslorenco=dados{6};
```

A linha `i` desse arquivo corresponde ao perfil:

```text
DadosSalvos/RelevosLorenco85/DadosElevLorenco<i>.mat
```

## Dependências

Os testes utilizam principalmente:

- `../Funções`;
- `../DadosSalvos/DadosFab`;
- `../DadosSalvos/DadosConclusao`;
- `../DadosSalvos/RelevosLorenco85`;
- `../dadoslorencocompleto.txt`;
- `../Terceiros`, quando necessário.

Os testes são, em geral, independentes e não possuem uma ordem obrigatória de execução.

## Uso de assistência de IA

Este README e os comentários presentes nos códigos foram adicionados ou revisados com auxílio de inteligência artificial, com o objetivo de melhorar a organização, clareza e documentação do projeto.

A lógica, os métodos, os parâmetros e as decisões de implementação do código permaneceram sob responsabilidade do autor do projeto.