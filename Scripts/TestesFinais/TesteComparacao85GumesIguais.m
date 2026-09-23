clear
clc
close all

%% Definir caminhos

pastateste=fileparts(mfilename('fullpath'));

pastascripts=fileparts(pastateste);

addpath(fullfile(pastascripts,'Funções'))

arquivotxt=fullfile(pastascripts,'dadoslorencocompleto.txt');

pastarelevos=fullfile(pastascripts,'DadosSalvos','RelevosLorenco85');

%% Definir parâmetros

freq=575.142857*10^6;

alturat=10;

alturar=10;

%% Ler dados de Lorenço

arquivo=fopen(arquivotxt,'r');

dados=textscan(arquivo,'%s %s %s %s %s %f');

fclose(arquivo);

epsteinlorenco=str2double(strrep(dados{3},',','.'));

deygoutlorenco=str2double(strrep(dados{4},',','.'));

giovanelilorenco=str2double(strrep(dados{5},',','.'));

gumeslorenco=dados{6};

quantidade=length(gumeslorenco);

%% Preparar vetores dos casos com a mesma quantidade de gumes

casosiguais=[];

gumesiguais=[];

giovanelicalculado=[];

giovanelireferencia=[];

deygoutcalculado=[];

deygoutreferencia=[];

epsteincalculado=[];

epsteinreferencia=[];

%% Testar os 85 casos

for i=1:quantidade

    %% Carregar relevo

    nomearquivo=['DadosElevLorenco' num2str(i) '.mat'];

    caminhoarquivo=fullfile(pastarelevos,nomearquivo);

    load(caminhoarquivo,'dadoselev');

    %% Aplicar correção do raio efetivo da Terra

    dadoselev=raioefetivo(dadoselev);

    %% Identificar gumes sem filtro

    [indexgumes,gumes]=indexgumess(dadoselev,alturat,alturar,freq,false);

    %% Considerar somente casos com a mesma quantidade de gumes

    if gumes==gumeslorenco(i)

        %% Calcular Epstein-Peterson

        pathlossepstein=perdaepstein(indexgumes,dadoselev,freq,gumes,alturar,alturat);

        %% Calcular Deygout

        pathlossdeygout=perdadeygout(indexgumes,dadoselev,freq,gumes,alturar,alturat);

        %% Calcular Giovaneli

        pathlossgio=perdagiovaneli(indexgumes,dadoselev,freq,gumes,alturar,alturat);

        %% Corrigir sinal

        pathlossepstein=-pathlossepstein;

        pathlossdeygout=-pathlossdeygout;

        pathlossgio=-pathlossgio;

        %% Guardar caso

        casosiguais=[casosiguais i];

        gumesiguais=[gumesiguais gumes];

        %% Guardar Giovaneli

        giovanelicalculado=[giovanelicalculado pathlossgio];

        giovanelireferencia=[giovanelireferencia giovanelilorenco(i)];

        %% Guardar Deygout

        deygoutcalculado=[deygoutcalculado pathlossdeygout];

        deygoutreferencia=[deygoutreferencia deygoutlorenco(i)];

        %% Guardar Epstein-Peterson

        epsteincalculado=[epsteincalculado pathlossepstein];

        epsteinreferencia=[epsteinreferencia epsteinlorenco(i)];

    end

end

%% Calcular quantidade de casos iguais

quantidadeiguais=length(casosiguais);

percentualiguais=(quantidadeiguais/quantidade)*100;

%% Calcular métricas de Giovaneli

erro=giovanelicalculado-giovanelireferencia;

biasgio=mean(erro);

desviogio=std(erro,1);

maegio=mean(abs(erro));

rmsegio=sqrt(mean(erro.^2));

maxgio=max(abs(erro));

matriz=corrcoef(giovanelicalculado,giovanelireferencia);

correlacaogio=matriz(1,2);

r2gio=correlacaogio^2;

%% Calcular métricas de Deygout

erro=deygoutcalculado-deygoutreferencia;

biasdey=mean(erro);

desviodey=std(erro,1);

maedey=mean(abs(erro));

rmsedey=sqrt(mean(erro.^2));

maxdey=max(abs(erro));

matriz=corrcoef(deygoutcalculado,deygoutreferencia);

correlacaodey=matriz(1,2);

r2dey=correlacaodey^2;

%% Calcular métricas de Epstein-Peterson

erro=epsteincalculado-epsteinreferencia;

biaseps=mean(erro);

desvioeps=std(erro,1);

maeeps=mean(abs(erro));

rmseeps=sqrt(mean(erro.^2));

maxeps=max(abs(erro));

matriz=corrcoef(epsteincalculado,epsteinreferencia);

correlacaoeps=matriz(1,2);

r2eps=correlacaoeps^2;

%% Mostrar resumo estatístico

fprintf('\n')

fprintf('--------------------------------------------------------------------------------------------\n')

fprintf('RESUMO ESTATÍSTICO - CASOS COM A MESMA QUANTIDADE DE GUMES\n')

fprintf('--------------------------------------------------------------------------------------------\n')

fprintf('Casos iguais: %d de %d (%.2f %%)\n',quantidadeiguais,quantidade,percentualiguais)

fprintf('--------------------------------------------------------------------------------------------\n')

fprintf('%-20s %11s %10s %10s %10s %12s %12s %8s\n','Modelo','Erro médio','Desvio','MAE','RMSE','Erro máx.','Correlação','R²')

fprintf('--------------------------------------------------------------------------------------------\n')

fprintf('%-20s %+11.3f %10.3f %10.3f %10.3f %12.3f %12.4f %8.4f\n','Giovaneli',biasgio,desviogio,maegio,rmsegio,maxgio,correlacaogio,r2gio)

fprintf('%-20s %+11.3f %10.3f %10.3f %10.3f %12.3f %12.4f %8.4f\n','Deygout',biasdey,desviodey,maedey,rmsedey,maxdey,correlacaodey,r2dey)

fprintf('%-20s %+11.3f %10.3f %10.3f %10.3f %12.3f %12.4f %8.4f\n','Epstein-Peterson',biaseps,desvioeps,maeeps,rmseeps,maxeps,correlacaoeps,r2eps)

fprintf('--------------------------------------------------------------------------------------------\n')