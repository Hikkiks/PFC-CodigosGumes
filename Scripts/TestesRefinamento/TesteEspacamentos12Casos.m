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

freq1=557.142857*10^6;

alturat1=76.2;

freq2=581.142857*10^6;

alturat2=113;

espacamentosteste=[30 50 75 90 100 120 150];

%% Definir número de gumes publicados por Lorenço

gumeslorenco=[3 3 4 3 3 2;
              2 2 3 3 3 1];

%% Preparar armazenamento dos resultados

resultados=zeros(12,length(espacamentosteste));

caso=1;

%% Testar os 12 casos

for emissora=1:2

    if emissora==1

        freq=freq1;

        alturat=alturat1;

    else

        freq=freq2;

        alturat=alturat2;

    end

    for ponto=1:6

        %% Carregar perfil original de 512 pontos

        nomearquivo=['DadosConclusaoE' num2str(emissora) 'P' num2str(ponto) '.mat'];

        caminhoarquivo=fullfile(pastaconclusao,nomearquivo);

        load(caminhoarquivo,'dadoselev');

        %% Aplicar correção do raio efetivo

        dadoselev=raioefetivo(dadoselev);

        %% Calcular distância acumulada original

        n=size(dadoselev,2);

        wgs84=wgs84Ellipsoid("m");

        distancia=zeros(1,n);

        for i=2:n

            distancia(i)=distancia(i-1)+distance(dadoselev(1,i-1),dadoselev(2,i-1),dadoselev(1,i),dadoselev(2,i),wgs84);

        end

        distanciatotal=distancia(end);

        %% Preparar perfil de altitude com alturas das antenas

        altura=dadoselev(3,:);

        altura(1)=altura(1)+alturat;

        altura(end)=altura(end)+alturar;

        %% Testar cada espaçamento físico

        for e=1:length(espacamentosteste)

            espacamento=espacamentosteste(e);

            distancianova=0:espacamento:distanciatotal;

            if distancianova(end)<distanciatotal

                distancianova=[distancianova distanciatotal];

            end

            alturanova=interp1(distancia,altura,distancianova,'linear');

            indexgumes=encontragumesdistancia(alturanova,distancianova);

            resultados(caso,e)=length(indexgumes);

        end

        caso=caso+1;

    end

end

%% Mostrar número de gumes por espaçamento

fprintf('\n')
fprintf('NÚMERO DE GUMES POR ESPAÇAMENTO\n\n')

fprintf('Caso   Lor')

for e=1:length(espacamentosteste)

    fprintf('   %3dm',espacamentosteste(e))

end

fprintf('\n')

fprintf('---------------------------------------------------------------\n')

caso=1;

for emissora=1:2

    for ponto=1:6

        fprintf('E%d-P%d %5d',emissora,ponto,gumeslorenco(emissora,ponto))

        for e=1:length(espacamentosteste)

            fprintf(' %6d',resultados(caso,e))

        end

        fprintf('\n')

        caso=caso+1;

    end

end

%% Mostrar quantidade de casos exatamente iguais a Lorenço

fprintf('\n')
fprintf('ACERTOS EXATOS POR ESPAÇAMENTO\n')
fprintf('------------------------------\n')

for e=1:length(espacamentosteste)

    acertos=0;

    caso=1;

    for emissora=1:2

        for ponto=1:6

            if resultados(caso,e)==gumeslorenco(emissora,ponto)

                acertos=acertos+1;

            end

            caso=caso+1;

        end

    end

    fprintf('%3d m: %d de 12\n',espacamentosteste(e),acertos)

end

%% Mostrar erro absoluto total

fprintf('\n')
fprintf('ERRO ABSOLUTO TOTAL NA QUANTIDADE DE GUMES\n')
fprintf('------------------------------------------\n')

for e=1:length(espacamentosteste)

    erro=0;

    caso=1;

    for emissora=1:2

        for ponto=1:6

            erro=erro+abs(resultados(caso,e)-gumeslorenco(emissora,ponto));

            caso=caso+1;

        end

    end

    fprintf('%3d m: %d\n',espacamentosteste(e),erro)

end

%% Detectar gumes em perfil definido pela distância

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