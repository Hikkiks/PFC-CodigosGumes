function [dadoselev,resolucao]=dadoselevresolucao(lat1,lon1,lat2,lon2,amostras,API_KEY)

%% Criar pontos igualmente espaçados no enlace

latitudes=linspace(lat1,lat2,amostras);

longitudes=linspace(lon1,lon2,amostras);

dadoselev=zeros(3,amostras);

resolucao=zeros(1,amostras);

%% Consultar cada ponto individualmente

for i=1:1:amostras

    url=['https://maps.googleapis.com/maps/api/elevation/json?locations=' num2str(latitudes(i),15) ',' num2str(longitudes(i),15) '&key=' API_KEY];

    resposta=webread(url);

    %% Verificar resposta da API

    if strcmp(resposta.status,'OK')==false

        error(['Erro na consulta da API no ponto ' num2str(i) ': ' resposta.status])

    end

    %% Salvar dados do ponto

    resultado=resposta.results(1);

    dadoselev(1,i)=resultado.location.lat;

    dadoselev(2,i)=resultado.location.lng;

    dadoselev(3,i)=resultado.elevation;

    resolucao(i)=resultado.resolution;

    fprintf('Ponto %d/%d | Elevação = %.2f m | Resolução = %.2f m\n',i,amostras,dadoselev(3,i),resolucao(i))

end

end