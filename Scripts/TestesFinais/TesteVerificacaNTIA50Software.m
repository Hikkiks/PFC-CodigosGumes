clear
clc
close all

%% Definir caminhos

pastateste=fileparts(mfilename('fullpath'));

pastascripts=fileparts(pastateste);

addpath(fullfile(pastascripts,'Funções'))

pastadados=fullfile(pastascripts,'DadosSalvos','NTIA50');

arquivotxt=fullfile(pastadados,'dadosNTIA50.txt');

pastarelevos=fullfile(pastadados,'Relevos');

pastasaida=fullfile(pastateste,'ResultadosNTIA50Software');

if exist(pastasaida,'dir')==0
    mkdir(pastasaida)
end

%% Conferir arquivos e funções

if exist(arquivotxt,'file')~=2
    error('O arquivo dadosNTIA50.txt não foi encontrado.')
end

if exist(pastarelevos,'dir')~=7
    error('A pasta de relevos NTIA50 não foi encontrada. Execute GerarRelevosNTIA50.m primeiro.')
end

if exist('indexgumess','file')~=2
    error('A função indexgumess não foi encontrada.')
end

if exist('perdaepstein','file')~=2
    error('A função perdaepstein não foi encontrada.')
end

if exist('perdadeygout','file')~=2
    error('A função perdadeygout não foi encontrada.')
end

if exist('perdagiovaneli','file')~=2
    error('A função perdagiovaneli não foi encontrada.')
end

%% Ler dados de referência

dados=readtable(arquivotxt,'Delimiter',',');

quantidade=height(dados);

if quantidade~=50
    error(['Foram encontrados ' num2str(quantidade) ' casos em vez de 50.'])
end

%% Definir identificação de gumes

% false mantém a comparação concentrada nos gumes de faca geométricos.
% O objetivo é verificar separadamente:
% 1) os métodos usando os gumes fornecidos pela NTIA;
% 2) os mesmos métodos usando os gumes encontrados por indexgumess.

usarfresnel=false;

%% Preparar resultados

gumesntia=zeros(quantidade,1);

gumesdetectados=zeros(quantidade,1);

diferencagumes=zeros(quantidade,1);

quantidadeigual=false(quantidade,1);

indicesiguais=false(quantidade,1);

indicesntiatexto=strings(quantidade,1);

indicesdetectadostexto=strings(quantidade,1);

epsteinfornecido=zeros(quantidade,1);

deygoutfornecido=zeros(quantidade,1);

giovanelifornecido=zeros(quantidade,1);

epsteindetectado=zeros(quantidade,1);

deygoutdetectado=zeros(quantidade,1);

giovanelidetectado=zeros(quantidade,1);

imagepstein=zeros(quantidade,2);

imagdeygout=zeros(quantidade,2);

imaggiovaneli=zeros(quantidade,2);

%% Executar os 50 casos

fprintf('\n')
fprintf('====================================================================\n')
fprintf('VALIDAÇÃO DO SOFTWARE COM OS 50 CASOS DA NTIA\n')
fprintf('====================================================================\n')
fprintf('Gumes fornecidos pela NTIA x gumes encontrados pelo indexgumess\n')
fprintf('Fresnel na identificação: %d\n',usarfresnel)
fprintf('====================================================================\n')

for caso=1:quantidade

    %% Carregar perfil sintético

    nomearquivo=['DadosNTIACaso' num2str(caso) '.mat'];

    caminhoarquivo=fullfile(pastarelevos,nomearquivo);

    if exist(caminhoarquivo,'file')~=2
        error(['O arquivo ' nomearquivo ' não foi encontrado.'])
    end

    perfil=load(caminhoarquivo,'dadoselev','indexgumes','gumes','freq','alturat','alturar');

    dadoselev=perfil.dadoselev;

    indexgumesntia=perfil.indexgumes;

    gumes=perfil.gumes;

    freq=perfil.freq;

    alturat=perfil.alturat;

    alturar=perfil.alturar;

    %% Conferir dados básicos

    if gumes~=dados.Gumes(caso)
        error(['Quantidade de gumes incorreta no caso ' num2str(caso) '.'])
    end

    if freq~=dados.FreqHz(caso)
        error(['Frequência incorreta no caso ' num2str(caso) '.'])
    end

    %% Identificar gumes com o algoritmo do software

    [indexgumesdetectados,gumesencontrados]=indexgumess(dadoselev,alturat,alturar,freq,usarfresnel);

    %% Guardar comparação dos gumes

    gumesntia(caso)=gumes;

    gumesdetectados(caso)=gumesencontrados;

    diferencagumes(caso)=gumesencontrados-gumes;

    quantidadeigual(caso)=gumesencontrados==gumes;

    indicesiguais(caso)=isequal(indexgumesdetectados,indexgumesntia);

    indicesntiatexto(caso)=string(mat2str(indexgumesntia));

    indicesdetectadostexto(caso)=string(mat2str(indexgumesdetectados));

    %% Calcular métodos com os gumes fornecidos pela NTIA

    perda=perdaepstein(indexgumesntia,dadoselev,freq,gumes,alturar,alturat);

    [epsteinfornecido(caso),imagepstein(caso,1)]=normalizavalor(-perda);

    perda=perdadeygout(indexgumesntia,dadoselev,freq,gumes,alturar,alturat);

    [deygoutfornecido(caso),imagdeygout(caso,1)]=normalizavalor(-perda);

    perda=perdagiovaneli(indexgumesntia,dadoselev,freq,gumes,alturar,alturat);

    [giovanelifornecido(caso),imaggiovaneli(caso,1)]=normalizavalor(-perda);

    %% Calcular métodos com os gumes identificados pelo software

    perda=perdaepstein(indexgumesdetectados,dadoselev,freq,gumesencontrados,alturar,alturat);

    [epsteindetectado(caso),imagepstein(caso,2)]=normalizavalor(-perda);

    perda=perdadeygout(indexgumesdetectados,dadoselev,freq,gumesencontrados,alturar,alturat);

    [deygoutdetectado(caso),imagdeygout(caso,2)]=normalizavalor(-perda);

    perda=perdagiovaneli(indexgumesdetectados,dadoselev,freq,gumesencontrados,alturar,alturat);

    [giovanelidetectado(caso),imaggiovaneli(caso,2)]=normalizavalor(-perda);

    %% Mostrar progresso

    fprintf('Caso %2d | Gumes NTIA: %d | Detectados: %d | Índices iguais: %d\n',caso,gumes,gumesencontrados,indicesiguais(caso))

end

%% Calcular erros por caso

erroepsteinfornecidovogler=epsteinfornecido-dados.Vogler;

errodeygoutfornecidovogler=deygoutfornecido-dados.Vogler;

errogiovanelifornecidovogler=giovanelifornecido-dados.Vogler;

erroepsteindetectadovogler=epsteindetectado-dados.Vogler;

errodeygoutdetectadovogler=deygoutdetectado-dados.Vogler;

errogiovanelidetectadovogler=giovanelidetectado-dados.Vogler;

erroepsteinfornecidontia=epsteinfornecido-dados.EpsteinNTIA;

errodeygoutfornecidontia=deygoutfornecido-dados.DeygoutNTIA;

errogiovanelifornecidontia=giovanelifornecido-dados.GiovaneliNTIA;

erroepsteindetectadontia=epsteindetectado-dados.EpsteinNTIA;

errodeygoutdetectadontia=deygoutdetectado-dados.DeygoutNTIA;

errogiovanelidetectadontia=giovanelidetectado-dados.GiovaneliNTIA;

%% Criar tabela completa por caso

caso=dados.Caso;

resultado=table(caso,gumesntia,gumesdetectados,diferencagumes,quantidadeigual,indicesiguais,indicesntiatexto,indicesdetectadostexto,dados.Vogler,dados.EpsteinNTIA,epsteinfornecido,erroepsteinfornecidontia,erroepsteinfornecidovogler,epsteindetectado,erroepsteindetectadontia,erroepsteindetectadovogler,dados.DeygoutNTIA,deygoutfornecido,errodeygoutfornecidontia,errodeygoutfornecidovogler,deygoutdetectado,errodeygoutdetectadontia,errodeygoutdetectadovogler,dados.GiovaneliNTIA,giovanelifornecido,errogiovanelifornecidontia,errogiovanelifornecidovogler,giovanelidetectado,errogiovanelidetectadontia,errogiovanelidetectadovogler);

resultado.Properties.VariableNames={'Caso','GumesNTIA','GumesDetectados','DiferencaGumes','QuantidadeGumesIgual','IndicesGumesIguais','IndicesNTIA','IndicesDetectados','Vogler','EpsteinNTIA','EpsteinLucasGumesNTIA','ErroEpsteinLucasVsNTIA','ErroEpsteinLucasVsVogler','EpsteinLucasGumesDetectados','ErroEpsteinDetectadoVsNTIA','ErroEpsteinDetectadoVsVogler','DeygoutNTIA','DeygoutLucasGumesNTIA','ErroDeygoutLucasVsNTIA','ErroDeygoutLucasVsVogler','DeygoutLucasGumesDetectados','ErroDeygoutDetectadoVsNTIA','ErroDeygoutDetectadoVsVogler','GiovaneliNTIA','GiovaneliLucasGumesNTIA','ErroGiovaneliLucasVsNTIA','ErroGiovaneliLucasVsVogler','GiovaneliLucasGumesDetectados','ErroGiovaneliDetectadoVsNTIA','ErroGiovaneliDetectadoVsVogler'};

%% Calcular as 13 métricas

metricas=calculametricas("Gumes NTIA","Epstein-Peterson","Lucas x Vogler",epsteinfornecido,dados.Vogler);

metricas=[metricas;calculametricas("Gumes NTIA","Deygout","Lucas x Vogler",deygoutfornecido,dados.Vogler)];

metricas=[metricas;calculametricas("Gumes NTIA","Giovaneli","Lucas x Vogler",giovanelifornecido,dados.Vogler)];

metricas=[metricas;calculametricas("Gumes NTIA","Epstein-Peterson","Lucas x NTIA",epsteinfornecido,dados.EpsteinNTIA)];

metricas=[metricas;calculametricas("Gumes NTIA","Deygout","Lucas x NTIA",deygoutfornecido,dados.DeygoutNTIA)];

metricas=[metricas;calculametricas("Gumes NTIA","Giovaneli","Lucas x NTIA",giovanelifornecido,dados.GiovaneliNTIA)];

metricas=[metricas;calculametricas("Gumes detectados","Epstein-Peterson","Lucas x Vogler",epsteindetectado,dados.Vogler)];

metricas=[metricas;calculametricas("Gumes detectados","Deygout","Lucas x Vogler",deygoutdetectado,dados.Vogler)];

metricas=[metricas;calculametricas("Gumes detectados","Giovaneli","Lucas x Vogler",giovanelidetectado,dados.Vogler)];

metricas=[metricas;calculametricas("Gumes detectados","Epstein-Peterson","Lucas x NTIA",epsteindetectado,dados.EpsteinNTIA)];

metricas=[metricas;calculametricas("Gumes detectados","Deygout","Lucas x NTIA",deygoutdetectado,dados.DeygoutNTIA)];

metricas=[metricas;calculametricas("Gumes detectados","Giovaneli","Lucas x NTIA",giovanelidetectado,dados.GiovaneliNTIA)];

metricas=[metricas;calculametricas("Referência NTIA","Epstein-Peterson","NTIA x Vogler",dados.EpsteinNTIA,dados.Vogler)];

metricas=[metricas;calculametricas("Referência NTIA","Deygout","NTIA x Vogler",dados.DeygoutNTIA,dados.Vogler)];

metricas=[metricas;calculametricas("Referência NTIA","Giovaneli","NTIA x Vogler",dados.GiovaneliNTIA,dados.Vogler)];

%% Calcular faixas de erro em relação a Vogler

faixas=calculafaixas("Gumes NTIA","Epstein-Peterson",erroepsteinfornecidovogler);

faixas=[faixas;calculafaixas("Gumes NTIA","Deygout",errodeygoutfornecidovogler)];

faixas=[faixas;calculafaixas("Gumes NTIA","Giovaneli",errogiovanelifornecidovogler)];

faixas=[faixas;calculafaixas("Gumes detectados","Epstein-Peterson",erroepsteindetectadovogler)];

faixas=[faixas;calculafaixas("Gumes detectados","Deygout",errodeygoutdetectadovogler)];

faixas=[faixas;calculafaixas("Gumes detectados","Giovaneli",errogiovanelidetectadovogler)];

faixas=[faixas;calculafaixas("Referência NTIA","Epstein-Peterson",dados.EpsteinNTIA-dados.Vogler)];

faixas=[faixas;calculafaixas("Referência NTIA","Deygout",dados.DeygoutNTIA-dados.Vogler)];

faixas=[faixas;calculafaixas("Referência NTIA","Giovaneli",dados.GiovaneliNTIA-dados.Vogler)];

%% Calcular métricas por quantidade de gumes da NTIA

metricasporgumes=table;

for numerogumes=2:6

    mascara=dados.Gumes==numerogumes;

    metricasporgumes=[metricasporgumes;calculametricasgrupo("Gumes NTIA","Epstein-Peterson",numerogumes,epsteinfornecido(mascara),dados.Vogler(mascara))];

    metricasporgumes=[metricasporgumes;calculametricasgrupo("Gumes NTIA","Deygout",numerogumes,deygoutfornecido(mascara),dados.Vogler(mascara))];

    metricasporgumes=[metricasporgumes;calculametricasgrupo("Gumes NTIA","Giovaneli",numerogumes,giovanelifornecido(mascara),dados.Vogler(mascara))];

    metricasporgumes=[metricasporgumes;calculametricasgrupo("Gumes detectados","Epstein-Peterson",numerogumes,epsteindetectado(mascara),dados.Vogler(mascara))];

    metricasporgumes=[metricasporgumes;calculametricasgrupo("Gumes detectados","Deygout",numerogumes,deygoutdetectado(mascara),dados.Vogler(mascara))];

    metricasporgumes=[metricasporgumes;calculametricasgrupo("Gumes detectados","Giovaneli",numerogumes,giovanelidetectado(mascara),dados.Vogler(mascara))];

end

%% Identificar piores casos em relação a Vogler

piores=table;

piores=[piores;selecionapiores("Gumes NTIA","Epstein-Peterson",caso,erroepsteinfornecidovogler,5)];

piores=[piores;selecionapiores("Gumes NTIA","Deygout",caso,errodeygoutfornecidovogler,5)];

piores=[piores;selecionapiores("Gumes NTIA","Giovaneli",caso,errogiovanelifornecidovogler,5)];

piores=[piores;selecionapiores("Gumes detectados","Epstein-Peterson",caso,erroepsteindetectadovogler,5)];

piores=[piores;selecionapiores("Gumes detectados","Deygout",caso,errodeygoutdetectadovogler,5)];

piores=[piores;selecionapiores("Gumes detectados","Giovaneli",caso,errogiovanelidetectadovogler,5)];

%% Resumir identificação dos gumes

casosquantidadeigual=sum(quantidadeigual);

casosindicesiguais=sum(indicesiguais);

erroabsolutogumes=sum(abs(diferencagumes));

mediagumes=mean(diferencagumes);

resumogumes=table(quantidade,casosquantidadeigual,casosindicesiguais,erroabsolutogumes,mediagumes);

resumogumes.Properties.VariableNames={'Casos','QuantidadeGumesIgual','IndicesGumesIguais','ErroAbsolutoTotalGumes','MediaDiferencaGumes'};

%% Resumir componentes imaginárias numéricas

metodo=["Epstein-Peterson";"Deygout";"Giovaneli"];

maximagfornecido=[max(imagepstein(:,1));max(imagdeygout(:,1));max(imaggiovaneli(:,1))];

maximagdetectado=[max(imagepstein(:,2));max(imagdeygout(:,2));max(imaggiovaneli(:,2))];

resumoimaginario=table(metodo,maximagfornecido,maximagdetectado);

resumoimaginario.Properties.VariableNames={'Metodo','MaxComponenteImaginariaGumesNTIA_dB','MaxComponenteImaginariaGumesDetectados_dB'};

%% Mostrar resultados principais

fprintf('\n')
fprintf('====================================================================\n')
fprintf('RESUMO DA IDENTIFICAÇÃO DOS GUMES\n')
fprintf('====================================================================\n')

disp(resumogumes)

fprintf('\n')
fprintf('====================================================================\n')
fprintf('13 MÉTRICAS\n')
fprintf('====================================================================\n')

disp(metricas)

fprintf('\n')
fprintf('====================================================================\n')
fprintf('FAIXAS DE ERRO EM RELAÇÃO A VOGLER\n')
fprintf('====================================================================\n')

disp(faixas)

fprintf('\n')
fprintf('====================================================================\n')
fprintf('COMPONENTES IMAGINÁRIAS NUMÉRICAS\n')
fprintf('====================================================================\n')

disp(resumoimaginario)

%% Salvar resultados

writetable(resultado,fullfile(pastasaida,'ResultadosNTIA50Software.csv'));

writetable(metricas,fullfile(pastasaida,'MetricasNTIA50Software.csv'));

writetable(faixas,fullfile(pastasaida,'FaixasErroNTIA50Software.csv'));

writetable(metricasporgumes,fullfile(pastasaida,'MetricasPorGumesNTIA50Software.csv'));

writetable(piores,fullfile(pastasaida,'PioresCasosNTIA50Software.csv'));

writetable(resumogumes,fullfile(pastasaida,'ResumoGumesNTIA50Software.csv'));

writetable(resumoimaginario,fullfile(pastasaida,'ResumoNumericoNTIA50Software.csv'));

save(fullfile(pastasaida,'TesteValidacaoNTIA50Software.mat'),'resultado','metricas','faixas','metricasporgumes','piores','resumogumes','resumoimaginario','epsteinfornecido','deygoutfornecido','giovanelifornecido','epsteindetectado','deygoutdetectado','giovanelidetectado','dados');

%% Gerar gráficos principais

figure

plot(caso,dados.Vogler,'k-')

hold on

plot(caso,epsteinfornecido,'o-')

plot(caso,epsteindetectado,'x-')

grid on

xlabel('Caso')

ylabel('Perda por difração (dB)')

title('Epstein-Peterson x Vogler')

legend('Vogler','Lucas - gumes NTIA','Lucas - gumes detectados','Location','best')

figure

plot(caso,dados.Vogler,'k-')

hold on

plot(caso,deygoutfornecido,'o-')

plot(caso,deygoutdetectado,'x-')

grid on

xlabel('Caso')

ylabel('Perda por difração (dB)')

title('Deygout x Vogler')

legend('Vogler','Lucas - gumes NTIA','Lucas - gumes detectados','Location','best')

figure

plot(caso,dados.Vogler,'k-')

hold on

plot(caso,giovanelifornecido,'o-')

plot(caso,giovanelidetectado,'x-')

grid on

xlabel('Caso')

ylabel('Perda por difração (dB)')

title('Giovaneli x Vogler')

legend('Vogler','Lucas - gumes NTIA','Lucas - gumes detectados','Location','best')

%% Finalizar

fprintf('\n')
fprintf('====================================================================\n')
fprintf('VALIDAÇÃO CONCLUÍDA\n')
fprintf('====================================================================\n')
fprintf('Resultados salvos em:\n')
fprintf('%s\n',pastasaida)
fprintf('====================================================================\n')

%% Normalizar pequeno resíduo imaginário

function [valorreal,valorimag]=normalizavalor(valor)

valorimag=abs(imag(valor));

valorreal=real(valor);

end

%% Calcular as 13 métricas

function metricas=calculametricas(modo,metodo,comparacao,estimado,referencia)

erro=estimado-referencia;

mediaerro=mean(erro);

medianaerro=median(erro);

desvioerro=std(erro,1);

mae=mean(abs(erro));

rmse=sqrt(mean(erro.^2));

errocentralizado=erro-mediaerro;

maecentralizado=mean(abs(errocentralizado));

rmsecentralizado=sqrt(mean(errocentralizado.^2));

maderro=median(abs(erro-median(erro)));

erromaximo=max(abs(erro));

matrizcorrelacao=corrcoef(estimado,referencia);

correlacao=matrizcorrelacao(1,2);

r2=correlacao^2;

ajuste=polyfit(referencia,estimado,1);

inclinacao=ajuste(1);

intercepto=ajuste(2);

metricas=table(modo,metodo,comparacao,mediaerro,medianaerro,desvioerro,mae,rmse,maecentralizado,rmsecentralizado,maderro,erromaximo,correlacao,inclinacao,intercepto,r2);

metricas.Properties.VariableNames={'Modo','Metodo','Comparacao','MediaErro','MedianaErro','DesvioErro','MAE','RMSE','MAECentralizado','RMSECentralizado','MAD','ErroMaximoAbsoluto','Correlacao','Inclinacao','Intercepto','R2'};

end

%% Calcular faixas de erro

function faixas=calculafaixas(modo,metodo,erro)

erroabsoluto=abs(erro);

casos1=sum(erroabsoluto<=1);

casos2=sum(erroabsoluto<=2);

casos3=sum(erroabsoluto<=3);

casos5=sum(erroabsoluto<=5);

casos10=sum(erroabsoluto<=10);

total=length(erro);

percentual1=100*casos1/total;

percentual2=100*casos2/total;

percentual3=100*casos3/total;

percentual5=100*casos5/total;

percentual10=100*casos10/total;

faixas=table(modo,metodo,total,casos1,casos2,casos3,casos5,casos10,percentual1,percentual2,percentual3,percentual5,percentual10);

faixas.Properties.VariableNames={'Modo','Metodo','Casos','ErroAte1dB','ErroAte2dB','ErroAte3dB','ErroAte5dB','ErroAte10dB','PercentualAte1dB','PercentualAte2dB','PercentualAte3dB','PercentualAte5dB','PercentualAte10dB'};

end

%% Calcular métricas resumidas por quantidade de gumes

function metricas=calculametricasgrupo(modo,metodo,numerogumes,estimado,referencia)

erro=estimado-referencia;

casos=length(erro);

mediaerro=mean(erro);

mae=mean(abs(erro));

rmse=sqrt(mean(erro.^2));

erromaximo=max(abs(erro));

metricas=table(modo,metodo,numerogumes,casos,mediaerro,mae,rmse,erromaximo);

metricas.Properties.VariableNames={'Modo','Metodo','GumesNTIA','Casos','MediaErro','MAE','RMSE','ErroMaximoAbsoluto'};

end

%% Selecionar piores casos

function piores=selecionapiores(modo,metodo,casos,erro,quantidade)

erroabsoluto=abs(erro);

[~,ordem]=sort(erroabsoluto,'descend');

ordem=ordem(1:min(quantidade,length(ordem)));

caso=casos(ordem);

erroselecionado=erro(ordem);

erroabsolutoselecionado=erroabsoluto(ordem);

posicao=(1:length(ordem))';

modo=repmat(string(modo),length(ordem),1);

metodo=repmat(string(metodo),length(ordem),1);

piores=table(modo,metodo,posicao,caso,erroselecionado,erroabsolutoselecionado);

piores.Properties.VariableNames={'Modo','Metodo','Posicao','Caso','Erro_dB','ErroAbsoluto_dB'};

end
