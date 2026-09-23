clear
clc
close all

%% Escolher perfil

emissora=1;

ponto=1;

%% Definir caminhos

pastateste=fileparts(mfilename('fullpath'));

pastascripts=fileparts(pastateste);

addpath(fullfile(pastascripts,'Funções'))

pastaconclusao=fullfile(pastascripts,'DadosSalvos','DadosConclusao');

%% Definir parâmetros

alturar=1.5;

if emissora==1

    freq=557.142857*10^6;

    alturat=76.2;

    gumeslorenco=[3 3 4 3 3 2];

elseif emissora==2

    freq=581.142857*10^6;

    alturat=113;

    gumeslorenco=[2 2 3 3 3 1];

else

    error('A emissora deve ser 1 ou 2.')

end

if ponto<1 || ponto>6

    error('O ponto deve estar entre 1 e 6.')

end

%% Carregar perfil

nomearquivo=['DadosConclusaoE' num2str(emissora) 'P' num2str(ponto) '.mat'];

caminhoarquivo=fullfile(pastaconclusao,nomearquivo);

load(caminhoarquivo,'dadoselev');

%% Corrigir raio efetivo da Terra

dadoselev=raioefetivo(dadoselev);

%% Identificar gumes

[indexgumes,gumes]=indexgumess(dadoselev,alturat,alturar,freq,true);

%% Preparar alturas

altura=dadoselev(3,:);

alturaplot=altura;

alturaplot(1)=alturaplot(1)+alturat;

alturaplot(end)=alturaplot(end)+alturar;

%% Calcular distâncias

n=size(dadoselev,2);

wgs84=wgs84Ellipsoid("m");

distancia=zeros(1,n);

for i=2:n

    distancia(i)=distancia(i-1)+distance(dadoselev(1,i-1),dadoselev(2,i-1),dadoselev(1,i),dadoselev(2,i),wgs84);

end

distanciakm=distancia/1000;

%% Desenhar perfil

figure

hold on

grid on

plot(distanciakm,altura,'k','LineWidth',1.2)

plot(distanciakm(1),alturaplot(1),'ro','MarkerFaceColor','r','MarkerSize',7,'LineWidth',1.2)

plot(distanciakm(end),alturaplot(end),'bo','MarkerFaceColor','b','MarkerSize',7,'LineWidth',1.2)

for i=1:gumes

    indice=indexgumes(i);

    plot(distanciakm(indice),altura(indice),'ko','MarkerFaceColor','k','MarkerSize',6,'LineWidth',1)

end

%% Desenhar caminho pelos gumes

indicescaminho=[1 indexgumes n];

alturacaminho=[alturaplot(1) altura(indexgumes) alturaplot(end)];

plot(distanciakm(indicescaminho),alturacaminho,'--','LineWidth',1)

%% Configurar eixos

xlabel('Distância (km)','FontSize',18)

ylabel('Elevação (m)','FontSize',18)

title(['Emissora ' num2str(emissora) ' - Ponto ' num2str(ponto) ' | Gumes: ' num2str(gumes) ' | Lorenço: ' num2str(gumeslorenco(ponto))],'FontSize',20)

ax=gca;

ax.FontSize=16;

ax.LineWidth=1.2;

%% Ajustar margem vertical

valormin=min([altura alturaplot]);

valormax=max([altura alturaplot]);

margem=(valormax-valormin)*0.08;

if margem==0

    margem=10;

end

ylim([valormin-margem valormax+margem])

%% Mostrar resultados

fprintf('\n')
fprintf('Emissora: %d\n',emissora)
fprintf('Ponto: %d\n',ponto)
fprintf('Gumes encontrados: %d\n',gumes)
fprintf('Gumes do Lorenço: %d\n',gumeslorenco(ponto))
fprintf('Diferença: %d\n',gumes-gumeslorenco(ponto))

fprintf('\n')
fprintf('Índices dos gumes:\n')

disp(indexgumes)

fprintf('Distâncias dos gumes em km:\n')

disp(distanciakm(indexgumes))