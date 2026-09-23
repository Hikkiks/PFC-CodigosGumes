# PFC - CódigosGumes

Este repositório reúne os códigos, dados, testes e o aplicativo desenvolvidos durante um Projeto Final de Curso (PFC/TCC) voltado ao estudo e à implementação de modelos de difração por múltiplos gumes de faca aplicados a enlaces de rádio.

O projeto inclui rotinas para obtenção e tratamento de perfis de elevação, identificação e filtragem de gumes, cálculo de perdas por difração e comparação entre diferentes métodos.

## Sobre o projeto

O trabalho envolve a implementação e a validação dos métodos de Epstein-Peterson, Deygout e Giovaneli, além do desenvolvimento de ferramentas auxiliares para análise de perfis de relevo e seleção de gumes.

A parte escrita do trabalho, contendo a fundamentação teórica, metodologia, validações e análise dos resultados, será disponibilizada em um repositório separado.

O link para o repositório contendo a parte escrita será adicionado futuramente.

## Estrutura do repositório

```text
PFC - CódigosGumes/
├── App Design/
├── Scripts/
├── LICENSE
└── README.md
```

- `App Design` — Aplicativo desenvolvido no MATLAB App Designer;
- `Scripts` — Funções, dados e testes utilizados no desenvolvimento e na validação do projeto;
- `LICENSE` — Licença aplicável ao código desenvolvido pelo autor;
- `README.md` — Documentação principal do repositório.

A documentação específica de cada etapa está disponível nos respectivos arquivos README presentes nas pastas internas.

## App Design

A pasta `App Design` contém o aplicativo desenvolvido para análise de enlaces de rádio.

O aplicativo permite definir as posições e características das antenas, obter perfis de elevação, identificar e filtrar gumes e calcular as perdas pelos modelos implementados.

As funções utilizadas pelo aplicativo são baseadas nas funções presentes em `Scripts`, com adaptações necessárias para integração com o MATLAB App Designer.

Consulte o README da pasta `App Design` para mais informações sobre utilização e configuração.

## Scripts

A pasta `Scripts` concentra as funções principais do projeto, os dados utilizados nos testes e os scripts desenvolvidos ao longo das etapas de implementação, refinamento e validação.

A organização e a descrição detalhada dessas etapas estão disponíveis nos READMEs das respectivas pastas.

## Requisitos

O projeto foi desenvolvido no MATLAB e utiliza funcionalidades relacionadas a:

- Cálculos geográficos e manipulação de coordenadas;
- Desenvolvimento de aplicativos com MATLAB App Designer;
- Obtenção de dados de elevação;
- Análise e representação gráfica dos resultados.

Para a utilização da Google Elevation API no aplicativo, deve ser definida a variável de ambiente:

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

A lógica, os métodos, os parâmetros e as decisões de implementação do código permaneceram sob responsabilidade do autor do projeto.