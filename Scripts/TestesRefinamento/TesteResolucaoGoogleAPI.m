clear
clc
close all

%% Definir caminhos

pastateste=fileparts(mfilename('fullpath'));

pastascripts=fileparts(pastateste);

addpath(fullfile(pastascripts,'Funções'))

%% Obter chave da Google Elevation API

API_KEY=getenv('GOOGLE_ELEVATION_API_KEY');

if isempty(API_KEY)==true
    error('Defina a variável de ambiente GOOGLE_ELEVATION_API_KEY.')
end

%% Definir configuração

amostras=100;

%% Definir transmissor da Emissora 2

lattx=-18.8825;

lontx=-48.25083;

%% Definir receptores analisados

nomes={'E2-P1','E2-P6'};

latrx=[-18.865 -18.975];

lonrx=[-48.21833 -48.37639];

%% Executar testes

for caso=1:length(nomes)

    fprintf('\n========================================\n')
    fprintf('%s\n',nomes{caso})
    fprintf('========================================\n\n')

    [dadoselev,resolucao]=dadoselevresolucao(lattx,lontx,latrx(caso),lonrx(caso),amostras,API_KEY);

    %% Calcular estatísticas da resolução

    resolucaomin=min(resolucao);

    resolucaomedia=mean(resolucao);

    resolucaomediana=median(resolucao);

    resolucaomax=max(resolucao);

    fprintf('\nResultados %s\n',nomes{caso})
    fprintf('Resolução mínima:   %.3f m\n',resolucaomin)
    fprintf('Resolução média:    %.3f m\n',resolucaomedia)
    fprintf('Resolução mediana:  %.3f m\n',resolucaomediana)
    fprintf('Resolução máxima:   %.3f m\n',resolucaomax)

    %% Mostrar valores de resolução encontrados

    valores=unique(round(resolucao,3));

    fprintf('\nValores de resolução encontrados:\n')

    disp(valores')

    %% Mostrar distribuição da resolução

    figure

    histogram(resolucao)

    xlabel('Resolução informada pelo Google (m)','FontSize',18)

    ylabel('Número de pontos','FontSize',18)

    title(['Resolução da Elevation API - ' nomes{caso}],'FontSize',20)

    set(gca,'FontSize',16,'LineWidth',1.5)

    grid on

    %% Calcular distância acumulada

    wgs84=wgs84Ellipsoid("m");

    distancia=zeros(1,amostras);

    for i=2:amostras

        distancia(i)=distancia(i-1)+distance(dadoselev(1,i-1),dadoselev(2,i-1),dadoselev(1,i),dadoselev(2,i),wgs84);

    end

    %% Mostrar resolução ao longo do enlace

    figure

    plot(distancia/1000,resolucao,'LineWidth',2.5)

    xlabel('Distância (km)','FontSize',18)

    ylabel('Resolução informada pelo Google (m)','FontSize',18)

    title(['Resolução ao longo do enlace - ' nomes{caso}],'FontSize',20)

    set(gca,'FontSize',16,'LineWidth',1.5)

    grid on

end