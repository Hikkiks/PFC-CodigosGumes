clear
clc
close all

%% Definir caminhos

pastateste=fileparts(mfilename('fullpath'));

pastascripts=fileparts(pastateste);

addpath(fullfile(pastascripts,'Funções'))

BancoD=fullfile(pastascripts,'DadosSalvos','DadosFab','DadosFab2.mat');

%% Carregar dados

load(BancoD)

dadoselev=raioefetivo(dadoselev);

freq=575.142857*10^6;

alturat=10;
alturar=10;

%% Identificar gumes

[indexgumes,gumes]=indexgumess(dadoselev,alturat,alturar,freq,true);

%% Calcular perda de Giovaneli

pathlossgio=perdagiovaneli(indexgumes,dadoselev,freq,gumes,alturar,alturat);

%% Calcular distância acumulada

n=size(dadoselev,2);

wgs84=wgs84Ellipsoid("m");

distancia=zeros(1,n);

for i=2:n

    distancia(i)=distancia(i-1)+distance(dadoselev(1,i-1),dadoselev(2,i-1),dadoselev(1,i),dadoselev(2,i),wgs84);

end

distancia=distancia/1000;

%% Desenhar Giovaneli

figure

desenhagiovaneli(dadoselev,indexgumes,alturat,alturar,freq)

nticks=6;

xticksindice=round(linspace(1,n,nticks));

xticks(xticksindice)

xticklabels(compose('%.1f',distancia(xticksindice)))

xlim([1 n])

xlabel('Distância (km)','FontSize',18)

ylabel('Elevação (m)','FontSize',18)

title(['Giovaneli - ',num2str(gumes),' gumes - Perda = ',num2str(pathlossgio),' dB'],'FontSize',20)

set(gca,'FontSize',16,'LineWidth',1.5)

%% Mostrar informações

disp('---------------------------------------')

disp(['Número de gumes : ',num2str(gumes)])

disp(['Índices         : ',num2str(indexgumes)])

disp(['Perda Giovaneli : ',num2str(pathlossgio),' dB'])

disp(['Distância total : ',num2str(distancia(end),'%.2f'),' km'])

disp('---------------------------------------')