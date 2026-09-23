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

nomearquivo='DadosConclusaoE2P1.mat';

caminhoarquivo=fullfile(pastadados,nomearquivo);

%% Carregar perfil original

load(caminhoarquivo,'dadoselev');

amostras=size(dadoselev,2);

%% Preparar vetores

elevacaoriginal=dadoselev(3,:);

elevacaoindividual=zeros(1,amostras);

resolucao=zeros(1,amostras);

diferenca=zeros(1,amostras);

%% Consultar exatamente as mesmas coordenadas

for i=1:amostras

    latitude=dadoselev(1,i);

    longitude=dadoselev(2,i);

    [elevacaoindividual(i),resolucao(i)]=consultaindividualgoogle(latitude,longitude,API_KEY);

    diferenca(i)=elevacaoindividual(i)-elevacaoriginal(i);

    fprintf('Ponto %3d/%3d | Original = %9.4f m | Individual = %9.4f m | Diferença = %8.4f m | Resolução = %7.3f m\n',i,amostras,elevacaoriginal(i),elevacaoindividual(i),diferenca(i),resolucao(i))

end

%% Calcular distância acumulada

wgs84=wgs84Ellipsoid("m");

distancia=zeros(1,amostras);

for i=2:amostras

    distancia(i)=distancia(i-1)+distance(dadoselev(1,i-1),dadoselev(2,i-1),dadoselev(1,i),dadoselev(2,i),wgs84);

end

%% Calcular estatísticas das diferenças

diferencaabs=abs(diferenca);

fprintf('\n============================================\n')
fprintf('COMPARAÇÃO ENTRE OS PERFIS\n')
fprintf('============================================\n\n')

fprintf('Diferença média com sinal:   %.6f m\n',mean(diferenca))
fprintf('Diferença absoluta média:    %.6f m\n',mean(diferencaabs))
fprintf('Diferença absoluta mediana:  %.6f m\n',median(diferencaabs))
fprintf('Diferença absoluta máxima:   %.6f m\n',max(diferencaabs))

fprintf('\nResolução mínima:             %.6f m\n',min(resolucao))
fprintf('Resolução média:              %.6f m\n',mean(resolucao))
fprintf('Resolução máxima:             %.6f m\n',max(resolucao))

%% Mostrar pontos de interesse de E2-P1

indicesinteresse=[492 493];

fprintf('\n============================================\n')
fprintf('PONTOS DE INTERESSE\n')
fprintf('============================================\n\n')

for i=1:length(indicesinteresse)

    indice=indicesinteresse(i);

    fprintf('Índice %d\n',indice)
    fprintf('Distância:             %.6f km\n',distancia(indice)/1000)
    fprintf('Elevação original:     %.6f m\n',elevacaoriginal(indice))
    fprintf('Elevação individual:   %.6f m\n',elevacaoindividual(indice))
    fprintf('Diferença:             %.6f m\n',diferenca(indice))
    fprintf('Resolução:              %.6f m\n\n',resolucao(indice))

end

%% Comparar os dois perfis

figure

plot(distancia/1000,elevacaoriginal,'LineWidth',1.5)

hold on

plot(distancia/1000,elevacaoindividual,'LineWidth',1.5)

xlabel('Distância (km)','FontSize',18)

ylabel('Elevação (m)','FontSize',18)

title('Perfil original x consultas individuais - E2-P1','FontSize',20)

legend('Perfil salvo','Consulta individual','Location','best')

set(gca,'FontSize',16,'LineWidth',1.5)

grid on

%% Mostrar diferença entre os perfis

figure

plot(distancia/1000,diferenca,'LineWidth',1.5)

xlabel('Distância (km)','FontSize',18)

ylabel('Diferença de elevação (m)','FontSize',18)

title('Diferença entre os perfis - E2-P1','FontSize',20)

set(gca,'FontSize',16,'LineWidth',1.5)

grid on

%% Mostrar detalhe próximo dos gumes

inicio=max(1,485);

fim=min(amostras,500);

figure

plot(distancia(inicio:fim)/1000,elevacaoriginal(inicio:fim),'o-','LineWidth',1.5)

hold on

plot(distancia(inicio:fim)/1000,elevacaoindividual(inicio:fim),'o-','LineWidth',1.5)

xlabel('Distância (km)','FontSize',18)

ylabel('Elevação (m)','FontSize',18)

title('Detalhe próximo aos gumes 492 e 493','FontSize',20)

legend('Perfil salvo','Consulta individual','Location','best')

set(gca,'FontSize',16,'LineWidth',1.5)

grid on