clear
clc
close all

%% Definir caminhos

pastateste=fileparts(mfilename('fullpath'));

pastascripts=fileparts(pastateste);

addpath(fullfile(pastascripts,'Funções'))

BancoD=fullfile(pastascripts,'DadosSalvos','DadosFab','DadosElev0.mat');

%% Carregar dados

load(BancoD)

freq=575.142857*10^6;

alturat=10;
alturar=10;

dadoselev=raioefetivo(dadoselev);

%% Identificar gumes

[indexgumes,gumes]=indexgumess(dadoselev,alturat,alturar,freq,true);

%% Preparar alturas

altura=dadoselev(3,:);

altura(1)=altura(1)+alturat;
altura(end)=altura(end)+alturar;

%% Calcular distância acumulada

wgs84=wgs84Ellipsoid("m");

n=length(altura);

distancia=zeros(1,n);

for i=2:n

    distancia(i)=distancia(i-1)+distance(dadoselev(1,i-1),dadoselev(2,i-1),dadoselev(1,i),dadoselev(2,i),wgs84);

end

distancia=distancia/1000;

%% Desenhar perfil e gumes

figure

hold on
grid on

plot(distancia,altura,'b','LineWidth',2.5)

plot(distancia(indexgumes),altura(indexgumes),'ro','MarkerFaceColor','r','MarkerSize',10,'LineWidth',1.5)

%% Desenhar retas do horizonte

ponto=1;

for k=1:gumes

    plot([distancia(ponto) distancia(indexgumes(k))],[altura(ponto) altura(indexgumes(k))],'g--','LineWidth',2.5)

    ponto=indexgumes(k);

end

plot([distancia(ponto) distancia(end)],[altura(ponto) altura(end)],'g--','LineWidth',2.5)

%% Formatar gráfico

xlabel('Distância (km)','FontSize',18)

ylabel('Elevação (m)','FontSize',18)

title(['Quantidade de gumes: ',num2str(gumes)],'FontSize',20)

legend('Perfil','Gumes','Retas do horizonte','Location','best','FontSize',16)

set(gca,'FontSize',16,'LineWidth',1.5)

xlim([0 distancia(end)])