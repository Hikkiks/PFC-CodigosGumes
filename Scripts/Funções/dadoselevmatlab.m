function dadoselev=dadoselevmatlab(lat1,lon1,lat2,lon2,amostras)

%% Gerar coordenadas do enlace

delta=linspace(0,1,amostras);

vetorlat=lat1+(lat2-lat1)*delta;

vetorlon=lon1+(lon2-lon1)*delta;

%% Inicializar matriz de dados

dadoselev=zeros(3,amostras);

%% Consultar elevação dos pontos

for i=1:1:amostras

    elev=txsite('Latitude',vetorlat(i),'Longitude',vetorlon(i));

    dadoselev(1,i)=vetorlat(i);

    dadoselev(2,i)=vetorlon(i);

    dadoselev(3,i)=elevation(elev);

end

end