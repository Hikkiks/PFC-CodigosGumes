clear
clc
close all

%% Definir caminhos

pastateste=fileparts(mfilename('fullpath'));

pastascripts=fileparts(pastateste);

addpath(fullfile(pastascripts,'Funções'))

BancoD=fullfile(pastascripts,'DadosSalvos','DadosFab','DadosElevFres.mat');

%% Carregar dados da API Elevation

load(BancoD)

dadoselevapi=dadoselev;

amostras=size(dadoselevapi,2);

%% Obter coordenadas

lat1=dadoselevapi(1,1);

lon1=dadoselevapi(2,1);

lat2=dadoselevapi(1,end);

lon2=dadoselevapi(2,end);

%% Obter dados do MATLAB

dadoselevmat=dadoselevmatlab(lat1,lon1,lat2,lon2,amostras);

%% Calcular distância acumulada

wgs84=wgs84Ellipsoid("m");

distancia=zeros(1,amostras);

for i=2:1:amostras

    distancia(i)=distancia(i-1)+distance(dadoselevapi(1,i-1),dadoselevapi(2,i-1),dadoselevapi(1,i),dadoselevapi(2,i),wgs84);

end

distancia=distancia/1000;

%% Calcular diferenças

delta=abs(dadoselevmat(3,:)-dadoselevapi(3,:));

deltamedio=mean(delta);

deltapercentual=mean((delta./dadoselevapi(3,:))*100);

%% Desenhar dados da API Elevation

figure

subplot(3,1,1)

plot(distancia,dadoselevapi(3,:),'LineWidth',2)

grid on

xlabel('Distância (km)','FontSize',14)

ylabel('Elevação (m)','FontSize',14)

title('Dados API Elevation','FontSize',16)

xlim([0 distancia(end)])

set(gca,'FontSize',14)

%% Desenhar dados do MATLAB

subplot(3,1,2)

plot(distancia,dadoselevmat(3,:),'LineWidth',2)

grid on

xlabel('Distância (km)','FontSize',14)

ylabel('Elevação (m)','FontSize',14)

title('Dados MATLAB','FontSize',16)

xlim([0 distancia(end)])

set(gca,'FontSize',14)

%% Comparar API Elevation e MATLAB

subplot(3,1,3)

plot(distancia,dadoselevapi(3,:),'LineWidth',2)

hold on

plot(distancia,dadoselevmat(3,:),'LineWidth',2)

grid on

xlabel('Distância (km)','FontSize',14)

ylabel('Elevação (m)','FontSize',14)

title('API Elevation x MATLAB','FontSize',16)

legend('API Elevation','MATLAB','Location','best','FontSize',13)

xlim([0 distancia(end)])

set(gca,'FontSize',14)

%% Mostrar resultados

disp('---------------------------------------')

disp(['Delta médio          : ',num2str(deltamedio,'%.2f'),' m'])

disp(['Delta médio relativo : ',num2str(deltapercentual,'%.2f'),' %'])

disp('---------------------------------------')