clear
clc
close all

%% Definir caminhos

pastateste=fileparts(mfilename('fullpath'));

pastascripts=fileparts(pastateste);

addpath(fullfile(pastascripts,'Funções'))

pastaconclusao=fullfile(pastascripts,'DadosSalvos','DadosConclusao');

%% Definir parâmetros

alturar=1.5;

alturat1=76.2;

alturat2=113;

%% Mostrar cabeçalho

fprintf('\n')
fprintf('-------------------------------------------------------------\n')
fprintf('Caso     WGS84   Uniforme   Diferença   Índices iguais\n')
fprintf('-------------------------------------------------------------\n')

iguais=0;

%% Testar os 12 casos

for emissora=1:2

    if emissora==1

        alturat=alturat1;

    else

        alturat=alturat2;

    end

    for ponto=1:6

        %% Carregar perfil

        nomearquivo=['DadosConclusaoE' num2str(emissora) 'P' num2str(ponto) '.mat'];

        caminhoarquivo=fullfile(pastaconclusao,nomearquivo);

        load(caminhoarquivo,'dadoselev');

        %% Corrigir perfil

        dadoselev=raioefetivo(dadoselev);

        n=size(dadoselev,2);

        altura=dadoselev(3,:);

        altura(1)=altura(1)+alturat;
        altura(end)=altura(end)+alturar;

        %% Calcular distância WGS84 cumulativa

        wgs84=wgs84Ellipsoid("m");

        distanciawgs=zeros(1,n);

        for i=2:n

            distanciawgs(i)=distanciawgs(i-1)+distance(dadoselev(1,i-1),dadoselev(2,i-1),dadoselev(1,i),dadoselev(2,i),wgs84);

        end

        %% Calcular distância uniforme

        distanciauniforme=linspace(0,distanciawgs(end),n);

        %% Detectar gumes

        indexwgs=encontragumesdistancia(altura,distanciawgs);

        indexuniforme=encontragumesdistancia(altura,distanciauniforme);

        gumeswgs=length(indexwgs);

        gumesuniforme=length(indexuniforme);

        %% Comparar resultados

        diferenca=gumeswgs-gumesuniforme;

        mesmosindices=isequal(indexwgs,indexuniforme);

        if mesmosindices

            texto='SIM';

            iguais=iguais+1;

        else

            texto='NAO';

        end

        fprintf('E%d-P%d %8d %10d %10d %15s\n',emissora,ponto,gumeswgs,gumesuniforme,diferenca,texto)

    end

end

fprintf('-------------------------------------------------------------\n')
fprintf('Índices exatamente iguais: %d de 12\n',iguais)

%% Função de detecção usando distância fornecida

function indexgumes=encontragumesdistancia(altura,distancia)

n=length(altura);

indexgumes=[];

ponto=1;

while ponto<n

    alturaatual=altura(ponto);

    distanciaatual=distancia(ponto);

    distanciatotal=distancia(end)-distanciaatual;

    if distanciatotal<=0

        break

    end

    inclinacao=(altura(end)-alturaatual)/distanciatotal;

    indicesteste=ponto+1:n-1;

    if isempty(indicesteste)==true

        break

    end

    alturareta=alturaatual+inclinacao.*(distancia(indicesteste)-distanciaatual);

    diferencas=altura(indicesteste)-alturareta;

    indicesobstruidos=indicesteste(diferencas>=0);

    if isempty(indicesobstruidos)==false

        tangentes=(altura(indicesobstruidos)-alturaatual)./(distancia(indicesobstruidos)-distanciaatual);

        [~,indicemaior]=max(tangentes);

        pontohorizonte=indicesobstruidos(indicemaior);

        indexgumes=[indexgumes pontohorizonte];

        ponto=pontohorizonte;

    else

        break

    end

end

indexgumes=unique(indexgumes,'stable');

end