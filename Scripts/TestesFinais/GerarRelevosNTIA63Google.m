clear
clc
close all

%% Definir caminhos

pastateste=fileparts(mfilename('fullpath'));

pastascripts=fileparts(pastateste);

addpath(fullfile(pastascripts,'Funções'))

pastasaida=fullfile(pastascripts,'DadosSalvos','NTIAReais','Google63rd');

if exist(pastasaida,'dir')==0
    mkdir(pastasaida)
end

%% Carregar chave da API

API_KEY=getenv('GOOGLE_ELEVATION_API_KEY');

if isempty(API_KEY)==true
    error('Defina a variável de ambiente GOOGLE_ELEVATION_API_KEY.')
end

%% Definir coordenada do transmissor

% O relatório informa que o transmissor estava no Ryssby Church e que os
% caminhos seguem a 63rd Street em direção norte e sul.
%
% Coordenada pública utilizada para o Ryssby Church:
% 40.139700 N, -105.205600 W.
%
% A coordenada exata do veículo transmissor não é fornecida numericamente
% no relatório. Por isso, este perfil é uma reconstrução geográfica do
% caminho, e não uma reprodução das coordenadas originais da campanha.

latitudetx=40.139700;

longitudetx=-105.205600;

%% Definir caminhos da NTIA

distanciashort=1380;

distancialong=7110;

amostrasshort=round(distanciashort/30)+1;

amostraslong=round(distancialong/30)+1;

%% Calcular coordenadas dos receptores

wgs84=wgs84Ellipsoid("m");

latituderxshort=fzero(@(latitude) distance(latitudetx,longitudetx,latitude,longitudetx,wgs84)-distanciashort,[latitudetx latitudetx+0.1]);

longituderxshort=longitudetx;

latituderxlong=fzero(@(latitude) distance(latitudetx,longitudetx,latitude,longitudetx,wgs84)-distancialong,[latitudetx-0.1 latitudetx]);

longituderxlong=longitudetx;

%% Mostrar coordenadas

fprintf('\n')
fprintf('============================================================\n')
fprintf('CAMINHOS RECONSTRUÍDOS DA 63RD STREET\n')
fprintf('============================================================\n')
fprintf('Transmissor - Ryssby Church\n')
fprintf('Latitude:  %.8f\n',latitudetx)
fprintf('Longitude: %.8f\n',longitudetx)
fprintf('\n')
fprintf('Short path - norte\n')
fprintf('Distância nominal: %.0f m\n',distanciashort)
fprintf('Amostras: %d\n',amostrasshort)
fprintf('Latitude Rx:  %.8f\n',latituderxshort)
fprintf('Longitude Rx: %.8f\n',longituderxshort)
fprintf('\n')
fprintf('Long path - sul\n')
fprintf('Distância nominal: %.0f m\n',distancialong)
fprintf('Amostras: %d\n',amostraslong)
fprintf('Latitude Rx:  %.8f\n',latituderxlong)
fprintf('Longitude Rx: %.8f\n',longituderxlong)
fprintf('============================================================\n')

%% Consultar Google Elevation - short path

fprintf('\nConsultando Google Elevation para o short path.\n')

dadoselev=dadoselevgoogle(latitudetx,longitudetx,latituderxshort,longituderxshort,amostrasshort,API_KEY);

distancianominal=distanciashort;

amostras=amostrasshort;

sentido="Norte";

latituderx=latituderxshort;

longituderx=longituderxshort;

nomecaminho="63rd Street - Short";

save(fullfile(pastasaida,'DadosNTIA63ShortGoogle.mat'),'dadoselev','distancianominal','amostras','sentido','latitudetx','longitudetx','latituderx','longituderx','nomecaminho');

tabelashort=table(dadoselev(1,:)',dadoselev(2,:)',dadoselev(3,:)');

tabelashort.Properties.VariableNames={'Latitude','Longitude','Elevacao'};

writetable(tabelashort,fullfile(pastasaida,'DadosNTIA63ShortGoogle.csv'));

%% Consultar Google Elevation - long path

fprintf('Consultando Google Elevation para o long path.\n')

dadoselev=dadoselevgoogle(latitudetx,longitudetx,latituderxlong,longituderxlong,amostraslong,API_KEY);

distancianominal=distancialong;

amostras=amostraslong;

sentido="Sul";

latituderx=latituderxlong;

longituderx=longituderxlong;

nomecaminho="63rd Street - Long";

save(fullfile(pastasaida,'DadosNTIA63LongGoogle.mat'),'dadoselev','distancianominal','amostras','sentido','latitudetx','longitudetx','latituderx','longituderx','nomecaminho');

tabelalong=table(dadoselev(1,:)',dadoselev(2,:)',dadoselev(3,:)');

tabelalong.Properties.VariableNames={'Latitude','Longitude','Elevacao'};

writetable(tabelalong,fullfile(pastasaida,'DadosNTIA63LongGoogle.csv'));

%% Recarregar perfis para conferência

short=load(fullfile(pastasaida,'DadosNTIA63ShortGoogle.mat'));

long=load(fullfile(pastasaida,'DadosNTIA63LongGoogle.mat'));

%% Calcular distâncias reais dos perfis

distshort=calculadistancia(short.dadoselev);

distlong=calculadistancia(long.dadoselev);

%% Mostrar conferência

fprintf('\n')
fprintf('============================================================\n')
fprintf('CONFERÊNCIA DOS PERFIS DO GOOGLE\n')
fprintf('============================================================\n')
fprintf('Short path\n')
fprintf('Distância calculada: %.3f m\n',distshort(end))
fprintf('Elevação inicial: %.3f m\n',short.dadoselev(3,1))
fprintf('Elevação final:   %.3f m\n',short.dadoselev(3,end))
fprintf('Espaçamento médio: %.3f m\n',mean(diff(distshort)))
fprintf('Espaçamento mínimo: %.3f m\n',min(diff(distshort)))
fprintf('Espaçamento máximo: %.3f m\n',max(diff(distshort)))
fprintf('\n')
fprintf('Long path\n')
fprintf('Distância calculada: %.3f m\n',distlong(end))
fprintf('Elevação inicial: %.3f m\n',long.dadoselev(3,1))
fprintf('Elevação final:   %.3f m\n',long.dadoselev(3,end))
fprintf('Espaçamento médio: %.3f m\n',mean(diff(distlong)))
fprintf('Espaçamento mínimo: %.3f m\n',min(diff(distlong)))
fprintf('Espaçamento máximo: %.3f m\n',max(diff(distlong)))
fprintf('============================================================\n')

%% Plotar perfis

figure

plot(distshort,short.dadoselev(3,:))

grid on

xlabel('Distância (m)')

ylabel('Elevação (m)')

title('NTIA - 63rd Street Short Path - Google Elevation')

figure

plot(distlong,long.dadoselev(3,:))

grid on

xlabel('Distância (m)')

ylabel('Elevação (m)')

title('NTIA - 63rd Street Long Path - Google Elevation')

%% Finalizar

fprintf('\nArquivos salvos em:\n')
fprintf('%s\n',pastasaida)

%% Calcular distância acumulada

function distancia=calculadistancia(dadoselev)

n=size(dadoselev,2);

wgs84=wgs84Ellipsoid("m");

distancia=zeros(1,n);

for i=2:n

    distancia(i)=distancia(i-1)+distance(dadoselev(1,i-1),dadoselev(2,i-1),dadoselev(1,i),dadoselev(2,i),wgs84);

end

end
