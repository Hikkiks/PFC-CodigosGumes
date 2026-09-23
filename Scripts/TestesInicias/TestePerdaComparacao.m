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

freq=575.142857*10^6;

alturat=10;
alturar=10;

%% Aplicar correção do raio efetivo

dadoselev=raioefetivo(dadoselev);

%% Identificar gumes

[indexgumes,gumes]=indexgumess(dadoselev,alturat,alturar,freq,true);

%% Calcular perdas

pathlossepstein=perdaepstein(indexgumes,dadoselev,freq,gumes,alturar,alturat);

pathlossdeygout=perdadeygout(indexgumes,dadoselev,freq,gumes,alturar,alturat);

pathlossgio=perdagiovaneli(indexgumes,dadoselev,freq,gumes,alturar,alturat);

%% Calcular distância acumulada

n=size(dadoselev,2);

wgs84=wgs84Ellipsoid("m");

distancia=zeros(1,n);

for i=2:1:n

    distancia(i)=distancia(i-1)+distance(dadoselev(1,i-1),dadoselev(2,i-1),dadoselev(1,i),dadoselev(2,i),wgs84);

end

distanciatotal=distancia(end);

nticks=6;

xticksdist=round(linspace(1,n,nticks));

xlabels=linspace(0,distanciatotal/1000,nticks);

%% Desenhar comparação dos modelos

figure

%% Epstein-Peterson

subplot(3,1,1)

desenhaepstein(dadoselev,indexgumes,alturat,alturar)

xlim([1 n])

xticks(xticksdist)

xticklabels(compose('%.1f',xlabels))

xlabel('Distância (km)','FontSize',18)

ylabel('Elevação (m)','FontSize',18)

title(['Epstein-Peterson - ',num2str(gumes),' gumes - Perda = ',num2str(pathlossepstein),' dB'],'FontSize',20)

set(gca,'FontSize',16,'LineWidth',1.5)

%% Deygout

subplot(3,1,2)

desenhadeygout(dadoselev,indexgumes,alturat,alturar,freq)

xlim([1 n])

xticks(xticksdist)

xticklabels(compose('%.1f',xlabels))

xlabel('Distância (km)','FontSize',18)

ylabel('Elevação (m)','FontSize',18)

title(['Deygout - ',num2str(gumes),' gumes - Perda = ',num2str(pathlossdeygout),' dB'],'FontSize',20)

set(gca,'FontSize',16,'LineWidth',1.5)

%% Giovaneli

subplot(3,1,3)

desenhagiovaneli(dadoselev,indexgumes,alturat,alturar,freq)

xlim([1 n])

xticks(xticksdist)

xticklabels(compose('%.1f',xlabels))

xlabel('Distância (km)','FontSize',18)

ylabel('Elevação (m)','FontSize',18)

title(['Giovaneli - ',num2str(gumes),' gumes - Perda = ',num2str(pathlossgio),' dB'],'FontSize',20)

set(gca,'FontSize',16,'LineWidth',1.5)

%% Mostrar comparação numérica

disp('---------------------------------------')

disp(['Número de gumes       : ',num2str(gumes)])

disp(['Índices dos gumes     : ',num2str(indexgumes)])

disp(['Epstein-Peterson (dB) : ',num2str(pathlossepstein)])

disp(['Deygout (dB)          : ',num2str(pathlossdeygout)])

disp(['Giovaneli (dB)        : ',num2str(pathlossgio)])

disp(['Distância total (km)  : ',num2str(distanciatotal/1000)])

disp('---------------------------------------')