clear
clc
close all

%% Definir caminhos

pastateste=fileparts(mfilename('fullpath'));

pastascripts=fileparts(pastateste);

addpath(fullfile(pastascripts,'Funções'))

pastagoogle=fullfile(pastascripts,'DadosSalvos','NTIAReais','Google63rd');

pastasaida=fullfile(pastateste,'ResultadosNTIAReaisCorrigido');

if exist(pastasaida,'dir')==0
    mkdir(pastasaida)
end

%% Conferir perfis do Google

arquivoshort=fullfile(pastagoogle,'DadosNTIA63ShortGoogle.mat');

arquivolong=fullfile(pastagoogle,'DadosNTIA63LongGoogle.mat');

if exist(arquivoshort,'file')~=2
    error('O perfil Google do short path não foi encontrado. Execute GerarRelevosNTIA63Google.m primeiro.')
end

if exist(arquivolong,'file')~=2
    error('O perfil Google do long path não foi encontrado. Execute GerarRelevosNTIA63Google.m primeiro.')
end

%% Informações da comparação

% O objetivo é comparar as funções efetivamente utilizadas pelo software
% com medições apresentadas no relatório NTIA TR-26-580.
%
% 63rd Street:
% - O relevo completo foi reconstruído com Google Elevation.
% - O próprio indexgumess identifica os obstáculos.
% - A correção do raio efetivo do software é aplicada.
%
% Table Mountain:
% - O perfil utiliza exatamente os 15 pontos publicados na Tabela 24.
% - Não é feita interpolação entre os pontos.
% - O próprio indexgumess identifica os obstáculos.
% - A correção do raio efetivo do software é aplicada.
%
% Os valores medidos foram lidos aproximadamente das Figuras 47, 48, 51
% e 52 do relatório. Eles não são fornecidos numericamente em tabelas.
% Portanto, esta análise é complementar e não deve ser interpretada como
% reprodução numérica exata das medições originais.

%% Definir frequências

freq63=[183 430 915 1602.5 2260]*10^6;

freqtable=[183 430 915 1350 1602.5 2260 5750]*10^6;

%% Definir valores medidos digitalizados das figuras

medido63short=[101.8 105.5 117.2 127.8 131.3];

medido63long=[125.2 126.9 143.0 153.4 156.3];

medidotable1=[109.5 116.5 128.5 134.0 137.0 141.5 151.5];

medidotable2=[117.5 123.5 131.5 136.0 138.5 142.5 147.0];

%% Carregar perfis da 63rd Street

dadosshort=load(arquivoshort,'dadoselev');

dadoslong=load(arquivolong,'dadoselev');

dadoselevshort=dadosshort.dadoselev;

dadoselevlong=dadoslong.dadoselev;

%% Aplicar raio efetivo aos perfis da 63rd Street

dadoselevshort=raioefetivo(dadoselevshort);

dadoselevlong=raioefetivo(dadoselevlong);

%% Definir alturas absolutas das antenas da 63rd Street

% Valores publicados nas Tabelas 20 e 21 do relatório.
% Como o Google fornece a elevação do terreno, os valores abaixo são
% convertidos em deslocamentos relativos à elevação corrigida do perfil,
% de forma que a altura final do ponto Tx/Rx coincida com a altura absoluta
% da antena publicada pela NTIA.

antenaabsolutatx=1579.2;

antenaabsolutarxshort=1563.2;

antenaabsolutarxlong=1574.2;

alturatshort=antenaabsolutatx-dadoselevshort(3,1);

alturarshort=antenaabsolutarxshort-dadoselevshort(3,end);

alturatlong=antenaabsolutatx-dadoselevlong(3,1);

alturarlong=antenaabsolutarxlong-dadoselevlong(3,end);

%% Mostrar alinhamento das antenas

fprintf('\n')
fprintf('====================================================================\n')
fprintf('ALINHAMENTO DAS ANTENAS - 63RD STREET\n')
fprintf('====================================================================\n')
fprintf('Short path\n')
fprintf('Offset Tx usado: %.3f m\n',alturatshort)
fprintf('Offset Rx usado: %.3f m\n',alturarshort)
fprintf('Altura absoluta Tx final: %.3f m\n',dadoselevshort(3,1)+alturatshort)
fprintf('Altura absoluta Rx final: %.3f m\n',dadoselevshort(3,end)+alturarshort)
fprintf('\n')
fprintf('Long path\n')
fprintf('Offset Tx usado: %.3f m\n',alturatlong)
fprintf('Offset Rx usado: %.3f m\n',alturarlong)
fprintf('Altura absoluta Tx final: %.3f m\n',dadoselevlong(3,1)+alturatlong)
fprintf('Altura absoluta Rx final: %.3f m\n',dadoselevlong(3,end)+alturarlong)
fprintf('====================================================================\n')

if alturatshort<0 || alturarshort<0 || alturatlong<0 || alturarlong<0
    warning('Um ou mais offsets de antena ficaram negativos. Isso indica diferença de referência altimétrica entre o perfil Google e os valores absolutos publicados pela NTIA.')
end

%% Criar perfil de Table Mountain exatamente como a Tabela 24

distanciatable=[0 30 60 90 120 150 180 210 240 270 300 330 360 390 400];

alturatable=[1704 1704 1705 1705 1705 1705 1706 1707 1707 1705 1696 1693 1692 1691 1690.7];

dadoselevtable=criaperfiltabela(distanciatable,alturatable);

dadoselevtable=raioefetivo(dadoselevtable);

%% Definir alturas das antenas de Table Mountain

alturat1=[1.81 1.81 0.62 0.89 0.64 0.79 0.70];

alturar1=[2.2 2.2 2.2 2.2 2.7 2.7 2.7];

alturat2=[1.0 1.0 1.0 1.71 1.71 1.61 1.52];

alturar2=[2.2 2.2 2.2 2.2 2.7 2.7 2.7];

%% Preparar resultados

cenario=strings(0,1);

frequenciamhz=zeros(0,1);

origemperfil=strings(0,1);

gumes=zeros(0,1);

indicesgumes=strings(0,1);

medido=zeros(0,1);

epstein=zeros(0,1);

deygout=zeros(0,1);

giovaneli=zeros(0,1);

%% Processar 63rd Street - short path

for i=1:length(freq63)

    freq=freq63(i);

    [indexgumes,gumesencontrados]=indexgumess(dadoselevshort,alturatshort,alturarshort,freq,false);

    [ep,dey,gio]=calculamodelos(indexgumes,dadoselevshort,freq,gumesencontrados,alturatshort,alturarshort);

    cenario(end+1,1)="63rd Street - Short";
    frequenciamhz(end+1,1)=freq/10^6;
    origemperfil(end+1,1)="Google Elevation";
    gumes(end+1,1)=gumesencontrados;
    indicesgumes(end+1,1)=string(mat2str(indexgumes));
    medido(end+1,1)=medido63short(i);
    epstein(end+1,1)=ep;
    deygout(end+1,1)=dey;
    giovaneli(end+1,1)=gio;

end

%% Processar 63rd Street - long path

for i=1:length(freq63)

    freq=freq63(i);

    [indexgumes,gumesencontrados]=indexgumess(dadoselevlong,alturatlong,alturarlong,freq,false);

    [ep,dey,gio]=calculamodelos(indexgumes,dadoselevlong,freq,gumesencontrados,alturatlong,alturarlong);

    cenario(end+1,1)="63rd Street - Long";
    frequenciamhz(end+1,1)=freq/10^6;
    origemperfil(end+1,1)="Google Elevation";
    gumes(end+1,1)=gumesencontrados;
    indicesgumes(end+1,1)=string(mat2str(indexgumes));
    medido(end+1,1)=medido63long(i);
    epstein(end+1,1)=ep;
    deygout(end+1,1)=dey;
    giovaneli(end+1,1)=gio;

end

%% Processar Table Mountain - conjunto 1

for i=1:length(freqtable)

    freq=freqtable(i);

    alturat=alturat1(i);

    alturar=alturar1(i);

    [indexgumes,gumesencontrados]=indexgumess(dadoselevtable,alturat,alturar,freq,false);

    [ep,dey,gio]=calculamodelos(indexgumes,dadoselevtable,freq,gumesencontrados,alturat,alturar);

    cenario(end+1,1)="Table Mountain - Conjunto 1";
    frequenciamhz(end+1,1)=freq/10^6;
    origemperfil(end+1,1)="Tabela 24";
    gumes(end+1,1)=gumesencontrados;
    indicesgumes(end+1,1)=string(mat2str(indexgumes));
    medido(end+1,1)=medidotable1(i);
    epstein(end+1,1)=ep;
    deygout(end+1,1)=dey;
    giovaneli(end+1,1)=gio;

end

%% Processar Table Mountain - conjunto 2

for i=1:length(freqtable)

    freq=freqtable(i);

    alturat=alturat2(i);

    alturar=alturar2(i);

    [indexgumes,gumesencontrados]=indexgumess(dadoselevtable,alturat,alturar,freq,false);

    [ep,dey,gio]=calculamodelos(indexgumes,dadoselevtable,freq,gumesencontrados,alturat,alturar);

    cenario(end+1,1)="Table Mountain - Conjunto 2";
    frequenciamhz(end+1,1)=freq/10^6;
    origemperfil(end+1,1)="Tabela 24";
    gumes(end+1,1)=gumesencontrados;
    indicesgumes(end+1,1)=string(mat2str(indexgumes));
    medido(end+1,1)=medidotable2(i);
    epstein(end+1,1)=ep;
    deygout(end+1,1)=dey;
    giovaneli(end+1,1)=gio;

end

%% Calcular erros

erroepstein=epstein-medido;

errodeygout=deygout-medido;

errogiovaneli=giovaneli-medido;

%% Criar tabela completa

resultado=table(cenario,frequenciamhz,origemperfil,gumes,indicesgumes,medido,epstein,erroepstein,deygout,errodeygout,giovaneli,errogiovaneli);

resultado.Properties.VariableNames={'Cenario','FrequenciaMHz','OrigemPerfil','Gumes','IndicesGumes','Medido','EpsteinPeterson','ErroEpstein','Deygout','ErroDeygout','Giovaneli','ErroGiovaneli'};

%% Calcular métricas gerais

metricas=calculametricas("Epstein-Peterson",epstein,medido);

metricas=[metricas;calculametricas("Deygout",deygout,medido)];

metricas=[metricas;calculametricas("Giovaneli",giovaneli,medido)];

%% Calcular métricas por cenário

cenariosunicos=unique(cenario,'stable');

metricascenario=table;

for i=1:length(cenariosunicos)

    mascara=cenario==cenariosunicos(i);

    metricascenario=[metricascenario;calculametricascenario(cenariosunicos(i),"Epstein-Peterson",epstein(mascara),medido(mascara))];

    metricascenario=[metricascenario;calculametricascenario(cenariosunicos(i),"Deygout",deygout(mascara),medido(mascara))];

    metricascenario=[metricascenario;calculametricascenario(cenariosunicos(i),"Giovaneli",giovaneli(mascara),medido(mascara))];

end

%% Mostrar resultados caso a caso

fprintf('\n')
fprintf('====================================================================================================================\n')
fprintf('                         SOFTWARE X MEDIÇÕES REAIS DA NTIA\n')
fprintf('====================================================================================================================\n')
fprintf('| %-27s | %8s | %5s | %8s | %10s | %10s | %10s |\n','Cenário','Freq.','Gumes','Medido','Epstein','Deygout','Giovaneli')
fprintf('--------------------------------------------------------------------------------------------------------------------\n')

for i=1:height(resultado)

    fprintf('| %-27s | %8.1f | %5d | %8.2f | %10.2f | %10.2f | %10.2f |\n',char(resultado.Cenario(i)),resultado.FrequenciaMHz(i),resultado.Gumes(i),resultado.Medido(i),resultado.EpsteinPeterson(i),resultado.Deygout(i),resultado.Giovaneli(i))

end

fprintf('====================================================================================================================\n')

%% Mostrar métricas gerais

fprintf('\n')
fprintf('====================================================================================================================\n')
fprintf('                                  MÉTRICAS GERAIS CONTRA DADOS MEDIDOS\n')
fprintf('====================================================================================================================\n')
fprintf('| %-25s | %12s | %12s | %12s |\n','Métrica','Epstein-Pet.','Deygout','Giovaneli')
fprintf('--------------------------------------------------------------------------------------------------------------------\n')

fprintf('| %-25s | %+12.3f | %+12.3f | %+12.3f |\n','Erro médio / Bias (dB)',metricas.MediaErro)

fprintf('| %-25s | %+12.3f | %+12.3f | %+12.3f |\n','Mediana do erro (dB)',metricas.MedianaErro)

fprintf('| %-25s | %12.3f | %12.3f | %12.3f |\n','Desvio-padrão (dB)',metricas.DesvioErro)

fprintf('| %-25s | %12.3f | %12.3f | %12.3f |\n','MAE (dB)',metricas.MAE)

fprintf('| %-25s | %12.3f | %12.3f | %12.3f |\n','RMSE (dB)',metricas.RMSE)

fprintf('| %-25s | %12.3f | %12.3f | %12.3f |\n','MAE centralizado (dB)',metricas.MAECentralizado)

fprintf('| %-25s | %12.3f | %12.3f | %12.3f |\n','RMSE centralizado (dB)',metricas.RMSECentralizado)

fprintf('| %-25s | %12.3f | %12.3f | %12.3f |\n','MAD (dB)',metricas.MAD)

fprintf('| %-25s | %12.3f | %12.3f | %12.3f |\n','Erro máximo (dB)',metricas.ErroMaximoAbsoluto)

fprintf('| %-25s | %12.4f | %12.4f | %12.4f |\n','Correlação',metricas.Correlacao)

fprintf('| %-25s | %12.4f | %12.4f | %12.4f |\n','R²',metricas.R2)

fprintf('| %-25s | %12.4f | %12.4f | %12.4f |\n','Inclinação',metricas.Inclinacao)

fprintf('| %-25s | %+12.3f | %+12.3f | %+12.3f |\n','Intercepto (dB)',metricas.Intercepto)

fprintf('====================================================================================================================\n')

%% Mostrar métricas por cenário

fprintf('\n')
fprintf('====================================================================================================================\n')
fprintf('                                     MÉTRICAS POR CENÁRIO\n')
fprintf('====================================================================================================================\n')

disp(metricascenario)

%% Salvar resultados

writetable(resultado,fullfile(pastasaida,'ResultadosNTIAReaisCorrigido.csv'));

writetable(metricas,fullfile(pastasaida,'MetricasGeraisNTIAReaisCorrigido.csv'));

writetable(metricascenario,fullfile(pastasaida,'MetricasPorCenarioNTIAReaisCorrigido.csv'));

save(fullfile(pastasaida,'TesteValidacaoNTIAReaisCorrigido.mat'),'resultado','metricas','metricascenario','dadoselevshort','dadoselevlong','dadoselevtable','alturatshort','alturarshort','alturatlong','alturarlong','medido63short','medido63long','medidotable1','medidotable2');

%% Finalizar

fprintf('\n')
fprintf('ATENÇÃO: os valores medidos foram digitalizados aproximadamente das Figuras 47, 48, 51 e 52.\n')
fprintf('Os perfis da 63rd Street foram reconstruídos com Google Elevation a partir da localização pública do Ryssby Church.\n')
fprintf('O perfil de Table Mountain utiliza exatamente os pontos da Tabela 24, sem interpolação.\n')

fprintf('\nResultados salvos em:\n')
fprintf('%s\n',pastasaida)

%% Criar perfil geográfico a partir da tabela

function dadoselev=criaperfiltabela(distancia,altura)

wgs84=wgs84Ellipsoid("m");

raio=wgs84.SemimajorAxis;

latitude=zeros(size(distancia));

longitude=(distancia/raio)*(180/pi);

dadoselev=[latitude;longitude;altura];

end

%% Calcular os três modelos

function [epstein,deygout,giovaneli]=calculamodelos(indexgumes,dadoselev,freq,gumes,alturat,alturar)

lambda=(3*10^8)/freq;

dtotal=txrx(1,size(dadoselev,2),alturat,alturar,dadoselev);

perdalivre=-10*log10((lambda^2)/(((4*pi)^2)*(dtotal^2)));

perda=perdaepstein(indexgumes,dadoselev,freq,gumes,alturar,alturat);

epstein=perdalivre-perda;

perda=perdadeygout(indexgumes,dadoselev,freq,gumes,alturar,alturat);

deygout=perdalivre-perda;

perda=perdagiovaneli(indexgumes,dadoselev,freq,gumes,alturar,alturat);

giovaneli=perdalivre-perda;

epstein=real(epstein);

deygout=real(deygout);

giovaneli=real(giovaneli);

end

%% Calcular as 13 métricas

function metricas=calculametricas(metodo,estimado,referencia)

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

metricas=table(metodo,mediaerro,medianaerro,desvioerro,mae,rmse,maecentralizado,rmsecentralizado,maderro,erromaximo,correlacao,inclinacao,intercepto,r2);

metricas.Properties.VariableNames={'Metodo','MediaErro','MedianaErro','DesvioErro','MAE','RMSE','MAECentralizado','RMSECentralizado','MAD','ErroMaximoAbsoluto','Correlacao','Inclinacao','Intercepto','R2'};

end

%% Calcular métricas resumidas por cenário

function metricas=calculametricascenario(cenario,metodo,estimado,referencia)

erro=estimado-referencia;

casos=length(erro);

mediaerro=mean(erro);

mae=mean(abs(erro));

rmse=sqrt(mean(erro.^2));

erromaximo=max(abs(erro));

metricas=table(cenario,metodo,casos,mediaerro,mae,rmse,erromaximo);

metricas.Properties.VariableNames={'Cenario','Metodo','Casos','MediaErro','MAE','RMSE','ErroMaximoAbsoluto'};

end
