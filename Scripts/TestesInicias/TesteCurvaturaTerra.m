clear
clc
close all

%% Definir caminhos

pastateste=fileparts(mfilename('fullpath'));

pastascripts=fileparts(pastateste);

addpath(fullfile(pastascripts,'Funções'))

BancoD=fullfile(pastascripts,'DadosSalvos','RelevosLorenco85','DadosElevLorenco1.mat');

%% Carregar perfil

load(BancoD)

dadoselevoriginal=dadoselev;

%% Calcular distância acumulada

n=size(dadoselev,2);

wgs84=wgs84Ellipsoid("m");

distancia=zeros(1,n);

for i=2:1:n

    distancia(i)=distancia(i-1)+distance(dadoselev(1,i-1),dadoselev(2,i-1),dadoselev(1,i),dadoselev(2,i),wgs84);

end

distancia=distancia/(10^3);

%% Aplicar correção do raio efetivo

dadoselev=raioefetivo(dadoselev);

%% Comparar perfis

figure

plot(distancia,dadoselevoriginal(3,:),'LineWidth',2.5)

hold on

plot(distancia,dadoselev(3,:),'LineWidth',2.5)

grid on

xlabel('Distância (km)','FontSize',18)

ylabel('Elevação (m)','FontSize',18)

title('Perfil de Elevação com Correção do Raio Efetivo','FontSize',20)

legend('Relevo Original','Relevo com Raio Efetivo','Location','best','FontSize',16)

set(gca,'FontSize',16,'LineWidth',1.5)

xlim([0 distancia(end)])