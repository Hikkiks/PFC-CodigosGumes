clear
clc
close all

%% Definir caminhos

pastateste=fileparts(mfilename('fullpath'));

pastascripts=fileparts(pastateste);

addpath(fullfile(pastascripts,'Funções'))

pastarelevos=fullfile(pastascripts,'DadosSalvos','RelevosLorenco85');

arquivotxt=fullfile(pastascripts,'dadoslorencocompleto.txt');

pastasaida=fullfile(pastateste,'ResultadosVarredura85');

if exist(pastasaida,'dir')==0
    mkdir(pastasaida)
end

%% Conferir caminhos

if exist(pastarelevos,'dir')~=7
    error('A pasta RelevosLorenco85 não foi encontrada.')
end

if exist(arquivotxt,'file')~=2
    error('O arquivo dadoslorencocompleto.txt não foi encontrado.')
end

if exist('preparageometria','file')~=2
    error('A função preparageometria não foi encontrada.')
end

%% Definir parâmetros

freq=575.142857*10^6;

alturat=10;

alturar=10;

%% Definir coordenada Tx

lattx=-18.8825;

lontx=-48.25083;

%% Ler dados de referência de Lorenço

arquivo=fopen(arquivotxt,'r');

if arquivo==-1
    error('Não foi possível abrir o arquivo dadoslorencocompleto.txt.')
end

dados=textscan(arquivo,'%s %s %s %s %s %f');

fclose(arquivo);

latitudes=str2double(strrep(dados{1},',','.'));

longitudes=str2double(strrep(dados{2},',','.'));

epsteinlorenco=str2double(strrep(dados{3},',','.'));

deygoutlorenco=str2double(strrep(dados{4},',','.'));

giovanelilorenco=str2double(strrep(dados{5},',','.'));

gumeslorenco=dados{6};

quantidade=length(giovanelilorenco);

%% Conferir quantidade

if quantidade~=85
    error('O arquivo de referência não possui exatamente 85 casos.')
end

%% Preparar variáveis

relevos=cell(quantidade,1);

indicesoriginais=cell(quantidade,1);

geometrias=cell(quantidade,1);

gumesoriginais=zeros(quantidade,1);

giooriginal=zeros(quantidade,1);

%% Preparar informações dos perfis

amostrasperfil=zeros(quantidade,1);

distanciaperfil=zeros(quantidade,1);

latitudetxperfil=zeros(quantidade,1);

longitudetxperfil=zeros(quantidade,1);

latituderxperfil=zeros(quantidade,1);

longituderxperfil=zeros(quantidade,1);

%% Iniciar preparação

fprintf('\n')
fprintf('====================================================================\n')
fprintf('PREPARAÇÃO DA VARREDURA DOS 85 CASOS - SEM FRESNEL\n')
fprintf('====================================================================\n')
fprintf('Pasta dos relevos:\n')
fprintf('%s\n',pastarelevos)
fprintf('\n')
fprintf('Tx utilizado: %.5f, %.5f\n',lattx,lontx)
fprintf('Frequência: %.6f MHz\n',freq/10^6)
fprintf('Altura Tx: %.2f m\n',alturat)
fprintf('Altura Rx: %.2f m\n',alturar)
fprintf('Casos: %d\n',quantidade)
fprintf('====================================================================\n\n')

tic

wgs84=wgs84Ellipsoid("m");

%% Preparar os 85 casos

for i=1:quantidade

    %% Carregar relevo

    nomearquivo=['DadosElevLorenco' num2str(i) '.mat'];

    caminhoarquivo=fullfile(pastarelevos,nomearquivo);

    if exist(caminhoarquivo,'file')~=2
        error(['O arquivo ' nomearquivo ' não foi encontrado.'])
    end

    dadosrelevo=load(caminhoarquivo,'dadoselev');

    if isfield(dadosrelevo,'dadoselev')==false
        error(['A variável dadoselev não foi encontrada em ' nomearquivo])
    end

    dadoselev=dadosrelevo.dadoselev;

    %% Conferir estrutura

    if size(dadoselev,1)~=3
        error(['O perfil ' num2str(i) ' não possui três linhas.'])
    end

    if any(isfinite(dadoselev(:))==false)
        error(['O perfil ' num2str(i) ' possui NaN ou Inf.'])
    end

    %% Guardar informações do perfil bruto

    amostrasperfil(i)=size(dadoselev,2);

    latitudetxperfil(i)=dadoselev(1,1);

    longitudetxperfil(i)=dadoselev(2,1);

    latituderxperfil(i)=dadoselev(1,end);

    longituderxperfil(i)=dadoselev(2,end);

    %% Conferir Tx

    if abs(latitudetxperfil(i)-lattx)>1e-4 || abs(longitudetxperfil(i)-lontx)>1e-4
        error(['A coordenada Tx do perfil ' num2str(i) ' não corresponde à coordenada utilizada.'])
    end

    %% Conferir Rx

    if abs(latituderxperfil(i)-latitudes(i))>1e-4 || abs(longituderxperfil(i)-longitudes(i))>1e-4
        error(['A coordenada Rx do perfil ' num2str(i) ' não corresponde ao arquivo de referência.'])
    end

    %% Calcular distância horizontal do perfil

    distancia=0;

    for j=2:size(dadoselev,2)

        distancia=distancia+distance(dadoselev(1,j-1),dadoselev(2,j-1),dadoselev(1,j),dadoselev(2,j),wgs84);

    end

    distanciaperfil(i)=distancia/1000;

    %% Aplicar correção do raio efetivo

    dadoselev=raioefetivo(dadoselev);

    relevos{i}=dadoselev;

    %% Identificar gumes sem Fresnel

    [indexgumes,gumes]=indexgumess(dadoselev,alturat,alturar,freq,false);

    indicesoriginais{i}=indexgumes;

    gumesoriginais(i)=gumes;

    %% Preparar geometria para o filtro

    geometrias{i}=preparageometria(indexgumes,dadoselev,alturat,alturar,freq);

    %% Calcular Giovaneli original

    perda=perdagiovaneli(indexgumes,dadoselev,freq,gumes,alturar,alturat);

    giooriginal(i)=-perda;

    %% Mostrar progresso

    fprintf('Caso %2d de %2d | Gumes Lucas: %2d | Lorenço: %2d | Gio Lucas: %8.3f | Lorenço: %8.3f\n',i,quantidade,gumes,gumeslorenco(i),giooriginal(i),giovanelilorenco(i))

end

tempo=toc;

%% Calcular diferenças dos gumes

difgumes=gumesoriginais-gumeslorenco;

totalgumeslucas=sum(gumesoriginais);

totalgumeslorenco=sum(gumeslorenco);

acertosgumes=sum(difgumes==0);

errototalgumes=sum(abs(difgumes));

casosacima=sum(difgumes>0);

casosiguais=sum(difgumes==0);

casosabaixo=sum(difgumes<0);

excessogumes=sum(max(difgumes,0));

deficitgumes=sum(max(-difgumes,0));

%% Calcular erros de Giovaneli

errogio=giooriginal-giovanelilorenco;

biasgio=mean(errogio);

desviogio=std(errogio,1);

maegio=mean(abs(errogio));

rmsegio=sqrt(mean(errogio.^2));

erromaxgio=max(abs(errogio));

medianagio=median(errogio);

madgio=median(abs(errogio-medianagio));

errocentralizado=errogio-biasgio;

maecentralizado=mean(abs(errocentralizado));

rmsecentralizado=sqrt(mean(errocentralizado.^2));

%% Calcular correlação

matrizcorrelacao=corrcoef(giooriginal,giovanelilorenco);

if size(matrizcorrelacao,1)==2

    correlacao=matrizcorrelacao(1,2);

else

    correlacao=NaN;

end

%% Calcular ajuste linear

ajuste=polyfit(giovanelilorenco,giooriginal,1);

inclinacao=ajuste(1);

intercepto=ajuste(2);

%% Criar tabela dos 85 casos

linha=(1:quantidade)';

resultado=table(linha,latitudes,longitudes,amostrasperfil,distanciaperfil,gumesoriginais,gumeslorenco,difgumes,giooriginal,giovanelilorenco,errogio);

resultado.Properties.VariableNames={'Caso','LatitudeRx','LongitudeRx','Amostras','Distancia_km','GumesLucas','GumesLorenco','DiferencaGumes','GiovaneliLucas','GiovaneliLorenco','ErroGiovaneli'};

%% Criar tabela de resumo

txlatitude=lattx;

txlongitude=lontx;

frequencia=freq;

alturatx=alturat;

alturarx=alturar;

resumo=table(txlatitude,txlongitude,frequencia,alturatx,alturarx,quantidade,totalgumeslucas,totalgumeslorenco,acertosgumes,errototalgumes,casosacima,casosiguais,casosabaixo,excessogumes,deficitgumes,biasgio,desviogio,maegio,rmsegio,erromaxgio,maecentralizado,rmsecentralizado,madgio,correlacao,inclinacao,intercepto);

resumo.Properties.VariableNames={'LatitudeTx','LongitudeTx','FrequenciaHz','AlturaTx','AlturaRx','Casos','TotalGumesLucas','TotalGumesLorenco','AcertosExatosGumes','ErroTotalGumes','CasosAcima','CasosIguais','CasosAbaixo','ExcessoTotalGumes','DeficitTotalGumes','BiasGiovaneli','DesvioGiovaneli','MAEGiovaneli','RMSEGiovaneli','ErroMaximoGiovaneli','MAECentralizado','RMSECentralizado','MADGiovaneli','Correlacao','Inclinacao','Intercepto'};

%% Mostrar resumo

fprintf('\n')
fprintf('====================================================================\n')
fprintf('RESUMO DA PREPARAÇÃO DOS 85 CASOS\n')
fprintf('====================================================================\n')
fprintf('Tx: %.5f, %.5f\n',lattx,lontx)
fprintf('--------------------------------------------------------------------\n')
fprintf('GUMES\n')
fprintf('--------------------------------------------------------------------\n')
fprintf('Total Lucas:                %d\n',totalgumeslucas)
fprintf('Total Lorenço:              %d\n',totalgumeslorenco)
fprintf('Acertos exatos:             %d de %d\n',acertosgumes,quantidade)
fprintf('Erro absoluto total:        %d\n',errototalgumes)
fprintf('Casos acima de Lorenço:     %d\n',casosacima)
fprintf('Casos iguais a Lorenço:     %d\n',casosiguais)
fprintf('Casos abaixo de Lorenço:    %d\n',casosabaixo)
fprintf('Excesso total:              %d\n',excessogumes)
fprintf('Déficit total:              %d\n',deficitgumes)
fprintf('--------------------------------------------------------------------\n')
fprintf('GIOVANELI\n')
fprintf('--------------------------------------------------------------------\n')
fprintf('Erro médio:                 %+.6f dB\n',biasgio)
fprintf('Desvio:                     %.6f dB\n',desviogio)
fprintf('MAE:                        %.6f dB\n',maegio)
fprintf('RMSE:                       %.6f dB\n',rmsegio)
fprintf('Erro máximo:                %.6f dB\n',erromaxgio)
fprintf('MAE centralizado:           %.6f dB\n',maecentralizado)
fprintf('RMSE centralizado:          %.6f dB\n',rmsecentralizado)
fprintf('MAD:                        %.6f dB\n',madgio)
fprintf('Correlação:                 %.6f\n',correlacao)
fprintf('Inclinação:                 %.6f\n',inclinacao)
fprintf('Intercepto:                 %+.6f\n',intercepto)
fprintf('--------------------------------------------------------------------\n')
fprintf('Tempo de preparação:        %.2f s\n',tempo)
fprintf('====================================================================\n')

%% Salvar tabelas

writetable(resultado,fullfile(pastasaida,'BasePreparacaoVarredura85.csv'));

writetable(resumo,fullfile(pastasaida,'ResumoPreparacaoVarredura85.csv'));

%% Salvar preparação

save(fullfile(pastasaida,'PreparacaoVarredura85.mat'),'relevos','indicesoriginais','geometrias','gumesoriginais','giooriginal','giovanelilorenco','gumeslorenco','epsteinlorenco','deygoutlorenco','latitudes','longitudes','amostrasperfil','distanciaperfil','freq','alturat','alturar','lattx','lontx','quantidade','-v7.3');

%% Mostrar finalização

fprintf('\n')
fprintf('Arquivos salvos em:\n')
fprintf('%s\n',pastasaida)
fprintf('\n')
fprintf('Preparação concluída.\n')