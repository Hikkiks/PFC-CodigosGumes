clear
clc
close all

%% Definir caminhos

pastateste=fileparts(mfilename('fullpath'));

pastascripts=fileparts(pastateste);

addpath(fullfile(pastascripts,'Funções'))

pastadados=fullfile(pastascripts,'DadosSalvos','DadosConclusao');

%% Obter chave da Google Elevation API

API_KEY=getenv('GOOGLE_ELEVATION_API_KEY');

if isempty(API_KEY)==true
    error('Defina a variável de ambiente GOOGLE_ELEVATION_API_KEY.')
end

%% Definir caso analisado

nomearquivo='DadosConclusaoE2P6.mat';

caminhoarquivo=fullfile(pastadados,nomearquivo);

%% Carregar perfil original

load(caminhoarquivo,'dadoselev');

amostras=size(dadoselev,2);

%% Definir trecho analisado

indiceinicio=470;

indicefim=500;

gume1=478;

gume2=480;

gume3=486;

gume4=489;

gumesconhecidos=[gume1 gume2 gume3 gume4];

%% Calcular distância acumulada do perfil original

wgs84=wgs84Ellipsoid("m");

distancia=zeros(1,amostras);

for i=2:amostras

    distancia(i)=distancia(i-1)+distance(dadoselev(1,i-1),dadoselev(2,i-1),dadoselev(1,i),dadoselev(2,i),wgs84);

end

%% Obter coordenadas inicial e final do trecho

lat1=dadoselev(1,indiceinicio);

lon1=dadoselev(2,indiceinicio);

lat2=dadoselev(1,indicefim);

lon2=dadoselev(2,indicefim);

%% Calcular distância física do trecho

distanciatrecho=distance(lat1,lon1,lat2,lon2,wgs84);

%% Definir quantidade de amostras do microperfil

amostrasdensas=512;

fprintf('============================================\n')
fprintf('MICROPERFIL E2-P6\n')
fprintf('============================================\n\n')

fprintf('Índice inicial:          %d\n',indiceinicio)
fprintf('Índice final:            %d\n',indicefim)
fprintf('Comprimento do trecho:   %.3f m\n',distanciatrecho)
fprintf('Amostras solicitadas:    %d\n',amostrasdensas)
fprintf('Espaçamento aproximado:  %.3f m\n\n',distanciatrecho/(amostrasdensas-1))

%% Consultar microperfil no Google

dadoselevdenso=dadoselevgoogle(lat1,lon1,lat2,lon2,amostrasdensas,API_KEY);

%% Calcular distância acumulada do perfil denso

distanciadensa=zeros(1,amostrasdensas);

for i=2:amostrasdensas

    distanciadensa(i)=distanciadensa(i-1)+distance(dadoselevdenso(1,i-1),dadoselevdenso(2,i-1),dadoselevdenso(1,i),dadoselevdenso(2,i),wgs84);

end

%% Ajustar posição do microperfil no enlace completo

distanciadensa=distanciadensa+distancia(indiceinicio);

%% Obter dados originais do trecho

indicesoriginais=indiceinicio:indicefim;

distanciaoriginal=distancia(indicesoriginais);

elevacaooriginal=dadoselev(3,indicesoriginais);

%% Mostrar gumes conhecidos

fprintf('============================================\n')
fprintf('GUMES ENCONTRADOS NO PERFIL ORIGINAL\n')
fprintf('============================================\n\n')

for i=1:length(gumesconhecidos)

    indice=gumesconhecidos(i);

    fprintf('Gume %d\n',i)
    fprintf('Índice:                 %d\n',indice)
    fprintf('Distância:              %.6f km\n',distancia(indice)/1000)
    fprintf('Elevação:               %.6f m\n\n',dadoselev(3,indice))

end

%% Mostrar separações entre os gumes

fprintf('Separações entre os gumes:\n\n')

for i=2:length(gumesconhecidos)

    separacao=distancia(gumesconhecidos(i))-distancia(gumesconhecidos(i-1));

    fprintf('G%d-G%d:                 %.6f m\n',i-1,i,separacao)

end

%% Encontrar máximos e mínimos locais no perfil denso

elevacaodensa=dadoselevdenso(3,:);

maximos=[];

minimos=[];

for i=2:amostrasdensas-1

    if elevacaodensa(i)>elevacaodensa(i-1) && elevacaodensa(i)>=elevacaodensa(i+1)

        maximos=[maximos i];

    end

    if elevacaodensa(i)<elevacaodensa(i-1) && elevacaodensa(i)<=elevacaodensa(i+1)

        minimos=[minimos i];

    end

end

%% Mostrar máximos locais

fprintf('\n============================================\n')
fprintf('MÁXIMOS LOCAIS\n')
fprintf('============================================\n\n')

fprintf('Máximos locais encontrados no trecho: %d\n\n',length(maximos))

for i=1:length(maximos)

    indice=maximos(i);

    fprintf('Máximo %d | Distância = %.6f km | Elevação = %.6f m\n',i,distanciadensa(indice)/1000,elevacaodensa(indice))

end

%% Mostrar mínimos locais

fprintf('\n============================================\n')
fprintf('MÍNIMOS LOCAIS\n')
fprintf('============================================\n\n')

fprintf('Mínimos locais encontrados no trecho: %d\n\n',length(minimos))

for i=1:length(minimos)

    indice=minimos(i);

    fprintf('Mínimo %d | Distância = %.6f km | Elevação = %.6f m\n',i,distanciadensa(indice)/1000,elevacaodensa(indice))

end

%% Mostrar microperfil e amostras originais

figure

plot(distanciadensa/1000,elevacaodensa,'LineWidth',2.5)

hold on

plot(distanciaoriginal/1000,elevacaooriginal,'o','MarkerSize',7,'LineWidth',1.5)

plot(distancia(gumesconhecidos)/1000,dadoselev(3,gumesconhecidos),'s','MarkerSize',10,'LineWidth',2)

xlabel('Distância (km)','FontSize',18)

ylabel('Elevação (m)','FontSize',18)

title('Microperfil do Google próximo aos gumes do E2-P6','FontSize',20)

legend('Perfil denso com 512 amostras','Amostras originais','Gumes encontrados','Location','best')

set(gca,'FontSize',16,'LineWidth',1.5)

grid on

%% Mostrar máximos e mínimos locais

figure

plot(distanciadensa/1000,elevacaodensa,'LineWidth',2.5)

hold on

if isempty(maximos)==false

    plot(distanciadensa(maximos)/1000,elevacaodensa(maximos),'o','MarkerSize',8,'LineWidth',1.5)

end

if isempty(minimos)==false

    plot(distanciadensa(minimos)/1000,elevacaodensa(minimos),'x','MarkerSize',8,'LineWidth',1.5)

end

xlabel('Distância (km)','FontSize',18)

ylabel('Elevação (m)','FontSize',18)

title('Máximos e mínimos da superfície interpolada - E2-P6','FontSize',20)

legend('Perfil Google','Máximos locais','Mínimos locais','Location','best')

set(gca,'FontSize',16,'LineWidth',1.5)

grid on