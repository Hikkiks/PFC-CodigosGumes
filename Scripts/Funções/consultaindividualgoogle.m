function [elevacao,resolucao]=consultaindividualgoogle(latitude,longitude,API_KEY)

%% Montar URL da consulta

url=['https://maps.googleapis.com/maps/api/elevation/json?locations=' num2str(latitude,15) ',' num2str(longitude,15) '&key=' API_KEY];

%% Consultar a API

resposta=webread(url);

%% Verificar resposta da API

if strcmp(resposta.status,'OK')==false

    error(['Erro na consulta da API: ' resposta.status])

end

%% Extrair resultados

resultado=resposta.results(1);

elevacao=resultado.elevation;

resolucao=resultado.resolution;

end