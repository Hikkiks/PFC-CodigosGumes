function distancia=txrx(index1,index2,atx,arx,dadoselev)

%% Informações iniciais

n=size(dadoselev,2);

%% Verificar índices

if index1<1 || index1>n || index2<1 || index2>n

    error('Os índices devem estar dentro do tamanho de dadoselev.')

end

%% Calcular distância horizontal

wgs84=wgs84Ellipsoid("m");

d=0;

for i=(index1+1):1:index2

    d=d+distance(dadoselev(1,i-1),dadoselev(2,i-1),dadoselev(1,i),dadoselev(2,i),wgs84);

end

%% Calcular diferença de altura

h=(dadoselev(3,index1)+atx)-(dadoselev(3,index2)+arx);

%% Calcular distância tridimensional

distancia=sqrt((h^2)+(d^2));

end