function dadoselev=dadoselevgoogle(lat1,lon1,lat2,lon2,amostras,API_KEY)

%% Consultar dados de elevação

[elevations,~,latitudes,longitudes]=getElevationsPath(lat1,lon1,lat2,lon2,amostras,'key',API_KEY);

%% Organizar dados

dadoselev=zeros(3,amostras);

dadoselev(1,:)=latitudes;

dadoselev(2,:)=longitudes;

dadoselev(3,:)=elevations;

end