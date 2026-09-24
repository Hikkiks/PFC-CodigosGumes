clear
clc
close all

%% Definir caminhos

pastateste=fileparts(mfilename('fullpath'));

pastascripts=fileparts(pastateste);

addpath(fullfile(pastascripts,'Funções'))

pastadados=fullfile(pastascripts,'DadosSalvos','NTIA50');

arquivotxt=fullfile(pastadados,'dadosNTIA50.txt');

pastarelevos=fullfile(pastadados,'Relevos');

if exist(pastarelevos,'dir')==0
    mkdir(pastarelevos)
end

%% Conferir arquivo de dados

if exist(arquivotxt,'file')~=2
    error('O arquivo dadosNTIA50.txt não foi encontrado.')
end

%% Ler dados da NTIA

dados=readtable(arquivotxt,'Delimiter',',');

if height(dados)~=50
    error(['Foram encontrados ' num2str(height(dados)) ' casos em vez de 50.'])
end

%% Informações da publicação

% Fonte:
% NTIA TR-26-580, A Comparative Analysis of Multiple Knife-Edge
% Diffraction Methods, outubro de 2025.
%
% Tabelas 12 e 13: distâncias e alturas dos 50 cenários.
% Tabelas 17 e 18: perdas publicadas para Vogler, Giovaneli,
% Deygout e Epstein-Peterson.
%
% Todos os cenários usam 1500 MHz e alturas Tx/Rx iguais a zero.
% Os valores das tabelas representam geometrias sintéticas de gumes.
%
% Não aplicar raioefetivo nestes perfis.

%% Preparar resumo

casos=zeros(50,1);

gumesvetor=zeros(50,1);

amostras=zeros(50,1);

passos=zeros(50,1);

distanciaesperada=zeros(50,1);

distanciagerada=zeros(50,1);

errogeometria=zeros(50,1);

%% Gerar os 50 relevos sintéticos

wgs84=wgs84Ellipsoid("m");

raioequatorial=wgs84.SemimajorAxis;

for caso=1:50

    %% Obter dados do caso

    gumes=dados.Gumes(caso);

    freq=dados.FreqHz(caso);

    alturat=dados.AlturaTx(caso);

    alturar=dados.AlturaRx(caso);

    distanciastodas=[dados.D1(caso) dados.D2(caso) dados.D3(caso) dados.D4(caso) dados.D5(caso) dados.D6(caso)];

    alturastodas=[dados.H1(caso) dados.H2(caso) dados.H3(caso) dados.H4(caso) dados.H5(caso) dados.H6(caso)];

    distanciasgumes=distanciastodas(1:gumes);

    alturasgumes=alturastodas(1:gumes);

    distanciarx=dados.DRx(caso);

    %% Conferir posições

    posicoes=[distanciasgumes distanciarx];

    if any(abs(posicoes-round(posicoes))>10^-10)
        error(['O caso ' num2str(caso) ' possui distância não inteira e precisa de outro método de amostragem.'])
    end

    %% Encontrar maior passo que preserva exatamente todos os gumes

    posicoesinteiras=round(posicoes);

    passo=posicoesinteiras(1);

    for i=2:length(posicoesinteiras)
        passo=gcd(passo,posicoesinteiras(i));
    end

    if passo<=0
        error(['Não foi possível definir o passo do caso ' num2str(caso) '.'])
    end

    %% Criar eixo de distância igualmente espaçado

    distancia=0:passo:distanciarx;

    if abs(distancia(end)-distanciarx)>10^-10
        error(['O receptor do caso ' num2str(caso) ' não coincidiu com o eixo de distância.'])
    end

    n=length(distancia);

    %% Criar perfil sintético

    % Os pontos intermediários são colocados ligeiramente abaixo da linha
    % de referência. Somente os gumes informados pela NTIA entram nos
    % cálculos de validação.

    altura=-10^-6*ones(1,n);

    altura(1)=0;

    altura(end)=0;

    indexgumes=zeros(1,gumes);

    for i=1:gumes

        indice=round(distanciasgumes(i)/passo)+1;

        indexgumes(i)=indice;

        altura(indice)=alturasgumes(i);

    end

    %% Criar coordenadas geográficas sintéticas

    % O perfil é colocado sobre o equador. Assim, o arco geodésico sobre
    % o elipsoide WGS84 reproduz as distâncias horizontais das tabelas.

    latitude=zeros(1,n);

    longitude=(distancia/raioequatorial)*(180/pi);

    dadoselev=[latitude;longitude;altura];

    %% Conferir distância gerada

    distanciateste=txrx(1,n,0,0,dadoselev);

    erro=distanciateste-distanciarx;

    if abs(erro)>10^-6
        error(['Erro de distância no caso ' num2str(caso) ': ' num2str(erro) ' m.'])
    end

    %% Salvar caso

    nomearquivo=['DadosNTIACaso' num2str(caso) '.mat'];

    caminhoarquivo=fullfile(pastarelevos,nomearquivo);

    save(caminhoarquivo,'dadoselev','indexgumes','gumes','freq','alturat','alturar','caso','distanciasgumes','alturasgumes','distancia','passo');

    %% Guardar resumo

    casos(caso)=caso;

    gumesvetor(caso)=gumes;

    amostras(caso)=n;

    passos(caso)=passo;

    distanciaesperada(caso)=distanciarx;

    distanciagerada(caso)=distanciateste;

    errogeometria(caso)=erro;

    %% Mostrar progresso

    fprintf('Caso %2d | Gumes: %d | Passo: %4d m | Amostras: %4d | Distância: %.3f m\n',caso,gumes,passo,n,distanciateste)

end

%% Criar resumo

resumo=table(casos,gumesvetor,passos,amostras,distanciaesperada,distanciagerada,errogeometria);

resumo.Properties.VariableNames={'Caso','Gumes','Passo_m','Amostras','DistanciaEsperada_m','DistanciaGerada_m','ErroDistancia_m'};

%% Salvar resumo

writetable(resumo,fullfile(pastadados,'ResumoRelevosNTIA50.csv'));

%% Mostrar resultado

fprintf('\n')
fprintf('============================================================\n')
fprintf('GERAÇÃO DOS 50 CASOS DA NTIA CONCLUÍDA\n')
fprintf('============================================================\n')
fprintf('Maior erro de distância: %.12f m\n',max(abs(errogeometria)))
fprintf('Arquivos salvos em:\n')
fprintf('%s\n',pastarelevos)
fprintf('============================================================\n')
