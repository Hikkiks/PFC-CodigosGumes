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

if arquivo==-1
    error('Não foi possível abrir dadoslorencocompleto.txt.')
end

dados=textscan(arquivo,'%s %s %s %s %s %f');

fclose(arquivo);

epsteinlorenco=str2double(strrep(dados{3},',','.'));

deygoutlorenco=str2double(strrep(dados{4},',','.'));

giovanelilorenco=str2double(strrep(dados{5},',','.'));

gumeslorenco=dados{6};

quantidade=length(epsteinlorenco);

%% Preparar vetores dos resultados

gumescalculados=zeros(quantidade,1);

giovanelicalculado=zeros(quantidade,1);

deygoutcalculado=zeros(quantidade,1);

epsteincalculado=zeros(quantidade,1);

%% Mostrar cabeçalho

disp('---------------------------------------------------------------------------------------------------------------------------------------------------------------------------')
disp('Linha |      Gumes de Faca      |        Giovaneli        |         Deygout         |    Epstein-Peterson')
disp('      | Lucas Lorenço Diferença | Lucas Lorenço Diferença | Lucas Lorenço Diferença | Lucas Lorenço Diferença')
disp('---------------------------------------------------------------------------------------------------------------------------------------------------------------------------')

%% Comparar os 85 casos

for i=1:quantidade

    %% Carregar relevo

    nomearquivo=['DadosElevLorenco' num2str(i) '.mat'];

    caminhoarquivo=fullfile(pastarelevos,nomearquivo);

    load(caminhoarquivo,'dadoselev');

    %% Aplicar correção do raio efetivo da Terra

    dadoselev=raioefetivo(dadoselev);

    %% Identificar gumes sem filtro

    [indexgumes,gumes]=indexgumess(dadoselev,alturat,alturar,freq,false);

    %% Calcular Epstein-Peterson

    pathlossepstein=perdaepstein(indexgumes,dadoselev,freq,gumes,alturar,alturat);

    %% Calcular Deygout

    pathlossdeygout=perdadeygout(indexgumes,dadoselev,freq,gumes,alturar,alturat);

    %% Calcular Giovaneli

    pathlossgio=perdagiovaneli(indexgumes,dadoselev,freq,gumes,alturar,alturat);

    %% Corrigir sinal dos resultados de perda

    pathlossepstein=-pathlossepstein;

    pathlossdeygout=-pathlossdeygout;

    pathlossgio=-pathlossgio;

    %% Guardar resultados

    gumescalculados(i)=gumes;

    giovanelicalculado(i)=pathlossgio;

    deygoutcalculado(i)=pathlossdeygout;

    epsteincalculado(i)=pathlossepstein;

    %% Calcular diferenças

    difgumes=gumes-gumeslorenco(i);

    difgio=pathlossgio-giovanelilorenco(i);

    difdey=pathlossdeygout-deygoutlorenco(i);

    difeps=pathlossepstein-epsteinlorenco(i);

    %% Mostrar resultados

    fprintf('%5d | %5d %6d %9d | %6.2f %7.2f %9.2f | %6.2f %7.2f %9.2f | %6.2f %7.2f %9.2f\n',i,gumes,gumeslorenco(i),difgumes,pathlossgio,giovanelilorenco(i),difgio,pathlossdeygout,deygoutlorenco(i),difdey,pathlossepstein,epsteinlorenco(i),difeps)

end

disp('---------------------------------------------------------------------------------------------------------------------------------------------------------------------------')

%% Calcular métricas de Giovaneli

erro=giovanelicalculado-giovanelilorenco;

biasgio=mean(erro);

medianagio=median(erro);

desviogio=std(erro,1);

maegio=mean(abs(erro));

rmsegio=sqrt(mean(erro.^2));

errocentralizado=erro-biasgio;

maecentralgio=mean(abs(errocentralizado));

rmsecentralgio=sqrt(mean(errocentralizado.^2));

madgio=median(abs(erro-median(erro)));

maxgio=max(abs(erro));

matriz=corrcoef(giovanelicalculado,giovanelilorenco);

correlacaogio=matriz(1,2);

r2gio=correlacaogio^2;

ajuste=polyfit(giovanelilorenco,giovanelicalculado,1);

inclinacaogio=ajuste(1);

interceptogio=ajuste(2);

%% Calcular métricas de Deygout

erro=deygoutcalculado-deygoutlorenco;

biasdey=mean(erro);

medianadey=median(erro);

desviodey=std(erro,1);

maedey=mean(abs(erro));

rmsedey=sqrt(mean(erro.^2));

errocentralizado=erro-biasdey;

maecentraldey=mean(abs(errocentralizado));

rmsecentraldey=sqrt(mean(errocentralizado.^2));

maddey=median(abs(erro-median(erro)));

maxdey=max(abs(erro));

matriz=corrcoef(deygoutcalculado,deygoutlorenco);

correlacaodey=matriz(1,2);

r2dey=correlacaodey^2;

ajuste=polyfit(deygoutlorenco,deygoutcalculado,1);

inclinacaodey=ajuste(1);

interceptodey=ajuste(2);

%% Calcular métricas de Epstein-Peterson

erro=epsteincalculado-epsteinlorenco;

biaseps=mean(erro);

medianaeps=median(erro);

desvioeps=std(erro,1);

maeeps=mean(abs(erro));

rmseeps=sqrt(mean(erro.^2));

errocentralizado=erro-biaseps;

maecentraleps=mean(abs(errocentralizado));

rmsecentraleps=sqrt(mean(errocentralizado.^2));

madeps=median(abs(erro-median(erro)));

maxeps=max(abs(erro));

matriz=corrcoef(epsteincalculado,epsteinlorenco);

correlacaoeps=matriz(1,2);

r2eps=correlacaoeps^2;

ajuste=polyfit(epsteinlorenco,epsteincalculado,1);

inclinacaoeps=ajuste(1);

interceptoeps=ajuste(2);

%% Mostrar resumo estatístico

fprintf('\n')
fprintf('===============================================================================================================================\n')
fprintf('RESUMO ESTATÍSTICO - 85 CASOS SEM FILTRO\n')
fprintf('===============================================================================================================================\n')

fprintf('%-20s %11s %10s %10s %10s %10s %10s %10s %10s\n','Modelo','Erro médio','Mediana','Desvio','MAE','RMSE','MAD','Erro máx.','R²')

fprintf('-------------------------------------------------------------------------------------------------------------------------------\n')

fprintf('%-20s %+11.3f %+10.3f %10.3f %10.3f %10.3f %10.3f %10.3f %10.4f\n','Giovaneli',biasgio,medianagio,desviogio,maegio,rmsegio,madgio,maxgio,r2gio)

fprintf('%-20s %+11.3f %+10.3f %10.3f %10.3f %10.3f %10.3f %10.3f %10.4f\n','Deygout',biasdey,medianadey,desviodey,maedey,rmsedey,maddey,maxdey,r2dey)

fprintf('%-20s %+11.3f %+10.3f %10.3f %10.3f %10.3f %10.3f %10.3f %10.4f\n','Epstein-Peterson',biaseps,medianaeps,desvioeps,maeeps,rmseeps,madeps,maxeps,r2eps)

fprintf('===============================================================================================================================\n')

%% Mostrar métricas complementares

fprintf('\n')
fprintf('===============================================================================================================================\n')
fprintf('MÉTRICAS COMPLEMENTARES - 85 CASOS SEM FILTRO\n')
fprintf('===============================================================================================================================\n')

fprintf('%-20s %12s %12s %12s %12s %12s\n','Modelo','MAE Central','RMSE Central','Correlação','Inclinação','Intercepto')

fprintf('-------------------------------------------------------------------------------------------------------------------------------\n')

fprintf('%-20s %12.3f %12.3f %12.4f %12.4f %+12.3f\n','Giovaneli',maecentralgio,rmsecentralgio,correlacaogio,inclinacaogio,interceptogio)

fprintf('%-20s %12.3f %12.3f %12.4f %12.4f %+12.3f\n','Deygout',maecentraldey,rmsecentraldey,correlacaodey,inclinacaodey,interceptodey)

fprintf('%-20s %12.3f %12.3f %12.4f %12.4f %+12.3f\n','Epstein-Peterson',maecentraleps,rmsecentraleps,correlacaoeps,inclinacaoeps,interceptoeps)

fprintf('===============================================================================================================================\n')