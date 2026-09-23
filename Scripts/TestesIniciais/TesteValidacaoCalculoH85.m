clear
clc
close all

%% Definir caminhos

pastateste=fileparts(mfilename('fullpath'));

pastascripts=fileparts(pastateste);

addpath(fullfile(pastascripts,'Funções'))

pastarelevos=fullfile(pastascripts,'DadosSalvos','RelevosLorenco85');

%% Definir configurações

alturat=10;

alturar=10;

freq=575.142857*10^6;

tolerancia=10^-8;

%% Localizar arquivos

arquivos=dir(fullfile(pastarelevos,'DadosElevLorenco*.mat'));

quantidade=length(arquivos);

%% Preparar resultados gerais

casos=[];

indicesgumes=[];

hmetodo=[];

hdireto=[];

errosabsolutos=[];

errosrelativos=[];

%% Analisar todos os perfis

for caso=1:quantidade

    %% Carregar perfil

    nomearquivo=['DadosElevLorenco' num2str(caso) '.mat'];

    caminhoarquivo=fullfile(pastarelevos,nomearquivo);

    dados=load(caminhoarquivo);

    dadoselev=dados.dadoselev;

    %% Aplicar correção do raio efetivo

    dadoselev=raioefetivo(dadoselev);

    %% Identificar gumes

    [indexgumes,gumes]=indexgumess(dadoselev,alturat,alturar,freq,false);

    if gumes==0
        continue
    end

    %% Calcular distância horizontal acumulada

    n=size(dadoselev,2);

    wgs84=wgs84Ellipsoid("m");

    distancia=zeros(1,n);

    for i=2:n

        distancia(i)=distancia(i-1)+distance(dadoselev(1,i-1),dadoselev(2,i-1),dadoselev(1,i),dadoselev(2,i),wgs84);

    end

    %% Preparar alturas com antenas

    altura=dadoselev(3,:);

    altura(1)=altura(1)+alturat;

    altura(end)=altura(end)+alturar;

    %% Comparar h de cada gume

    for y=1:gumes

        if y==1
            indexesq=1;
        else
            indexesq=indexgumes(y-1);
        end

        if y==gumes
            indexdir=n;
        else
            indexdir=indexgumes(y+1);
        end

        indexgume=indexgumes(y);

        %% Calcular h pelo método atual

        d1=txrx(indexesq,indexgume,0,0,dadoselev);

        d2=txrx(indexgume,indexdir,0,0,dadoselev);

        if indexesq==1
            d1=txrx(indexesq,indexgume,alturat,0,dadoselev);
        end

        if indexdir==n
            d2=txrx(indexgume,indexdir,0,alturar,dadoselev);
        end

        atxesq=0;

        arxdir=0;

        if indexesq==1
            atxesq=alturat;
        end

        if indexdir==n
            arxdir=alturar;
        end

        d3=txrx(indexesq,indexdir,atxesq,arxdir,dadoselev);

        [hf,~,~]=valorcos(d1,d2,d3);

        pontos=indexdir-indexesq+1;

        indexrelativo=indexgume-indexesq+1;

        hcalculado=checarh(altura(indexesq),altura(indexdir),pontos,altura(indexgume),indexrelativo,hf);

        %% Calcular h diretamente pela distância perpendicular assinada

        x1=distancia(indexesq);

        z1=altura(indexesq);

        x2=distancia(indexdir);

        z2=altura(indexdir);

        xg=distancia(indexgume);

        zg=altura(indexgume);

        numerador=(x2-x1)*(zg-z1)-(z2-z1)*(xg-x1);

        denominador=sqrt((x2-x1)^2+(z2-z1)^2);

        hdiretocalculado=numerador/denominador;

        %% Calcular erros

        erroabsoluto=abs(hcalculado-hdiretocalculado);

        if abs(hdiretocalculado)>10^-12

            errorelativo=erroabsoluto/abs(hdiretocalculado);

        else

            errorelativo=0;

        end

        %% Armazenar resultados

        casos=[casos caso];

        indicesgumes=[indicesgumes indexgume];

        hmetodo=[hmetodo hcalculado];

        hdireto=[hdireto hdiretocalculado];

        errosabsolutos=[errosabsolutos erroabsoluto];

        errosrelativos=[errosrelativos errorelativo];

    end

end

%% Calcular resumo

totalgumes=length(hmetodo);

iguais=sum(errosabsolutos<tolerancia);

erroabsolutomax=max(errosabsolutos);

erroabsolutomedio=mean(errosabsolutos);

errorelativomax=max(errosrelativos);

errorelativomedio=mean(errosrelativos);

[~,indicepior]=max(errosabsolutos);

%% Mostrar resultados

fprintf('\n')
fprintf('VALIDAÇÃO DO CÁLCULO DE h\n')
fprintf('=================================================\n')
fprintf('Perfis analisados: %d\n',quantidade)
fprintf('Total de gumes analisados: %d\n',totalgumes)
fprintf('Tolerância: %.1e m\n',tolerancia)
fprintf('Coincidentes dentro da tolerância: %d de %d\n',iguais,totalgumes)
fprintf('Erro absoluto médio: %.12f m\n',erroabsolutomedio)
fprintf('Erro absoluto máximo: %.12f m\n',erroabsolutomax)
fprintf('Erro relativo médio: %.12e\n',errorelativomedio)
fprintf('Erro relativo máximo: %.12e\n',errorelativomax)
fprintf('=================================================\n')

%% Mostrar pior caso

fprintf('\n')
fprintf('PIOR CASO\n')
fprintf('-------------------------------------------------\n')
fprintf('Perfil: %d\n',casos(indicepior))
fprintf('Índice do gume: %d\n',indicesgumes(indicepior))
fprintf('h atual: %.12f m\n',hmetodo(indicepior))
fprintf('h direto: %.12f m\n',hdireto(indicepior))
fprintf('Erro absoluto: %.12f m\n',errosabsolutos(indicepior))
fprintf('Erro relativo: %.12e\n',errosrelativos(indicepior))
fprintf('-------------------------------------------------\n')

%% Mostrar maiores diferenças

[~,ordem]=sort(errosabsolutos,'descend');

quantidademostrar=min(20,totalgumes);

fprintf('\n')
fprintf('20 MAIORES DIFERENÇAS\n\n')
fprintf('Caso   Gume   h atual          h direto         Erro\n')
fprintf('-------------------------------------------------------------\n')

for i=1:quantidademostrar

    indice=ordem(i);

    fprintf('%3d    %4d   %12.8f   %12.8f   %.3e\n',casos(indice),indicesgumes(indice),hmetodo(indice),hdireto(indice),errosabsolutos(indice))

end