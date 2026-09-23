function geometria=preparageometria(indexgumes,dadoselev,alturat,alturar,freq)

%% Informações iniciais

n=size(dadoselev,2);

gumes=length(indexgumes);

lambda=(3*10^8)/freq;

%% Calcular distância acumulada

wgs84=wgs84Ellipsoid("m");

distancia=zeros(1,n);

for i=2:n

    distancia(i)=distancia(i-1)+distance(dadoselev(1,i-1),dadoselev(2,i-1),dadoselev(1,i),dadoselev(2,i),wgs84);

end

%% Preparar alturas

altura=dadoselev(3,:);

altura(1)=altura(1)+alturat;

altura(end)=altura(end)+alturar;

%% Inicializar matrizes geométricas

hmat=nan(gumes+1,gumes);

vmat=nan(gumes+1,gumes);

angulomat=nan(gumes+1,gumes);

distanciamat=nan(gumes+1,gumes);

%% Calcular geometria dos candidatos

for candidato=1:gumes

    indicecandidato=indexgumes(candidato);

    for linhaobservacao=1:candidato

        %% Definir ponto de observação

        if linhaobservacao==1

            indiceobservacao=1;

            alturaantena=alturat;

        else

            indiceobservacao=indexgumes(linhaobservacao-1);

            alturaantena=0;

        end

        if indiceobservacao>=indicecandidato

            continue

        end

        %% Calcular distância e ângulo

        deltadistancia=distancia(indicecandidato)-distancia(indiceobservacao);

        deltaaltura=altura(indicecandidato)-altura(indiceobservacao);

        tangente=deltaaltura/deltadistancia;

        angulomat(linhaobservacao,candidato)=atan(tangente)*180/pi;

        distanciamat(linhaobservacao,candidato)=deltadistancia;

        %% Calcular geometria do gume

        d1=txrx(indiceobservacao,indicecandidato,alturaantena,0,dadoselev);

        d2=txrx(indicecandidato,n,0,alturar,dadoselev);

        d3=txrx(indiceobservacao,n,alturaantena,alturar,dadoselev);

        [h,d1f,d2f]=valorcos(d1,d2,d3);

        %% Verificar sinal de h

        proporcao=(distancia(indicecandidato)-distancia(indiceobservacao))/(distancia(end)-distancia(indiceobservacao));

        alturalinha=altura(indiceobservacao)+(altura(end)-altura(indiceobservacao))*proporcao;

        if altura(indicecandidato)<alturalinha

            h=-h;

        end

        %% Calcular parâmetro v

        v=h*sqrt((2/lambda)*((d1f+d2f)/(d1f*d2f)));

        %% Armazenar parâmetros

        hmat(linhaobservacao,candidato)=h;

        vmat(linhaobservacao,candidato)=v;

    end

end

%% Organizar resultado

geometria.h=hmat;

geometria.v=vmat;

geometria.angulo=angulomat;

geometria.distancia=distanciamat;

end