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

pastasaida=fullfile(pastateste,'ResultadosNTIA50');

if exist(pastasaida,'dir')==0
    mkdir(pastasaida)
end

%% Conferir arquivos

if exist(arquivotxt,'file')~=2
    error('O arquivo dadosNTIA50.txt não foi encontrado.')
end

if exist(pastarelevos,'dir')~=7
    error('A pasta de relevos NTIA50 não foi encontrada. Execute GerarRelevosNTIA50.m primeiro.')
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

%% Informações importantes da validação

% Fonte:
% NTIA TR-26-580, A Comparative Analysis of Multiple Knife-Edge
% Diffraction Methods, outubro de 2025.
%
% Tabelas 12 e 13: geometrias dos cenários.
% Tabelas 17 e 18: perdas em dB acima do espaço livre.
%
% A publicação usa 1500 MHz em todos os 50 cenários e alturas
% Tx/Rx iguais a zero.
%
% Para reproduzir a comparação "all knife edges" das Tabelas 17 e 18,
% este teste NÃO executa indexgumess. Todos os gumes listados pela
% publicação são fornecidos diretamente aos três métodos.
%
% Também NÃO é aplicada correção de raio efetivo da Terra, pois os
% cenários da publicação são geometrias sintéticas de gumes.

%% Preparar resultados

epsteinlucas=zeros(quantidade,1);

deygoutlucas=zeros(quantidade,1);

giovanelilucas=zeros(quantidade,1);

%% Calcular os 50 casos

fprintf('\n')
fprintf('====================================================================\n')
fprintf('VALIDAÇÃO NTIA TR-26-580 - 50 CENÁRIOS\n')
fprintf('====================================================================\n')

for caso=1:quantidade

    %% Carregar caso

    nomearquivo=['DadosNTIACaso' num2str(caso) '.mat'];

    caminhoarquivo=fullfile(pastarelevos,nomearquivo);

    if exist(caminhoarquivo,'file')~=2
        error(['O arquivo ' nomearquivo ' não foi encontrado.'])
    end

    perfil=load(caminhoarquivo,'dadoselev','indexgumes','gumes','freq','alturat','alturar');

    dadoselev=perfil.dadoselev;

    indexgumes=perfil.indexgumes;

    gumes=perfil.gumes;

    freq=perfil.freq;

    alturat=perfil.alturat;

    alturar=perfil.alturar;

    %% Conferir parâmetros

    if gumes~=dados.Gumes(caso)
        error(['Quantidade de gumes incorreta no caso ' num2str(caso) '.'])
    end

    if abs(freq-dados.FreqHz(caso))>0
        error(['Frequência incorreta no caso ' num2str(caso) '.'])
    end

    %% Calcular Epstein-Peterson

    perda=perdaepstein(indexgumes,dadoselev,freq,gumes,alturar,alturat);

    epsteinlucas(caso)=-perda;

    %% Calcular Deygout

    perda=perdadeygout(indexgumes,dadoselev,freq,gumes,alturar,alturat);

    deygoutlucas(caso)=-perda;

    %% Calcular Giovaneli

    perda=perdagiovaneli(indexgumes,dadoselev,freq,gumes,alturar,alturat);

    giovanelilucas(caso)=-perda;

    %% Mostrar progresso

    fprintf('Caso %2d | EP: %8.3f / %8.3f | D: %8.3f / %8.3f | G: %8.3f / %8.3f\n',caso,epsteinlucas(caso),dados.EpsteinNTIA(caso),deygoutlucas(caso),dados.DeygoutNTIA(caso),giovanelilucas(caso),dados.GiovaneliNTIA(caso))

end

%% Calcular erros em relação à implementação da NTIA

erroepsteinntia=epsteinlucas-dados.EpsteinNTIA;

errodeygoutntia=deygoutlucas-dados.DeygoutNTIA;

errogiovanelintia=giovanelilucas-dados.GiovaneliNTIA;

%% Calcular erros em relação a Vogler

erroepsteinvogler=epsteinlucas-dados.Vogler;

errodeygoutvogler=deygoutlucas-dados.Vogler;

errogiovanelivogler=giovanelilucas-dados.Vogler;

%% Criar tabela por caso

caso=dados.Caso;

gumes=dados.Gumes;

resultado=table(caso,gumes,dados.Vogler,dados.EpsteinNTIA,epsteinlucas,erroepsteinntia,erroepsteinvogler,dados.DeygoutNTIA,deygoutlucas,errodeygoutntia,errodeygoutvogler,dados.GiovaneliNTIA,giovanelilucas,errogiovanelintia,errogiovanelivogler);

resultado.Properties.VariableNames={'Caso','Gumes','Vogler','EpsteinNTIA','EpsteinLucas','ErroEpsteinLucasVsNTIA','ErroEpsteinLucasVsVogler','DeygoutNTIA','DeygoutLucas','ErroDeygoutLucasVsNTIA','ErroDeygoutLucasVsVogler','GiovaneliNTIA','GiovaneliLucas','ErroGiovaneliLucasVsNTIA','ErroGiovaneliLucasVsVogler'};

%% Calcular as 13 métricas

metricas=calculametricas("Epstein Lucas x Epstein NTIA",epsteinlucas,dados.EpsteinNTIA);

metricas=[metricas;calculametricas("Epstein Lucas x Vogler",epsteinlucas,dados.Vogler)];

metricas=[metricas;calculametricas("Epstein NTIA x Vogler",dados.EpsteinNTIA,dados.Vogler)];

metricas=[metricas;calculametricas("Deygout Lucas x Deygout NTIA",deygoutlucas,dados.DeygoutNTIA)];

metricas=[metricas;calculametricas("Deygout Lucas x Vogler",deygoutlucas,dados.Vogler)];

metricas=[metricas;calculametricas("Deygout NTIA x Vogler",dados.DeygoutNTIA,dados.Vogler)];

metricas=[metricas;calculametricas("Giovaneli Lucas x Giovaneli NTIA",giovanelilucas,dados.GiovaneliNTIA)];

metricas=[metricas;calculametricas("Giovaneli Lucas x Vogler",giovanelilucas,dados.Vogler)];

metricas=[metricas;calculametricas("Giovaneli NTIA x Vogler",dados.GiovaneliNTIA,dados.Vogler)];

%% Criar resumo rápido da reprodução

metodo=["Epstein-Peterson";"Deygout";"Giovaneli"];

maeimplementacao=[mean(abs(erroepsteinntia));mean(abs(errodeygoutntia));mean(abs(errogiovanelintia))];

rmseimplementacao=[sqrt(mean(erroepsteinntia.^2));sqrt(mean(errodeygoutntia.^2));sqrt(mean(errogiovanelintia.^2))];

erromaximplementacao=[max(abs(erroepsteinntia));max(abs(errodeygoutntia));max(abs(errogiovanelintia))];

biasimplementacao=[mean(erroepsteinntia);mean(errodeygoutntia);mean(errogiovanelintia)];

resumoreproducao=table(metodo,biasimplementacao,maeimplementacao,rmseimplementacao,erromaximplementacao);

resumoreproducao.Properties.VariableNames={'Metodo','BiasLucasVsNTIA_dB','MAELucasVsNTIA_dB','RMSELucasVsNTIA_dB','ErroMaxLucasVsNTIA_dB'};

%% Mostrar resultados

fprintf('\n')
fprintf('====================================================================\n')
fprintf('REPRODUÇÃO DAS IMPLEMENTAÇÕES PUBLICADAS PELA NTIA\n')
fprintf('====================================================================\n')

disp(resumoreproducao)

fprintf('\n')
fprintf('====================================================================\n')
fprintf('13 MÉTRICAS\n')
fprintf('====================================================================\n')

disp(metricas)

%% Salvar resultados

writetable(resultado,fullfile(pastasaida,'ResultadosNTIA50Casos.csv'));

writetable(metricas,fullfile(pastasaida,'MetricasNTIA50.csv'));

writetable(resumoreproducao,fullfile(pastasaida,'ResumoReproducaoNTIA50.csv'));

save(fullfile(pastasaida,'TesteValidacaoNTIA50.mat'),'resultado','metricas','resumoreproducao','epsteinlucas','deygoutlucas','giovanelilucas','dados');

%% Gerar gráficos de comparação

figure

plot(caso,dados.EpsteinNTIA,'o-')

hold on

plot(caso,epsteinlucas,'x-')

plot(caso,dados.Vogler,'k--')

grid on

xlabel('Caso')

ylabel('Perda por difração (dB)')

title('Epstein-Peterson - NTIA x Lucas x Vogler')

legend('Epstein NTIA','Epstein Lucas','Vogler','Location','best')

figure

plot(caso,dados.DeygoutNTIA,'o-')

hold on

plot(caso,deygoutlucas,'x-')

plot(caso,dados.Vogler,'k--')

grid on

xlabel('Caso')

ylabel('Perda por difração (dB)')

title('Deygout - NTIA x Lucas x Vogler')

legend('Deygout NTIA','Deygout Lucas','Vogler','Location','best')

figure

plot(caso,dados.GiovaneliNTIA,'o-')

hold on

plot(caso,giovanelilucas,'x-')

plot(caso,dados.Vogler,'k--')

grid on

xlabel('Caso')

ylabel('Perda por difração (dB)')

title('Giovaneli - NTIA x Lucas x Vogler')

legend('Giovaneli NTIA','Giovaneli Lucas','Vogler','Location','best')

%% Finalizar

fprintf('\n')
fprintf('Resultados salvos em:\n')
fprintf('%s\n',pastasaida)

%% Calcular métricas

function metricas=calculametricas(comparacao,estimado,referencia)

%% Calcular erro

erro=estimado-referencia;

mediaerro=mean(erro);

medianaerro=median(erro);

desvioerro=std(erro,1);

mae=mean(abs(erro));

rmse=sqrt(mean(erro.^2));

%% Centralizar erro

errocentralizado=erro-mediaerro;

maecentralizado=mean(abs(errocentralizado));

rmsecentralizado=sqrt(mean(errocentralizado.^2));

%% Calcular métricas robustas e extremas

maderro=median(abs(erro-median(erro)));

erromaximo=max(abs(erro));

%% Calcular correlação e R2

matrizcorrelacao=corrcoef(estimado,referencia);

correlacao=matrizcorrelacao(1,2);

r2=correlacao^2;

%% Calcular regressão linear

ajuste=polyfit(referencia,estimado,1);

inclinacao=ajuste(1);

intercepto=ajuste(2);

%% Criar tabela

metricas=table(comparacao,mediaerro,medianaerro,desvioerro,mae,rmse,maecentralizado,rmsecentralizado,maderro,erromaximo,correlacao,inclinacao,intercepto,r2);

metricas.Properties.VariableNames={'Comparacao','MediaErro','MedianaErro','DesvioErro','MAE','RMSE','MAECentralizado','RMSECentralizado','MAD','ErroMaximoAbsoluto','Correlacao','Inclinacao','Intercepto','R2'};

end
