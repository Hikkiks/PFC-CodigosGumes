# App Design

Esta pasta contém o aplicativo desenvolvido para análise de enlaces de rádio com múltiplos gumes de faca.

O aplicativo permite definir as posições e características das antenas, obter o perfil de elevação do caminho, identificar e filtrar os gumes e calcular as perdas pelos métodos de Epstein-Peterson, Deygout e Giovaneli.

## Estrutura

```text
App Design/
├── DadosSalvos/
├── FunçõesApp/
├── Imagens/
├── PathLoss.mlapp
└── READMEApp.md
```

- `PathLoss.mlapp` — Aplicativo principal desenvolvido no MATLAB App Designer;
- `FunçõesApp` — Funções utilizadas pelo aplicativo;
- `DadosSalvos` — Dados utilizados durante a execução do aplicativo;
- `Imagens` — Ícones utilizados na interface e no mapa.

## Funções do aplicativo

As funções presentes em `FunçõesApp` são baseadas nas funções já documentadas na pasta `Scripts/Funções`.

Algumas delas foram adaptadas para utilização no MATLAB App Designer, principalmente para permitir a representação dos resultados diretamente nos eixos gráficos da interface.

A descrição individual dos métodos e das funções permanece concentrada na documentação da pasta `Scripts`, evitando duplicação de informações.

## Perfil de elevação

O perfil de elevação entre as antenas é obtido por meio da Google Elevation API.

A chave da API não é armazenada no código e deve ser definida por meio da variável de ambiente:

```matlab
setenv('GOOGLE_ELEVATION_API_KEY','SUA_CHAVE_AQUI')
```

Após a obtenção do perfil, é aplicada a correção correspondente ao raio efetivo da Terra.

## Funcionalidades principais

O aplicativo permite:

- Selecionar as posições das antenas diretamente no mapa;
- Inserir manualmente as coordenadas;
- Alterar alturas, frequência e ganhos das antenas;
- Obter o perfil de elevação do enlace;
- Visualizar a linha de visada e os gumes identificados;
- Ativar ou desativar a verificação da zona de Fresnel;
- Ajustar os filtros de altura, parâmetro `v` e limite angular;
- Carregar perfis previamente salvos;
- Calcular as perdas pelos métodos de Epstein-Peterson, Deygout e Giovaneli;
- Visualizar graficamente a geometria utilizada pelos modelos.

No aplicativo, o parâmetro de distância do filtro permanece sem limite.

## Execução

1. Defina a variável de ambiente `GOOGLE_ELEVATION_API_KEY`.
2. Abra `PathLoss.mlapp` no MATLAB.
3. Execute o aplicativo.
4. Defina as posições das antenas.
5. Obtenha o perfil de elevação.
6. Ajuste os parâmetros desejados.
7. Selecione um dos modelos de difração.

## Uso de assistência de IA

Este README e os comentários presentes nos códigos foram adicionados ou revisados com auxílio de inteligência artificial, com o objetivo de melhorar a organização, clareza e documentação do projeto.

A lógica, os métodos, os parâmetros e as decisões de implementação do código permaneceram sob responsabilidade do autor do projeto.