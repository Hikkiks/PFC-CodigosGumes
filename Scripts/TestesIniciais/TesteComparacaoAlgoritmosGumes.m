clear
clc
close all

%% Definir caminhos

pastateste=fileparts(mfilename('fullpath'));

pastascripts=fileparts(pastateste);

addpath(fullfile(pastascripts,'Funções'))

addpath(genpath(fullfile(pastascripts,'Terceiros')))

pastaconclusao=fullfile(pastascripts,'DadosSalvos','DadosConclusao');

%% Definir parâmetros gerais

alturar=1.5;

%% Definir parâmetros da Emissora 1

freq1=557.142857*10^6;

alturat1=76.2;

%% Definir parâmetros da Emissora 2

freq2=581.142857*10^6;

alturat2=113;

%% Mostrar cabeçalho

fprintf('\n')
fprintf('----------------------------------------------------------\n')
fprintf('Caso   Lucas   Lorenço   Diferença   Índices iguais\n')
fprintf('----------------------------------------------------------\n')

%% Testar as duas emissoras

iguais=0;

for emissora=1:2

    if emissora==1

        freq=freq1;

        alturat=alturat1;

    else

        freq=freq2;

        alturat=alturat2;

    end

    lambda=(3*10^8)/freq;

    for ponto=1:6

        %% Carregar perfil

        nomearquivo=['DadosConclusaoE' num2str(emissora) 'P' num2str(ponto) '.mat'];

        caminhoarquivo=fullfile(pastaconclusao,nomearquivo);

        load(caminhoarquivo,'dadoselev');

        %% Aplicar correção do raio efetivo

        dadoselev=raioefetivo(dadoselev);

        %% Identificar gumes pelo algoritmo desenvolvido

        [indexlucas,gumeslucas]=indexgumess(dadoselev,alturat,alturar,freq,false);

        %% Calcular distâncias

        n=size(dadoselev,2);

        wgs84=wgs84Ellipsoid("m");

        distancia=zeros(n,1);

        for i=2:n

            distancia(i)=distancia(i-1)+distance(dadoselev(1,i-1),dadoselev(2,i-1),dadoselev(1,i),dadoselev(2,i),wgs84);

        end

        %% Preparar perfil para o algoritmo de Lorenço

        perfil=zeros(n,2);

        perfil(:,1)=dadoselev(3,:)';

        perfil(:,2)=distancia;

        %% Calcular alturas absolutas das antenas

        h1=perfil(1,1)+alturat;

        h2=perfil(end,1)+alturar;

        %% Identificar gumes pelo algoritmo de Lorenço

        pontos=[];

        indexlorenco=traca_caminho(h1,h2,1,n,perfil,lambda,pontos,false);

        indexlorenco=indexlorenco(:)';

        gumeslorenco=length(indexlorenco);

        %% Comparar resultados

        diferenca=gumeslucas-gumeslorenco;

        mesmosindices=isequal(indexlucas,indexlorenco);

        if mesmosindices

            texto='SIM';

            iguais=iguais+1;

        else

            texto='NAO';

        end

        %% Mostrar resultado

        fprintf('E%d-P%d %7d %9d %10d %14s\n',emissora,ponto,gumeslucas,gumeslorenco,diferenca,texto)

    end

end

fprintf('----------------------------------------------------------\n')
fprintf('Índices exatamente iguais: %d de 12\n',iguais)