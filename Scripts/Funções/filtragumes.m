function [indexgumes,gumes,dadosfiltro]=filtragumes(indexgumes,dadoselev,alturat,alturar,freq,limiteh,limitev,limitetangente)

%% Informações iniciais

n=size(dadoselev,2);

gumesoriginais=length(indexgumes);

if gumesoriginais==0

    gumes=0;

    dadosfiltro=table;

    return

end

lambda=(3*10^8)/freq;

%% Preparar alturas

altura=dadoselev(3,:);

altura(1)=altura(1)+alturat;

altura(end)=altura(end)+alturar;

%% Calcular distância acumulada

wgs84=wgs84Ellipsoid("m");

distancia=zeros(1,n);

for i=2:n

    distancia(i)=distancia(i-1)+distance(dadoselev(1,i-1),dadoselev(2,i-1),dadoselev(1,i),dadoselev(2,i),wgs84);

end

%% Inicializar parâmetros dos gumes

observacao=zeros(gumesoriginais,1);

distanciagume=zeros(gumesoriginais,1);

hvetor=zeros(gumesoriginais,1);

vvetor=zeros(gumesoriginais,1);

tangente=zeros(gumesoriginais,1);

observacaoatual=1;

%% Calcular parâmetros dos gumes originais

for i=1:gumesoriginais

    indice=indexgumes(i);

    observacao(i)=observacaoatual;

    distanciagume(i)=distancia(indice);

    %% Calcular tangente do horizonte

    deltaaltura=altura(indice)-altura(observacaoatual);

    deltadistancia=distancia(indice)-distancia(observacaoatual);

    tangente(i)=deltaaltura/deltadistancia;

    %% Definir altura da antena no ponto de observação

    if observacaoatual==1

        alturaobservacao=alturat;

    else

        alturaobservacao=0;

    end

    %% Calcular geometria do gume

    d1=txrx(observacaoatual,indice,alturaobservacao,0,dadoselev);

    d2=txrx(indice,n,0,alturar,dadoselev);

    d3=txrx(observacaoatual,n,alturaobservacao,alturar,dadoselev);

    [h,d1f,d2f]=valorcos(d1,d2,d3);

    %% Verificar sinal de h

    proporcao=(distancia(indice)-distancia(observacaoatual))/(distancia(end)-distancia(observacaoatual));

    alturalinha=altura(observacaoatual)+(altura(end)-altura(observacaoatual))*proporcao;

    if altura(indice)<alturalinha

        h=-h;

    end

    hvetor(i)=h;

    %% Calcular parâmetro v

    vvetor(i)=h*sqrt((2/lambda)*((d1f+d2f)/(d1f*d2f)));

    %% Atualizar ponto de observação

    observacaoatual=indice;

end

%% Aplicar filtro

manter=true(gumesoriginais,1);

deltatangente=nan(gumesoriginais,1);

ultimo=1;

for i=2:gumesoriginais

    deltatangente(i)=abs(tangente(i)-tangente(ultimo));

    hpequeno=abs(hvetor(i))<=limiteh;

    vpequeno=abs(vvetor(i))<=limitev;

    tangenteparecida=deltatangente(i)<=limitetangente;

    if hpequeno==true && vpequeno==true && tangenteparecida==true

        manter(i)=false;

    else

        ultimo=i;

    end

end

%% Obter resultado

indiceoriginal=indexgumes(:);

indexgumes=indexgumes(manter);

gumes=length(indexgumes);

%% Organizar dados para conferência

dadosfiltro=table(indiceoriginal,observacao,distanciagume,hvetor,vvetor,tangente,deltatangente,manter);

dadosfiltro.Properties.VariableNames={'Indice','Observacao','Distancia','h','v','Tangente','DeltaTangente','Mantido'};

end