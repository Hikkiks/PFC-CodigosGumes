# Testes de Refinamento

Esta pasta reúne testes utilizados para investigar e refinar etapas específicas do projeto após as verificações iniciais. As análises envolvem perfis de relevo, amostragem, geometria dos gumes, zona de Fresnel e resultados das varreduras de filtros.

A pasta contém 11 scripts MATLAB.

## Testes disponíveis

### Perfis de relevo e amostragem

| Script | Finalidade |
|---|---|
| `GerarRelevosLorenco85.m` | Gera os 85 perfis utilizados nas comparações com os resultados de Lorenço. |
| `TesteConsultaIndividualGoogleE2P1.m` | Compara o perfil salvo de E2-P1 com novas consultas à Google Elevation API. |
| `TesteMicroperfilGoogleE2P6.m` | Investiga variações locais do relevo em E2-P6. |
| `TesteQuantidadeAmostrasMATLAB12.m` | Analisa o efeito da quantidade de amostras na identificação dos gumes. |
| `TesteResolucaoGoogleAPI.m` | Analisa a resolução informada pela Google Elevation API. |
| `TesteEspacamentos12Casos.m` | Compara a identificação dos gumes para diferentes espaçamentos entre amostras. |

### Geometria e Fresnel

| Script | Finalidade |
|---|---|
| `TesteAnaliseGeometriaGumes12.m` | Analisa distância, ângulo, `h` e `v` nos gumes dos 12 casos. |
| `TesteValidacaoVerificaFresnel85.m` | Verifica geometricamente o funcionamento da função `verificafresnel` nos 85 perfis. |

`TesteAnaliseGeometriaGumes12.m` corresponde a uma investigação preliminar e não define isoladamente os critérios finais do filtro.

### Dados e varredura

| Script | Finalidade |
|---|---|
| `TesteValidacaoRelevos85.m` | Verifica a integridade e a consistência dos 85 perfis utilizados. |
| `TesteAnalisePioresCasos85.m` | Investiga os maiores erros das configurações selecionadas na varredura dos 85 casos. |
| `TesteVerificacaoVarredura85.m` | Confere os efeitos das configurações selecionadas sobre os gumes e os resultados calculados. |

Os nomes de alguns arquivos mantêm o termo `Validacao` por corresponderem à nomenclatura adotada durante o desenvolvimento, embora essas etapas sejam tratadas no trabalho final como verificações.

## Dados utilizados

Os principais conjuntos utilizados são:

```text
DadosSalvos/DadosConclusao/
DadosSalvos/RelevosLorenco85/
dadoslorencocompleto.txt
```

`DadosConclusao` contém os 12 perfis associados às duas emissoras e aos seis pontos de recepção.

`RelevosLorenco85` contém os 85 perfis gerados para comparação com os resultados de Lorenço.

Cada arquivo de relevo utiliza a variável `dadoselev`:

```text
dadoselev(1,:) = latitude
dadoselev(2,:) = longitude
dadoselev(3,:) = elevação do terreno
```

As alturas das antenas são fornecidas separadamente durante os cálculos.

## Google Elevation API

Alguns testes realizam novas consultas à Google Elevation API.

A chave deve ser fornecida pela variável de ambiente:

```matlab
API_KEY=getenv('GOOGLE_ELEVATION_API_KEY');
```

Ela pode ser definida durante a sessão do MATLAB com:

```matlab
setenv('GOOGLE_ELEVATION_API_KEY','SUA_CHAVE_AQUI')
```

Os principais scripts que realizam consultas são:

- `GerarRelevosLorenco85.m`;
- `TesteConsultaIndividualGoogleE2P1.m`;
- `TesteMicroperfilGoogleE2P6.m`;
- `TesteResolucaoGoogleAPI.m`.

## Verificação da varredura

`TesteAnalisePioresCasos85.m` e `TesteVerificacaoVarredura85.m` analisam as configurações:

```text
206554
203964
200330
206074
```

Esses testes dependem dos resultados produzidos em:

```text
TestesFinais/ResultadosVarredura85/
```

Os arquivos `.csv`, `.mat` e imagens gerados pelas análises são resultados derivados e podem ser produzidos novamente pelos respectivos scripts.

## Dependências

Os testes utilizam principalmente:

- `../Funções`;
- `../DadosSalvos/DadosConclusao`;
- `../DadosSalvos/RelevosLorenco85`;
- `../dadoslorencocompleto.txt`;
- `../TestesFinais/ResultadosVarredura85`, quando necessário.

## Uso de assistência de IA

Este README e os comentários dos códigos foram adicionados ou revisados com auxílio de inteligência artificial para melhorar a organização e a documentação.

A lógica, os métodos, os parâmetros e as decisões finais permaneceram sob responsabilidade do autor.