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

- `PathLoss.mlapp` — aplicativo principal desenvolvido no MATLAB App Designer;
- `FunçõesApp` — funções utilizadas pelo aplicativo;
- `DadosSalvos` — dados utilizados durante a execução do aplicativo;
- `Imagens` — ícones utilizados na interface e no mapa.

## Funções do aplicativo

As funções presentes em `FunçõesApp` são baseadas nas funções documentadas em `Scripts/Funções`.

Algumas foram adaptadas para utilização no MATLAB App Designer, principalmente para permitir a representação dos resultados diretamente nos eixos gráficos da interface.

A descrição dos métodos e das funções permanece concentrada na documentação da pasta `Scripts`, evitando duplicação de informações.

## Perfil de elevação

O perfil de elevação entre as antenas pode ser obtido por meio da Google Elevation API ou pelos recursos de elevação disponíveis no MATLAB.

Para utilizar a Google Elevation API, a chave deve ser definida por meio da variável de ambiente:

```matlab
setenv('GOOGLE_ELEVATION_API_KEY','SUA_CHAVE_AQUI')
```

A chave da API não é armazenada no código.

Após a obtenção do perfil, pode ser aplicada a correção correspondente ao raio efetivo da Terra.

## Funcionalidades principais

O aplicativo permite:

- selecionar as posições das antenas diretamente no mapa;
- inserir manualmente as coordenadas;
- alterar alturas, frequência e ganhos das antenas;
- obter ou carregar o perfil de elevação do enlace;
- visualizar a linha de visada e os gumes identificados;
- ativar ou desativar a verificação da zona de Fresnel;
- ajustar os filtros de altura, parâmetro `v`, limite angular e distância;
- calcular as perdas pelos métodos de Epstein-Peterson, Deygout e Giovaneli;
- visualizar graficamente a geometria utilizada pelos modelos.

## Execução

1. Caso seja utilizada a Google Elevation API, defina a variável de ambiente `GOOGLE_ELEVATION_API_KEY`.
2. Abra `PathLoss.mlapp` no MATLAB.
3. Execute o aplicativo.
4. Defina as posições das antenas ou carregue um perfil salvo.
5. Obtenha e prepare o perfil de elevação.
6. Ajuste os parâmetros desejados.
7. Selecione um dos modelos de difração.

## Uso de assistência de IA

Este README e os comentários presentes nos códigos foram adicionados ou revisados com auxílio de inteligência artificial, com o objetivo de melhorar a organização, clareza e documentação do projeto.

A lógica, os métodos, os parâmetros e as decisões de implementação permaneceram sob responsabilidade do autor do projeto.