# Funções

Esta pasta reúne as funções utilizadas nos scripts do projeto para obtenção e preparação de perfis de terreno, identificação e filtragem de gumes, cálculo de perdas por difração e representação gráfica dos modelos implementados.

Os principais métodos de difração considerados são Epstein-Peterson, Deygout e Giovaneli.

## Aquisição e preparação dos dados

- `consultaindividualgoogle.m` — realiza a consulta de um ponto individual à Google Elevation API, retornando elevação e resolução.

- `dadoselevgoogle.m` — obtém um perfil de elevação entre transmissor e receptor utilizando a Google Elevation API.

- `dadoselevmatlab.m` — obtém um perfil de elevação utilizando os recursos de elevação disponíveis no MATLAB.

- `dadoselevresolucao.m` — consulta individualmente os pontos de um enlace na Google Elevation API e armazena também a resolução informada para cada ponto.

- `raioefetivo.m` — aplica ao perfil de elevação a correção associada ao modelo de raio efetivo da Terra.

## Identificação e filtragem de gumes

- `indexgumess.m` — identifica os gumes presentes no perfil de terreno. A verificação da zona de Fresnel pode ser ativada ou desativada por parâmetro.

- `verificafresnel.m` — verifica a existência de obstruções em 60% da primeira zona de Fresnel e seleciona a obstrução de maior parâmetro `v`.

- `preparageometria.m` — calcula os parâmetros geométricos utilizados pelo processo de filtragem dos gumes, incluindo altura `h`, parâmetro `v`, ângulo e distância.

- `aplicafiltrodinamico.m` — aplica o filtro dinâmico aos gumes identificados considerando os limites definidos para `h`, `v`, diferença angular e distância.

- `filtragumes.m` — implementação anterior do processo de filtragem de gumes, mantida para compatibilidade com testes realizados durante o desenvolvimento.

## Modelos de difração

### Epstein-Peterson

- `perdaepstein.m` — calcula a perda por difração utilizando o método de Epstein-Peterson.

### Deygout

- `perdadeygout.m` — calcula a perda por difração utilizando o método recursivo de Deygout. Os gumes principais são selecionados a partir do parâmetro `v`, e a perda individual é calculada pela função `fresnel.m`.

- `perdadeygoutdavis.m` — implementação alternativa relacionada à correção de Causebrook e Davis, utilizada durante etapas de desenvolvimento e avaliação do projeto.

### Giovaneli

- `perdagiovaneli.m` — calcula a perda por difração utilizando o método de Giovaneli.

- `recursaogiovaneli.m` — executa o processo recursivo utilizado pelo método de Giovaneli.

- `calculagume.m` — calcula a contribuição de perda associada a um determinado gume.

- `pontoefetivotx.m` — determina o ponto efetivo do lado do transmissor utilizado na geometria do método de Giovaneli.

- `pontoefetivorx.m` — determina o ponto efetivo do lado do receptor utilizado na geometria do método de Giovaneli.

## Funções geométricas auxiliares

- `txrx.m` — calcula a distância tridimensional entre dois pontos do perfil considerando a distância geográfica e a diferença de altura.

- `valorcos.m` — calcula a altura perpendicular e as distâncias projetadas utilizadas na geometria dos modelos de difração.

- `checarh.m` — determina o sinal da altura de um obstáculo em relação à linha de referência entre dois pontos.

- `fresnel.m` — calcula o parâmetro de Fresnel-Kirchhoff e a perda por difração correspondente utilizando as aproximações adotadas no projeto.

## Representação gráfica

- `desenhaepstein.m` — representa graficamente a geometria utilizada pelo método de Epstein-Peterson.

- `desenhadeygout.m` — apresenta uma representação simplificada da geometria do método de Deygout, destacando o gume principal e os principais gumes à esquerda e à direita.

- `desenhagiovaneli.m` — representa graficamente a geometria utilizada pelo método de Giovaneli.

- `desenhagumes.m` — destaca graficamente os gumes identificados no perfil.

- `desenharecursaogio.m` — realiza a representação das etapas recursivas da geometria de Giovaneli.

- `desenhatriogio.m` — desenha a geometria elementar formada pelos pontos utilizados durante as etapas do método de Giovaneli.

## Código de terceiros

### `getElevationsPath.m`

A função `getElevationsPath.m` é baseada no projeto **Matlab-Google-Elevation-API**, disponibilizado por José Rosa (`pinxau1000`):

https://github.com/pinxau1000/Matlab-Google-Elevation-API

O código original é distribuído sob a licença MIT e deriva do trabalho anterior `GetElevation`, de Jarek Tuszynski.

Na versão utilizada neste projeto, foi realizada a substituição da função obsoleta `urlread` por `webread`, mantendo a finalidade original da implementação.

Os arquivos de licença e atribuição correspondentes ao código de terceiros devem ser preservados juntamente com o projeto.

## Dependências

Algumas funções utilizam recursos específicos do MATLAB, incluindo:

- `wgs84Ellipsoid`
- `distance`
- `txsite`
- `elevation`
- `webread`

A disponibilidade dessas funções depende da versão do MATLAB e dos produtos instalados.

As funções que utilizam a Google Elevation API recebem a chave da API por meio do parâmetro `API_KEY`. Nenhuma chave de API deve ser armazenada diretamente nos arquivos disponibilizados no repositório.

## Organização

As funções desta pasta são utilizadas pelos scripts de desenvolvimento, testes e validação do projeto.

Algumas implementações foram mantidas por terem sido utilizadas em etapas específicas do desenvolvimento. Arquivos antigos, duplicados ou que não possuem relação com os resultados apresentados no trabalho devem ser mantidos fora desta pasta principal ou removidos antes da publicação definitiva do repositório.

## Uso de assistência de IA

Este README e os comentários presentes nos códigos foram adicionados ou revisados com auxílio de inteligência artificial, com o objetivo de melhorar a organização, clareza e documentação do projeto.

A lógica, os métodos, os parâmetros e as decisões de implementação do código permaneceram sob responsabilidade do autor do projeto.