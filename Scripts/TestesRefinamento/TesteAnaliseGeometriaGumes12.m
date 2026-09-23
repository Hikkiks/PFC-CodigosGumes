clear
clc
close all

%% Definir caminhos

pastateste=fileparts(mfilename('fullpath'));

pastascripts=fileparts(pastateste);

addpath(fullfile(pastascripts,'Funções'))

pastadados=fullfile(pastascripts,'DadosSalvos','DadosConclusao');

pastasaida=fullfile(pastateste,'ResultadosAnaliseGeometria12Casos');

if exist(pastasaida,'dir')==0
    mkdir(pastasaida);
end

%% Definir dados de referência de Lorenço

gumeslorencoe1=[3 3 4 3 3 2];

gumeslorencoe2=[2 2 3 3 3 1];

%% Definir parâmetros das emissoras

frequenciae1=557.142857*10^6;

alturate1=76.2;

frequenciae2=581.142857*10^6;

alturate2=113;

alturar=1.5;

%% Definir casos

casos=1:6;

%% Preparar resultados gerais

emissorageral=[];

pontogeral=[];

gumegeral=[];

indicegeral=[];

observacaogeral=[];

distanciageral=[];

altitudegeral=[];

distanteriorgeral=[];

tangentegeral=[];

angulogerald=[];

excessogeral=[];

hgeral=[];

vgeral=[];

deltatangentegeral=[];

%% Processar emissoras

for emissora=1:2

    if emissora==1

        freq=frequenciae1;

        alturat=alturate1;

        gumeslorenco=gumeslorencoe1;

    else

        freq=frequenciae2;

        alturat=alturate2;

        gumeslorenco=gumeslorencoe2;

    end

    lambda=(3*10^8)/freq;

    %% Processar seis pontos

    for ponto=casos

        %% Carregar perfil

        nomearquivo=['DadosConclusaoE' num2str(emissora) 'P' num2str(ponto) '.mat'];

        caminhoarquivo=fullfile(pastadados,nomearquivo);

        dados=load(caminhoarquivo);

        dadoselev=dados.dadoselev;

        %% Aplicar correção do raio efetivo

        dadoselev=raioefetivo(dadoselev);

        %% Identificar gumes

        [indexgumes,gumes]=indexgumess(dadoselev,alturat,alturar,freq,false);

        %% Calcular distância acumulada

        n=size(dadoselev,2);

        wgs84=wgs84Ellipsoid("m");

        distancia=zeros(1,n);

        for i=2:n

            distancia(i)=distancia(i-1)+distance(dadoselev(1,i-1),dadoselev(2,i-1),dadoselev(1,i),dadoselev(2,i),wgs84);

        end

        %% Preparar alturas usadas no detector

        altura=dadoselev(3,:);

        altura(1)=altura(1)+alturat;

        altura(end)=altura(end)+alturar;

        %% Mostrar cabeçalho do caso

        fprintf('\n')
        fprintf('============================================================\n')
        fprintf('Emissora %d - Ponto %d\n',emissora,ponto)
        fprintf('============================================================\n')
        fprintf('Gumes calculados: %d\n',gumes)
        fprintf('Gumes Lorenço: %d\n',gumeslorenco(ponto))
        fprintf('Diferença: %+d\n',gumes-gumeslorenco(ponto))
        fprintf('Distância total: %.3f km\n',distancia(end)/1000)

        %% Verificar ausência de gumes

        if gumes==0

            fprintf('Nenhum gume encontrado.\n')

            continue

        end

        %% Preparar vetores do caso

        ordem=zeros(gumes,1);

        indice=zeros(gumes,1);

        observacao=zeros(gumes,1);

        distanciaquilometros=zeros(gumes,1);

        altitude=zeros(gumes,1);

        distanciaanterior=zeros(gumes,1);

        tangente=zeros(gumes,1);

        angulo=zeros(gumes,1);

        excessovisada=zeros(gumes,1);

        hperpendicular=zeros(gumes,1);

        v=zeros(gumes,1);

        mudancatangente=zeros(gumes,1);

        %% Calcular propriedades geométricas

        for y=1:gumes

            indexgume=indexgumes(y);

            if y==1

                indexobs=1;

            else

                indexobs=indexgumes(y-1);

            end

            ordem(y)=y;

            indice(y)=indexgume;

            observacao(y)=indexobs;

            distanciaquilometros(y)=distancia(indexgume)/1000;

            altitude(y)=altura(indexgume);

            distanciaanterior(y)=distancia(indexgume)-distancia(indexobs);

            %% Calcular tangente entre observação e gume

            deltax=distancia(indexgume)-distancia(indexobs);

            deltaz=altura(indexgume)-altura(indexobs);

            tangente(y)=deltaz/deltax;

            angulo(y)=atan(tangente(y))*180/pi;

            %% Calcular excesso em relação à visada observação-Rx

            distanciaobsrx=distancia(end)-distancia(indexobs);

            inclinacaovisada=(altura(end)-altura(indexobs))/distanciaobsrx;

            alturavisada=altura(indexobs)+inclinacaovisada*(distancia(indexgume)-distancia(indexobs));

            excessovisada(y)=altura(indexgume)-alturavisada;

            %% Calcular h perpendicular

            x1=distancia(indexobs);

            z1=altura(indexobs);

            x2=distancia(end);

            z2=altura(end);

            xg=distancia(indexgume);

            zg=altura(indexgume);

            numerador=(x2-x1)*(zg-z1)-(z2-z1)*(xg-x1);

            denominador=sqrt((x2-x1)^2+(z2-z1)^2);

            hperpendicular(y)=numerador/denominador;

            %% Calcular distâncias para v

            d1horizontal=xg-x1;

            d2horizontal=x2-xg;

            inclinacao=(z2-z1)/(x2-x1);

            fator=sqrt(1+inclinacao^2);

            d1f=d1horizontal*fator;

            d2f=d2horizontal*fator;

            %% Calcular parâmetro v

            v(y)=hperpendicular(y)*sqrt((2*(d1f+d2f))/(lambda*d1f*d2f));

            %% Calcular mudança de tangente

            if y==1

                mudancatangente(y)=NaN;

            else

                mudancatangente(y)=tangente(y)-tangente(y-1);

            end

        end

        %% Criar tabela do caso

        resultados=table(ordem,indice,observacao,distanciaquilometros,altitude,distanciaanterior,tangente,angulo,excessovisada,hperpendicular,v,mudancatangente);

        resultados.Properties.VariableNames={'Gume','Indice','Observacao','Distanciakm','Altitude','DistAnterior','Tangente','Angulograus','ExcessoLOS','h','v','DeltaTangente'};

        fprintf('\n')

        disp(resultados)

        %% Mostrar separação entre gumes consecutivos

        if gumes>1

            fprintf('\n')
            fprintf('Separação entre gumes consecutivos\n')
            fprintf('------------------------------------------------------------\n')

            for y=2:gumes

                separacao=distancia(indexgumes(y))-distancia(indexgumes(y-1));

                diferencaaltura=altura(indexgumes(y))-altura(indexgumes(y-1));

                fprintf('Gume %d -> %d: %.2f m | Delta altura = %.3f m\n',y-1,y,separacao,diferencaaltura)

            end

        end

        %% Armazenar resultados gerais

        for y=1:gumes

            emissorageral=[emissorageral; emissora];

            pontogeral=[pontogeral; ponto];

            gumegeral=[gumegeral; ordem(y)];

            indicegeral=[indicegeral; indice(y)];

            observacaogeral=[observacaogeral; observacao(y)];

            distanciageral=[distanciageral; distanciaquilometros(y)];

            altitudegeral=[altitudegeral; altitude(y)];

            distanteriorgeral=[distanteriorgeral; distanciaanterior(y)];

            tangentegeral=[tangentegeral; tangente(y)];

            angulogerald=[angulogerald; angulo(y)];

            excessogeral=[excessogeral; excessovisada(y)];

            hgeral=[hgeral; hperpendicular(y)];

            vgeral=[vgeral; v(y)];

            deltatangentegeral=[deltatangentegeral; mudancatangente(y)];

        end

    end

end

%% Criar tabela geral

tabelageral=table(emissorageral,pontogeral,gumegeral,indicegeral,observacaogeral,distanciageral,altitudegeral,distanteriorgeral,tangentegeral,angulogerald,excessogeral,hgeral,vgeral,deltatangentegeral);

tabelageral.Properties.VariableNames={'Emissora','Ponto','Gume','Indice','Observacao','Distanciakm','Altitude','DistAnterior','Tangente','Angulograus','ExcessoLOS','h','v','DeltaTangente'};

%% Mostrar resumo das quantidades de gumes

fprintf('\n')
fprintf('============================================================\n')
fprintf('RESUMO DAS QUANTIDADES DE GUMES\n')
fprintf('============================================================\n')

fprintf('\nEmissora 1\n')

for ponto=1:6

    nomearquivo=['DadosConclusaoE1P' num2str(ponto) '.mat'];

    dados=load(fullfile(pastadados,nomearquivo));

    perfil=raioefetivo(dados.dadoselev);

    [~,gumes]=indexgumess(perfil,alturate1,alturar,frequenciae1,false);

    fprintf('P%d: Calculado %d | Lorenço %d | Diferença %+d\n',ponto,gumes,gumeslorencoe1(ponto),gumes-gumeslorencoe1(ponto))

end

fprintf('\nEmissora 2\n')

for ponto=1:6

    nomearquivo=['DadosConclusaoE2P' num2str(ponto) '.mat'];

    dados=load(fullfile(pastadados,nomearquivo));

    perfil=raioefetivo(dados.dadoselev);

    [~,gumes]=indexgumess(perfil,alturate2,alturar,frequenciae2,false);

    fprintf('P%d: Calculado %d | Lorenço %d | Diferença %+d\n',ponto,gumes,gumeslorencoe2(ponto),gumes-gumeslorencoe2(ponto))

end

%% Salvar resultados

caminhomat=fullfile(pastasaida,'AnaliseGumes12Casos.mat');

save(caminhomat,'tabelageral');

caminhocsv=fullfile(pastasaida,'AnaliseGumes12Casos.csv');

writetable(tabelageral,caminhocsv);

fprintf('\n')
fprintf('Resultados salvos em:\n')
fprintf('%s\n',pastasaida)