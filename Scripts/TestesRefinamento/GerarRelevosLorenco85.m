clear
clc
close all

%% Definir caminhos

pastateste=fileparts(mfilename('fullpath'));

pastascripts=fileparts(pastateste);

addpath(fullfile(pastascripts,'Funções'))

pastarelevos=fullfile(pastascripts,'DadosSalvos','RelevosLorenco85');

if exist(pastarelevos,'dir')==0
    mkdir(pastarelevos)
end

arquivotxt=fullfile(pastascripts,'dadoslorencocompleto.txt');

%% Definir dados da transmissora

LatTx=-18.8825;
LonTx=-48.25083;

%% Definir configurações

amostras=512;

API_KEY=getenv('GOOGLE_ELEVATION_API_KEY');

if isempty(API_KEY)==true
    error('Defina a variável de ambiente GOOGLE_ELEVATION_API_KEY.')
end

%% Conferir arquivo de entrada

if exist(arquivotxt,'file')~=2
    error('O arquivo dadoslorencocompleto.txt não foi encontrado.')
end

%% Ler pontos de recepção

arquivo=fopen(arquivotxt,'r');

if arquivo==-1
    error('Não foi possível abrir o arquivo dadoslorencocompleto.txt.')
end

dados=textscan(arquivo,'%s %s %s %s %s %f');

fclose(arquivo);

latitudes=str2double(strrep(dados{1},',','.'));

longitudes=str2double(strrep(dados{2},',','.'));

quantidade=length(latitudes);

if quantidade~=85
    error(['Foram encontrados ' num2str(quantidade) ' casos em vez de 85.'])
end

%% Coletar relevos

for i=1:quantidade

    LatRx=latitudes(i);
    LonRx=longitudes(i);

    disp('---------------------------------------')
    disp(['Coletando relevo ',num2str(i),' de ',num2str(quantidade)])
    disp(['Tx: ',num2str(LatTx),'  ',num2str(LonTx)])
    disp(['Rx: ',num2str(LatRx),'  ',num2str(LonRx)])

    dadoselev=dadoselevgoogle(LatTx,LonTx,LatRx,LonRx,amostras,API_KEY);

    nomearquivo=['DadosElevLorenco' num2str(i) '.mat'];

    caminhoarquivo=fullfile(pastarelevos,nomearquivo);

    save(caminhoarquivo,'dadoselev');

    disp(['Salvo: ',nomearquivo])

end

%% Mostrar finalização

disp('---------------------------------------')
disp('Coleta finalizada.')
disp(['Total de relevos salvos: ',num2str(quantidade)])
disp('---------------------------------------')