# PFC - CódigosGumes

Este repositório reúne os códigos, dados, testes e o aplicativo desenvolvidos durante um Projeto Final de Curso (PFC/TCC) voltado ao estudo e à implementação de modelos de difração por múltiplos gumes de faca aplicados a enlaces de rádio.

O projeto inclui rotinas para obtenção e tratamento de perfis de elevação, identificação e filtragem de gumes, cálculo de perdas por difração e comparação entre diferentes métodos e referências.

## Sobre o projeto

O trabalho envolve a implementação dos métodos de Epstein-Peterson, Deygout e Giovaneli, além do desenvolvimento de ferramentas auxiliares para análise de perfis de relevo e seleção de gumes.

As implementações foram verificadas por meio de comparações com resultados de Lorenço e, complementarmente, com dados da NTIA. Também foram utilizados casos medidos em campo para análise das configurações de filtragem desenvolvidas.

A parte escrita do trabalho contém a fundamentação teórica, metodologia, desenvolvimento e análise detalhada dos resultados.

## Estrutura do repositório

```text
PFC-CodigosGumes/
├── App Design/
├── Scripts/
├── LICENSE
└── README.md
```

- `App Design` — aplicativo desenvolvido no MATLAB App Designer;
- `Scripts` — funções, dados e testes utilizados no desenvolvimento, verificação, calibração e avaliação do projeto;
- `LICENSE` — licença aplicável ao código desenvolvido pelo autor;
- `README.md` — documentação principal do repositório.

A documentação específica de cada etapa está disponível nos arquivos README presentes nas pastas internas.

## App Design

A pasta `App Design` contém o aplicativo desenvolvido para análise de enlaces de rádio.

O aplicativo permite definir as posições e características das antenas, obter perfis de elevação, identificar e filtrar gumes e calcular as perdas pelos modelos implementados.

As funções utilizadas pelo aplicativo são baseadas nas funções presentes em `Scripts`, com adaptações para integração com o MATLAB App Designer.

Consulte o README da pasta `App Design` para informações sobre utilização e configuração.

## Scripts

A pasta `Scripts` concentra as funções principais do projeto, os dados utilizados e os testes desenvolvidos durante as etapas de implementação, verificação, refinamento, calibração e avaliação.

A organização e a descrição dessas etapas estão disponíveis nos READMEs das respectivas pastas.

## Requisitos

O projeto foi desenvolvido no MATLAB e utiliza funcionalidades relacionadas a:

- cálculos geográficos e manipulação de coordenadas;
- desenvolvimento de aplicativos com MATLAB App Designer;
- obtenção de dados de elevação;
- análise e representação gráfica dos resultados.

Para utilizar a Google Elevation API, deve ser definida a variável de ambiente:

```matlab
setenv('GOOGLE_ELEVATION_API_KEY','SUA_CHAVE_AQUI')
```

A chave da API não é armazenada no repositório.

## Licença

O código desenvolvido pelo autor neste projeto é disponibilizado sob a licença MIT.

Consulte o arquivo `LICENSE` para os termos completos.

Códigos de terceiros presentes no repositório permanecem sujeitos às licenças e aos termos estabelecidos por seus respectivos autores.

## Uso de assistência de IA

Este README e os comentários presentes nos códigos foram adicionados ou revisados com auxílio de inteligência artificial, com o objetivo de melhorar a organização, clareza e documentação do projeto.

O ChatGPT também foi utilizado como ferramenta auxiliar em etapas de triagem e organização de resultados, posteriormente verificadas a partir dos dados gerados no MATLAB.

A lógica, os métodos, os parâmetros, a interpretação dos resultados e as decisões finais permaneceram sob responsabilidade do autor do projeto.