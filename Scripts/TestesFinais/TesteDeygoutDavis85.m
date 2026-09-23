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

%% Ler dados do Lorenço

arquivo=fopen(arquivotxt,'r');

dados=textscan(arquivo,'%s %s %s %s %s %f');

fclose(arquivo);

deygoutlorenco=str2double(strrep(dados{4},',','.'));

giovanelilorenco=str2double(strrep(dados{5},',','.'));

gumeslorenco=dados{6};

quantidade=length(gumeslorenco);

%% Preparar resultados

deygoutnormal=zeros(quantidade,1);

deygoutdavis=zeros(quantidade,1);

gumeslucas=zeros(quantidade,1);

difgumes=zeros(quantidade,1);

diflorencodey=zeros(quantidade,1);

difnormal=zeros(quantidade,1);

difdavis=zeros(quantidade,1);

%% Mostrar cabeçalho

fprintf('\n')

fprintf('--------------------------------------------------------------------------------------------------------------------------------------------------\n')

fprintf('Linha |     Gumes      | Giovaneli | Deygout Lorenco | Deygout Normal | Deygout Davis |        Diferenca para Giovaneli Lorenco\n')

fprintf('      | Lucas  Lorenco |  Lorenco  |                 |                |               | Lorenco Deygout   Normal    Davis\n')

fprintf('--------------------------------------------------------------------------------------------------------------------------------------------------\n')

%% Comparar os 85 casos

for i=1:1:quantidade

    %% Carregar relevo

    nomearquivo=['DadosElevLorenco' num2str(i) '.mat'];

    caminhoarquivo=fullfile(pastarelevos,nomearquivo);

    load(caminhoarquivo,'dadoselev');

    %% Corrigir raio efetivo

    dadoselev=raioefetivo(dadoselev);

    %% Identificar gumes

    [indexgumes,gumes]=indexgumess(dadoselev,alturat,alturar,freq,false);

    gumeslucas(i)=gumes;

    difgumes(i)=gumes-gumeslorenco(i);

    %% Calcular Deygout convencional

    perda=perdadeygout(indexgumes,dadoselev,freq,gumes,alturar,alturat);

    deygoutnormal(i)=-perda;

    %% Calcular Deygout com Causebrook e Davis

    perda=perdadeygoutdavis(indexgumes,dadoselev,freq,gumes,alturar,alturat);

    deygoutdavis(i)=-perda;

    %% Calcular diferenças em relação ao Giovaneli de Lorenço

    diflorencodey(i)=deygoutlorenco(i)-giovanelilorenco(i);

    difnormal(i)=deygoutnormal(i)-giovanelilorenco(i);

    difdavis(i)=deygoutdavis(i)-giovanelilorenco(i);

    %% Mostrar resultados

    fprintf('%5d | %5d %7d | %9.2f | %15.2f | %14.2f | %13.2f | %15.2f %8.2f %8.2f\n',i,gumes,gumeslorenco(i),giovanelilorenco(i),deygoutlorenco(i),deygoutnormal(i),deygoutdavis(i),diflorencodey(i),difnormal(i),difdavis(i));

end

fprintf('--------------------------------------------------------------------------------------------------------------------------------------------------\n')

%% Calcular resumo geral

maelorenco=mean(abs(diflorencodey));

maenormal=mean(abs(difnormal));

maedavis=mean(abs(difdavis));

rmseLorenco=sqrt(mean(diflorencodey.^2));

rmsenormal=sqrt(mean(difnormal.^2));

rmsedavis=sqrt(mean(difdavis.^2));

fprintf('\n')

fprintf('RESULTADO GERAL - REFERENCIA: GIOVANELI DE LORENCO\n')

fprintf('--------------------------------------------------------------------------------\n')

fprintf('Metodo                    MAE (dB)       RMSE (dB)       Delta medio (dB)\n')

fprintf('--------------------------------------------------------------------------------\n')

fprintf('Deygout Lorenco          %8.3f        %8.3f          %8.3f\n',maelorenco,rmseLorenco,mean(diflorencodey));

fprintf('Deygout Lucas            %8.3f        %8.3f          %8.3f\n',maenormal,rmsenormal,mean(difnormal));

fprintf('Deygout Davis            %8.3f        %8.3f          %8.3f\n',maedavis,rmsedavis,mean(difdavis));

fprintf('--------------------------------------------------------------------------------\n')

%% Analisar casos com mesma quantidade de gumes

mascara=difgumes==0;

if any(mascara)

    maelorencoigual=mean(abs(diflorencodey(mascara)));

    maenormaligual=mean(abs(difnormal(mascara)));

    maedavisigual=mean(abs(difdavis(mascara)));

    rmselorencoigual=sqrt(mean(diflorencodey(mascara).^2));

    rmsenormaligual=sqrt(mean(difnormal(mascara).^2));

    rmsedavisigual=sqrt(mean(difdavis(mascara).^2));

    fprintf('\n')

    fprintf('CASOS COM A MESMA QUANTIDADE DE GUMES\n')

    fprintf('Quantidade de casos: %d\n',sum(mascara))

    fprintf('--------------------------------------------------------------------------------\n')

    fprintf('Metodo                    MAE (dB)       RMSE (dB)       Delta medio (dB)\n')

    fprintf('--------------------------------------------------------------------------------\n')

    fprintf('Deygout Lorenco          %8.3f        %8.3f          %8.3f\n',maelorencoigual,rmselorencoigual,mean(diflorencodey(mascara)));

    fprintf('Deygout Lucas            %8.3f        %8.3f          %8.3f\n',maenormaligual,rmsenormaligual,mean(difnormal(mascara)));

    fprintf('Deygout Davis            %8.3f        %8.3f          %8.3f\n',maedavisigual,rmsedavisigual,mean(difdavis(mascara)));

    fprintf('--------------------------------------------------------------------------------\n')

end

%% Comparar efeito da correção de Causebrook e Davis

melhoradavis=abs(difdavis)<abs(difnormal);

empatadavis=abs(difdavis)==abs(difnormal);

pioradavis=abs(difdavis)>abs(difnormal);

fprintf('\n')

fprintf('EFEITO DA CORRECAO DE CAUSEBROOK E DAVIS\n')

fprintf('-------------------------------------------------------------\n')

fprintf('Davis mais proximo do Giovaneli: %d de %d casos\n',sum(melhoradavis),quantidade)

fprintf('Mesmo erro:                     %d de %d casos\n',sum(empatadavis),quantidade)

fprintf('Davis mais distante:            %d de %d casos\n',sum(pioradavis),quantidade)

fprintf('-------------------------------------------------------------\n')