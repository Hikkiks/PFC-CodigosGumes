function [indexgumes,gumes]=indexgumess(dadoselev,alturat,alturar,freq,usarfresnel)

%% Informações iniciais

n=size(dadoselev,2);

lambda=(3*10^8)/freq;

%% Preparar alturas

altura=dadoselev(3,:);

altura(1)=altura(1)+alturat;

altura(end)=altura(end)+alturar;

%% Calcular distância acumulada

wgs84=wgs84Ellipsoid("m");

distancia=zeros(1,n);

for i=2:1:n

    distancia(i)=distancia(i-1)+distance(dadoselev(1,i-1),dadoselev(2,i-1),dadoselev(1,i),dadoselev(2,i),wgs84);

end

%% Inicializar identificação dos gumes

indexgumes=[];

ponto=1;

%% Percorrer o perfil

while ponto<n

    alturaatual=altura(ponto);

    distanciaatual=distancia(ponto);

    distanciatotal=distancia(end)-distanciaatual;

    if distanciatotal<=0

        break

    end

    %% Construir linha entre o ponto atual e o receptor

    inclinacao=(altura(end)-alturaatual)/distanciatotal;

    indicesteste=ponto+1:n-1;

    if isempty(indicesteste)==true

        break

    end

    alturareta=alturaatual+inclinacao.*(distancia(indicesteste)-distanciaatual);

    diferencas=altura(indicesteste)-alturareta;

    %% Identificar pontos que obstruem a linha

    indicesobstruidos=indicesteste(diferencas>=0);

    if isempty(indicesobstruidos)==false

        %% Encontrar ponto de horizonte

        tangentes=(altura(indicesobstruidos)-alturaatual)./(distancia(indicesobstruidos)-distanciaatual);

        [~,indicemaior]=max(tangentes);

        pontohorizonte=indicesobstruidos(indicemaior);

        %% Verificar obstrução da zona de Fresnel

        if usarfresnel==true

            indicefresnel=verificafresnel(altura,distancia,ponto,pontohorizonte,lambda);

            if isempty(indicefresnel)==false

                indexgumes=[indexgumes indicefresnel];

            end

        end

        %% Armazenar ponto de horizonte

        indexgumes=[indexgumes pontohorizonte];

        ponto=pontohorizonte;

    else

        %% Verificar Fresnel até o receptor

        if usarfresnel==true

            indicefresnel=verificafresnel(altura,distancia,ponto,n,lambda);

            if isempty(indicefresnel)==false

                indexgumes=[indexgumes indicefresnel];

            end

        end

        break

    end

end

%% Organizar resultado

indexgumes=unique(indexgumes,'stable');

gumes=length(indexgumes);

end