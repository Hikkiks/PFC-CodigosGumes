function indexfiltrado=aplicafiltrodinamico(indexoriginal,geometria,limiteh,limitev,limiteangulo,limitedistancia)

%% Informações iniciais

gumes=length(indexoriginal);

if gumes<=1

    indexfiltrado=indexoriginal;

    return

end

%% Inicializar seleção dos gumes

manter=false(gumes,1);

manter(1)=true;

ultimomantido=1;

anguloreferencia=geometria.angulo(1,1);

%% Avaliar os gumes

for i=2:gumes

    linhaobservacao=ultimomantido+1;

    h=geometria.h(linhaobservacao,i);

    v=geometria.v(linhaobservacao,i);

    angulo=geometria.angulo(linhaobservacao,i);

    distancia=geometria.distancia(linhaobservacao,i);

    %% Calcular diferença angular

    deltaangulo=abs(angulo-anguloreferencia);

    %% Verificar critérios do filtro

    hpequeno=abs(h)<=limiteh;

    vpequeno=abs(v)<=limitev;

    anguloparecido=deltaangulo<=limiteangulo;

    proximos=distancia<=limitedistancia;

    %% Manter ou remover o gume

    if hpequeno==true && vpequeno==true && anguloparecido==true && proximos==true

        manter(i)=false;

    else

        manter(i)=true;

        ultimomantido=i;

        anguloreferencia=angulo;

    end

end

%% Retornar gumes filtrados

indexfiltrado=indexoriginal(manter);

end