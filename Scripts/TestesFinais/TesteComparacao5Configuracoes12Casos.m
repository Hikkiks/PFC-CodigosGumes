clear
clc
close all

%% Definir caminhos

pastateste=fileparts(mfilename('fullpath'));

pastascripts=fileparts(pastateste);

addpath(fullfile(pastascripts,'Funções'))

pastaperfis=fullfile(pastascripts,'DadosSalvos','DadosConclusao');

pastasaida=fullfile(pastateste,'ResultadosComparacao5Configuracoes12Casos');

if exist(pastasaida,'dir')==0
    mkdir(pastasaida)
end

%% Definir configurações

configs=[206554 203964 200330 206074 67399];

nomes=["h reduzido";
       "Consistência linear";
       "Equilíbrio global";
       "Menor MAE 85";
       "Selecionada 12 casos"];

valoresh=[0.375 1.750 1.750 1.250 0.250];

valoresv=[0.100 0.060 0.400 0.350 0.090];

valoresangulo=[0.400 0.250 0.100 0.350 0.750];

valoresdistancia=[Inf Inf Inf Inf 100];

nconfig=length(configs);

%% Definir dados das emissoras

freq=[557.142857*10^6 581.142857*10^6];

alturat=[76.2 113];

alturar=1.5;

%% Definir distâncias apresentadas por Lorenço

distancias=[4.76007 4.90242 5.57821 11.62309 10.55351 15.94797;
            3.93443 4.15807 6.28328 12.03950 11.27558 16.73901];

%% Definir ERP em cada ponto

erp=[0.05631 1.49906 5.09155 3.01382 3.23998 2.12244;
     0.32496 1.13006 3.22440 3.14907 3.08243 3.10165];

%% Definir resultados de Giovaneli apresentados por Lorenço

giolorenco=[60.90812 68.02893 68.38195 65.51763 69.00870 69.05509;
            77.91189 78.03863 71.02870 67.12174 66.92914 75.73337];

%% Definir valores medidos

medido=[64.6 65.3 67.3 64.1 66.9 65.7;
        78.9 78.3 72.0 64.5 66.8 65.0];

%% Definir gumes apresentados por Lorenço

gumeslorenco=[3 3 4 3 3 2;
              2 2 3 3 3 1];

%% Preparar vetores de resultados

campocalculado=zeros(12,nconfig);

errocalculado=zeros(12,nconfig);

gumescalculados=zeros(12,nconfig);

gumesoriginais=zeros(12,1);

campolivre=zeros(12,1);

casos=strings(12,1);

giolorencovetor=zeros(12,1);

medidovetor=zeros(12,1);

gumeslorencovetor=zeros(12,1);

%% Processar os 12 casos

linha=0;

for emissora=1:2

    for ponto=1:6

        linha=linha+1;

        casos(linha)="E"+string(emissora)+"-P"+string(ponto);

        %% Carregar perfil

        nomearquivo=['DadosConclusaoE' num2str(emissora) 'P' num2str(ponto) '.mat'];

        caminhoarquivo=fullfile(pastaperfis,nomearquivo);

        if exist(caminhoarquivo,'file')~=2
            error(['Perfil não encontrado: ' caminhoarquivo])
        end

        dadosarquivo=load(caminhoarquivo,'dadoselev');

        dadoselev=dadosarquivo.dadoselev;

        %% Aplicar correção do raio efetivo

        dadoselev=raioefetivo(dadoselev);

        %% Identificar gumes originais

        [indexoriginal,gumesoriginal]=indexgumess(dadoselev,alturat(emissora),alturar,freq(emissora),false);

        gumesoriginais(linha)=gumesoriginal;

        %% Preparar geometria dos gumes

        geometria=preparageometria(indexoriginal,dadoselev,alturat(emissora),alturar,freq(emissora));

        %% Calcular campo sem perda de difração

        erpkw=erp(emissora,ponto);

        distkm=distancias(emissora,ponto);

        campolivre(linha)=100+10*log10((4.92*erpkw)/(distkm^2));

        %% Armazenar referências

        giolorencovetor(linha)=giolorenco(emissora,ponto);

        medidovetor(linha)=medido(emissora,ponto);

        gumeslorencovetor(linha)=gumeslorenco(emissora,ponto);

        %% Aplicar configurações

        for c=1:nconfig

            indexfiltrado=aplicafiltrodinamico(indexoriginal,geometria,valoresh(c),valoresv(c),valoresangulo(c),valoresdistancia(c));

            gumes=length(indexfiltrado);

            gumescalculados(linha,c)=gumes;

            perda=perdagiovaneli(indexfiltrado,dadoselev,freq(emissora),gumes,alturar,alturat(emissora));

            perdadif=-perda;

            campocalculado(linha,c)=campolivre(linha)-perdadif;

            errocalculado(linha,c)=campocalculado(linha,c)-medidovetor(linha);

        end

    end

end

%% Calcular métricas de campo

erromedio=zeros(1,nconfig);

medianaerro=zeros(1,nconfig);

desvioerro=zeros(1,nconfig);

mae=zeros(1,nconfig);

rmse=zeros(1,nconfig);

maecentralizado=zeros(1,nconfig);

rmsecentralizado=zeros(1,nconfig);

maderro=zeros(1,nconfig);

erromaximo=zeros(1,nconfig);

correlacao=zeros(1,nconfig);

r2=zeros(1,nconfig);

inclinacao=zeros(1,nconfig);

intercepto=zeros(1,nconfig);

maelorenzo=zeros(1,nconfig);

for c=1:nconfig

    erro=errocalculado(:,c);

    erromedio(c)=mean(erro);

    medianaerro(c)=median(erro);

    desvioerro(c)=std(erro,1);

    mae(c)=mean(abs(erro));

    rmse(c)=sqrt(mean(erro.^2));

    errocentralizado=erro-mean(erro);

    maecentralizado(c)=mean(abs(errocentralizado));

    rmsecentralizado(c)=sqrt(mean(errocentralizado.^2));

    maderro(c)=median(abs(erro-median(erro)));

    erromaximo(c)=max(abs(erro));

    matriz=corrcoef(campocalculado(:,c),medidovetor);

    correlacao(c)=matriz(1,2);

    r2(c)=correlacao(c)^2;

    ajuste=polyfit(medidovetor,campocalculado(:,c),1);

    inclinacao(c)=ajuste(1);

    intercepto(c)=ajuste(2);

    maelorenzo(c)=mean(abs(campocalculado(:,c)-giolorencovetor));

end

%% Calcular métricas dos gumes

totalgumes=zeros(1,nconfig);

gumesremovidos=zeros(1,nconfig);

acertosgumes=zeros(1,nconfig);

errototalgumes=zeros(1,nconfig);

maegumes=zeros(1,nconfig);

biasgumes=zeros(1,nconfig);

casosalterados=zeros(1,nconfig);

totaloriginal=sum(gumesoriginais);

totallorenco=sum(gumeslorencovetor);

for c=1:nconfig

    totalgumes(c)=sum(gumescalculados(:,c));

    gumesremovidos(c)=sum(gumesoriginais-gumescalculados(:,c));

    acertosgumes(c)=sum(gumescalculados(:,c)==gumeslorencovetor);

    diferencagumes=gumescalculados(:,c)-gumeslorencovetor;

    errototalgumes(c)=sum(abs(diferencagumes));

    maegumes(c)=mean(abs(diferencagumes));

    biasgumes(c)=mean(diferencagumes);

    casosalterados(c)=sum(gumescalculados(:,c)~=gumesoriginais);

end

%% Calcular métricas de Lorenço em relação ao medido

errolorenco=giolorencovetor-medidovetor;

biasreferencia=mean(errolorenco);

medianareferencia=median(errolorenco);

desvioreferencia=std(errolorenco,1);

maereferencia=mean(abs(errolorenco));

rmsereferencia=sqrt(mean(errolorenco.^2));

errocentralizadoreferencia=errolorenco-biasreferencia;

maecentralizadoreferencia=mean(abs(errocentralizadoreferencia));

rmsecentralizadoreferencia=sqrt(mean(errocentralizadoreferencia.^2));

madreferencia=median(abs(errolorenco-medianareferencia));

erromaximoreferencia=max(abs(errolorenco));

matriz=corrcoef(giolorencovetor,medidovetor);

correlacaoreferencia=matriz(1,2);

r2referencia=correlacaoreferencia^2;

ajuste=polyfit(medidovetor,giolorencovetor,1);

inclinacaoreferencia=ajuste(1);

interceptoreferencia=ajuste(2);

%% Mostrar configurações avaliadas

fprintf('\n')
fprintf('====================================================================================================\n')
fprintf('                              CONFIGURAÇÕES AVALIADAS NOS 12 CASOS\n')
fprintf('====================================================================================================\n')
fprintf('| %-8s | %-22s | %8s | %7s | %11s | %14s |\n','Config.','Característica','h (m)','v','Ângulo (°)','Distância (m)')
fprintf('----------------------------------------------------------------------------------------------------\n')

for c=1:nconfig

    if isinf(valoresdistancia(c))

        textodistancia='Sem limite';

    else

        textodistancia=sprintf('%.0f',valoresdistancia(c));

    end

    fprintf('| %-8d | %-22s | %8.3f | %7.3f | %11.3f | %14s |\n',configs(c),char(nomes(c)),valoresh(c),valoresv(c),valoresangulo(c),textodistancia)

end

fprintf('====================================================================================================\n')

%% Mostrar métricas completas

fprintf('\n')
fprintf('=========================================================================================================================\n')
fprintf('                                    DESEMPENHO NOS 12 VALORES MEDIDOS\n')
fprintf('=========================================================================================================================\n')
fprintf('| %-25s | %10s | %10d | %10d | %10d | %10d | %10d |\n','Métrica','Lorenço',configs(1),configs(2),configs(3),configs(4),configs(5))
fprintf('-------------------------------------------------------------------------------------------------------------------------\n')

fprintf('| %-25s | %+10.3f | %+10.3f | %+10.3f | %+10.3f | %+10.3f | %+10.3f |\n','Erro médio / Bias (dB)',biasreferencia,erromedio)

fprintf('| %-25s | %+10.3f | %+10.3f | %+10.3f | %+10.3f | %+10.3f | %+10.3f |\n','Mediana do erro (dB)',medianareferencia,medianaerro)

fprintf('| %-25s | %10.3f | %10.3f | %10.3f | %10.3f | %10.3f | %10.3f |\n','Desvio-padrão (dB)',desvioreferencia,desvioerro)

fprintf('| %-25s | %10.3f | %10.3f | %10.3f | %10.3f | %10.3f | %10.3f |\n','MAE (dB)',maereferencia,mae)

fprintf('| %-25s | %10.3f | %10.3f | %10.3f | %10.3f | %10.3f | %10.3f |\n','RMSE (dB)',rmsereferencia,rmse)

fprintf('| %-25s | %10.3f | %10.3f | %10.3f | %10.3f | %10.3f | %10.3f |\n','MAE centralizado (dB)',maecentralizadoreferencia,maecentralizado)

fprintf('| %-25s | %10.3f | %10.3f | %10.3f | %10.3f | %10.3f | %10.3f |\n','RMSE centralizado (dB)',rmsecentralizadoreferencia,rmsecentralizado)

fprintf('| %-25s | %10.3f | %10.3f | %10.3f | %10.3f | %10.3f | %10.3f |\n','MAD (dB)',madreferencia,maderro)

fprintf('| %-25s | %10.3f | %10.3f | %10.3f | %10.3f | %10.3f | %10.3f |\n','Erro máximo (dB)',erromaximoreferencia,erromaximo)

fprintf('| %-25s | %10.4f | %10.4f | %10.4f | %10.4f | %10.4f | %10.4f |\n','Correlação',correlacaoreferencia,correlacao)

fprintf('| %-25s | %10.4f | %10.4f | %10.4f | %10.4f | %10.4f | %10.4f |\n','R²',r2referencia,r2)

fprintf('| %-25s | %10.4f | %10.4f | %10.4f | %10.4f | %10.4f | %10.4f |\n','Inclinação',inclinacaoreferencia,inclinacao)

fprintf('| %-25s | %+10.3f | %+10.3f | %+10.3f | %+10.3f | %+10.3f | %+10.3f |\n','Intercepto (dB)',interceptoreferencia,intercepto)

fprintf('-------------------------------------------------------------------------------------------------------------------------\n')

fprintf('| %-25s | %10.3f | %10.3f | %10.3f | %10.3f | %10.3f | %10.3f |\n','MAE vs Lorenço (dB)',0,maelorenzo)

fprintf('=========================================================================================================================\n')

%% Mostrar efeito dos filtros sobre os gumes

fprintf('\n')
fprintf('===================================================================================================================\n')
fprintf('                                      EFEITO DOS FILTROS SOBRE OS GUMES\n')
fprintf('===================================================================================================================\n')
fprintf('Gumes originais antes do filtro: %d\n',totaloriginal)
fprintf('Gumes apresentados por Lorenço:  %d\n',totallorenco)
fprintf('-------------------------------------------------------------------------------------------------------------------\n')
fprintf('| %-25s | %10d | %10d | %10d | %10d | %10d |\n','Métrica',configs(1),configs(2),configs(3),configs(4),configs(5))
fprintf('-------------------------------------------------------------------------------------------------------------------\n')

fprintf('| %-25s | %10d | %10d | %10d | %10d | %10d |\n','Gumes finais',totalgumes)

fprintf('| %-25s | %10d | %10d | %10d | %10d | %10d |\n','Gumes removidos',gumesremovidos)

fprintf('| %-25s | %7d/12 | %7d/12 | %7d/12 | %7d/12 | %7d/12 |\n','Acertos exatos',acertosgumes)

fprintf('| %-25s | %10d | %10d | %10d | %10d | %10d |\n','Erro absoluto total',errototalgumes)

fprintf('| %-25s | %10.3f | %10.3f | %10.3f | %10.3f | %10.3f |\n','MAE dos gumes',maegumes)

fprintf('| %-25s | %+10.3f | %+10.3f | %+10.3f | %+10.3f | %+10.3f |\n','Bias dos gumes',biasgumes)

fprintf('| %-25s | %7d/12 | %7d/12 | %7d/12 | %7d/12 | %7d/12 |\n','Casos alterados',casosalterados)

fprintf('===================================================================================================================\n')

%% Mostrar campo calculado caso a caso

fprintf('\n')
fprintf('===============================================================================================================================\n')
fprintf('                                             CAMPO CALCULADO CASO A CASO\n')
fprintf('===============================================================================================================================\n')
fprintf('| %-7s | %9s | %9s | %9d | %9d | %9d | %9d | %9d |\n','Caso','Medido','Lorenço',configs(1),configs(2),configs(3),configs(4),configs(5))
fprintf('-------------------------------------------------------------------------------------------------------------------------------\n')

for caso=1:12

    fprintf('| %-7s | %9.2f | %9.2f | %9.2f | %9.2f | %9.2f | %9.2f | %9.2f |\n',char(casos(caso)),medidovetor(caso),giolorencovetor(caso),campocalculado(caso,1),campocalculado(caso,2),campocalculado(caso,3),campocalculado(caso,4),campocalculado(caso,5))

end

fprintf('===============================================================================================================================\n')

%% Mostrar gumes filtrados caso a caso

fprintf('\n')
fprintf('===================================================================================================================================\n')
fprintf('                                               GUMES FILTRADOS CASO A CASO\n')
fprintf('===================================================================================================================================\n')
fprintf('| %-7s | %9s | %9s | %9d | %9d | %9d | %9d | %9d |\n','Caso','Original','Lorenço',configs(1),configs(2),configs(3),configs(4),configs(5))
fprintf('-----------------------------------------------------------------------------------------------------------------------------------\n')

for caso=1:12

    fprintf('| %-7s | %9d | %9d | %9d | %9d | %9d | %9d | %9d |\n',char(casos(caso)),gumesoriginais(caso),gumeslorencovetor(caso),gumescalculados(caso,1),gumescalculados(caso,2),gumescalculados(caso,3),gumescalculados(caso,4),gumescalculados(caso,5))

end

fprintf('-----------------------------------------------------------------------------------------------------------------------------------\n')
fprintf('| %-7s | %9d | %9d | %9d | %9d | %9d | %9d | %9d |\n','TOTAL',totaloriginal,totallorenco,totalgumes(1),totalgumes(2),totalgumes(3),totalgumes(4),totalgumes(5))
fprintf('===================================================================================================================================\n')

%% Criar tabela de resumo

Configuracao=configs';

Caracteristica=nomes;

h=valoresh';

v=valoresv';

Angulo=valoresangulo';

Distancia=valoresdistancia';

ErroMedio=erromedio';

Mediana=medianaerro';

DesvioPadrao=desvioerro';

MAE=mae';

RMSE=rmse';

MAECentralizado=maecentralizado';

RMSECentralizado=rmsecentralizado';

MAD=maderro';

ErroMaximo=erromaximo';

Correlacao=correlacao';

R2=r2';

Inclinacao=inclinacao';

Intercepto=intercepto';

MAEVsLorenco=maelorenzo';

GumesFinais=totalgumes';

GumesRemovidos=gumesremovidos';

AcertosGumes=acertosgumes';

ErroTotalGumes=errototalgumes';

MAEGumes=maegumes';

BiasGumes=biasgumes';

CasosAlterados=casosalterados';

resumo=table(Configuracao,Caracteristica,h,v,Angulo,Distancia,ErroMedio,Mediana,DesvioPadrao,MAE,RMSE,MAECentralizado,RMSECentralizado,MAD,ErroMaximo,Correlacao,R2,Inclinacao,Intercepto,MAEVsLorenco,GumesFinais,GumesRemovidos,AcertosGumes,ErroTotalGumes,MAEGumes,BiasGumes,CasosAlterados);

%% Salvar resultados

arquivoresumo=fullfile(pastasaida,'Comparacao5Configuracoes12Casos.csv');

writetable(resumo,arquivoresumo);

save(fullfile(pastasaida,'Comparacao5Configuracoes12Casos.mat'),'resumo','campocalculado','errocalculado','gumescalculados','gumesoriginais','casos','medidovetor','giolorencovetor','gumeslorencovetor');

fprintf('\n')
fprintf('Resultados salvos em:\n')
fprintf('%s\n',pastasaida)