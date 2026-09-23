clear
clc
close all

%% Definir caminhos

pastateste=fileparts(mfilename('fullpath'));

pastascripts=fileparts(pastateste);

addpath(fullfile(pastascripts,'Funções'))

arquivolorenco=fullfile(pastascripts,'dadoslorencocompleto.txt');

pastaperfis=fullfile(pastascripts,'DadosSalvos','RelevosLorenco85');

pastasaida=fullfile(pastateste,'ResultadosFiltrosSelecionados85');

if exist(pastasaida,'dir')==0
    mkdir(pastasaida)
end

%% Verificar arquivo de Lorenço

if exist(arquivolorenco,'file')~=2
    error('O arquivo dadoslorencocompleto.txt não foi encontrado.')
end

%% Ler dados de Lorenço

texto=fileread(arquivolorenco);

texto=strrep(texto,',','.');

dadoslorenco=sscanf(texto,'%f',[6 Inf])';

if size(dadoslorenco,1)~=85
    error(['Foram encontradas ' num2str(size(dadoslorenco,1)) ' linhas no arquivo de Lorenço. Eram esperadas 85.'])
end

giovanelilorenco=dadoslorenco(:,5);

gumeslorenco=round(dadoslorenco(:,6));

%% Localizar perfis

arquivos=dir(fullfile(pastaperfis,'DadosElevLorenco*.mat'));

if length(arquivos)~=85
    error(['Foram encontrados ' num2str(length(arquivos)) ' arquivos MAT. Eram esperados 85.'])
end

arquivos=ordenaarquivos(arquivos);

%% Definir parâmetros gerais

ncasos=85;

freq=575.142857*10^6;

alturat=10;

alturar=10;

%% Definir configurações dos filtros

configuracoes=[206554 203964 200330 206074];

limitesh=[0.375 1.75 1.75 1.25];

limitesv=[0.10 0.06 0.40 0.35];

limitesangulo=[0.40 0.25 0.10 0.35];

limitesdistancia=[Inf Inf Inf Inf];

nfiltros=length(configuracoes);

%% Preparar matrizes de resultados

gumessemfiltro=zeros(ncasos,1);

giovanelisemfiltro=zeros(ncasos,1);

gumesfiltros=zeros(ncasos,nfiltros);

giovanelifiltros=zeros(ncasos,nfiltros);

%% Testar 85 perfis sem filtro

fprintf('\n')
fprintf('============================================================\n')
fprintf('TESTE SEM FILTRO\n')
fprintf('============================================================\n')
fprintf('\n')

for caso=1:ncasos

    caminho=fullfile(pastaperfis,arquivos(caso).name);

    dados=load(caminho);

    if isfield(dados,'dadoselev')==false
        error(['A variável dadoselev não foi encontrada em ' arquivos(caso).name])
    end

    dadoselev=dados.dadoselev;

    dadoselev=raioefetivo(dadoselev);

    [indexoriginal,gumesoriginal]=indexgumess(dadoselev,alturat,alturar,freq,false);

    perda=perdagiovaneli(indexoriginal,dadoselev,freq,gumesoriginal,alturar,alturat);

    giovaneli=-perda;

    gumessemfiltro(caso)=gumesoriginal;

    giovanelisemfiltro(caso)=giovaneli;

    fprintf('Caso %2d de %2d | Gumes: %2d | Giovaneli: %8.3f dB\n',caso,ncasos,gumesoriginal,giovaneli)

end

%% Mostrar resultado sem filtro

errosemfiltro=giovanelisemfiltro-giovanelilorenco;

maesemfiltro=mean(abs(errosemfiltro));

fprintf('\n')
fprintf('Resultado sem filtro:\n')
fprintf('Total de gumes: %d\n',sum(gumessemfiltro))
fprintf('MAE Giovaneli: %.4f dB\n',maesemfiltro)
fprintf('\n')

%% Testar quatro filtros selecionados

for filtro=1:nfiltros

    config=configuracoes(filtro);

    limiteh=limitesh(filtro);

    limitev=limitesv(filtro);

    limiteangulo=limitesangulo(filtro);

    limitedistancia=limitesdistancia(filtro);

    fprintf('\n')
    fprintf('============================================================\n')
    fprintf('FILTRO %d\n',config)
    fprintf('============================================================\n')
    fprintf('\n')

    fprintf('h = %.3f m\n',limiteh)
    fprintf('v = %.3f\n',limitev)
    fprintf('Ângulo = %.3f graus\n',limiteangulo)

    if isinf(limitedistancia)==true

        fprintf('Distância = sem limite\n')

    else

        fprintf('Distância = %.0f m\n',limitedistancia)

    end

    fprintf('\n')

    for caso=1:ncasos

        caminho=fullfile(pastaperfis,arquivos(caso).name);

        dados=load(caminho);

        if isfield(dados,'dadoselev')==false
            error(['A variável dadoselev não foi encontrada em ' arquivos(caso).name])
        end

        dadoselev=dados.dadoselev;

        dadoselev=raioefetivo(dadoselev);

        [indexoriginal,gumesoriginal]=indexgumess(dadoselev,alturat,alturar,freq,false);

        if gumesoriginal<=1

            indexfiltrado=indexoriginal;

        else

            geometria=preparageometria(indexoriginal,dadoselev,alturat,alturar,freq);

            indexfiltrado=aplicafiltrodinamico(indexoriginal,geometria,limiteh,limitev,limiteangulo,limitedistancia);

        end

        gumesfiltrado=length(indexfiltrado);

        perda=perdagiovaneli(indexfiltrado,dadoselev,freq,gumesfiltrado,alturar,alturat);

        giovaneli=-perda;

        gumesfiltros(caso,filtro)=gumesfiltrado;

        giovanelifiltros(caso,filtro)=giovaneli;

        fprintf('Caso %2d de %2d | Original: %2d | Filtrado: %2d | Giovaneli: %8.3f dB\n',caso,ncasos,gumesoriginal,gumesfiltrado,giovaneli)

    end

    erro=giovanelifiltros(:,filtro)-giovanelilorenco;

    mae=mean(abs(erro));

    casosalterados=sum(gumesfiltros(:,filtro)~=gumessemfiltro | abs(giovanelifiltros(:,filtro)-giovanelisemfiltro)>10^-10);

    fprintf('\n')
    fprintf('Resultado do filtro %d:\n',config)
    fprintf('Total de gumes: %d\n',sum(gumesfiltros(:,filtro)))
    fprintf('Casos alterados em relação ao teste sem filtro: %d de %d\n',casosalterados,ncasos)
    fprintf('MAE Giovaneli: %.4f dB\n',mae)
    fprintf('\n')

end

%% Criar tabela de gumes

casos=(1:ncasos)';

tabelagumes=table(casos,gumeslorenco,gumessemfiltro,gumesfiltros(:,1),gumesfiltros(:,2),gumesfiltros(:,3),gumesfiltros(:,4));

tabelagumes.Properties.VariableNames={'Caso','Lorenco','SemFiltro','Filtro206554','Filtro203964','Filtro200330','Filtro206074'};

fprintf('\n')
fprintf('============================================================\n')
fprintf('TABELA DE GUMES\n')
fprintf('============================================================\n')
fprintf('\n')

disp(tabelagumes)

%% Salvar tabela de gumes

arquivogumes=fullfile(pastasaida,'ComparacaoGumes85.csv');

writetable(tabelagumes,arquivogumes);

%% Criar tabela de Giovaneli

tabelagiovaneli=table(casos,giovanelilorenco,giovanelisemfiltro,giovanelifiltros(:,1),giovanelifiltros(:,2),giovanelifiltros(:,3),giovanelifiltros(:,4));

tabelagiovaneli.Properties.VariableNames={'Caso','Lorenco','SemFiltro','Filtro206554','Filtro203964','Filtro200330','Filtro206074'};

fprintf('\n')
fprintf('============================================================\n')
fprintf('TABELA DE GIOVANELI\n')
fprintf('============================================================\n')
fprintf('\n')

disp(tabelagiovaneli)

%% Salvar tabela de Giovaneli

arquivogiovaneli=fullfile(pastasaida,'ComparacaoGiovaneli85.csv');

writetable(tabelagiovaneli,arquivogiovaneli);

%% Criar tabela completa

tabelacompleta=table(casos,gumeslorenco,gumessemfiltro,gumesfiltros(:,1),gumesfiltros(:,2),gumesfiltros(:,3),gumesfiltros(:,4),giovanelilorenco,giovanelisemfiltro,giovanelifiltros(:,1),giovanelifiltros(:,2),giovanelifiltros(:,3),giovanelifiltros(:,4));

tabelacompleta.Properties.VariableNames={'Caso','GumesLorenco','GumesSemFiltro','Gumes206554','Gumes203964','Gumes200330','Gumes206074','GiovaneliLorenco','GiovaneliSemFiltro','Giovaneli206554','Giovaneli203964','Giovaneli200330','Giovaneli206074'};

arquivocompleto=fullfile(pastasaida,'ComparacaoCompleta85.csv');

writetable(tabelacompleta,arquivocompleto);

%% Criar resumo

nomeseries=["Lorenço";
            "Sem filtro";
            "206554";
            "203964";
            "200330";
            "206074"];

totalgumes=zeros(6,1);

coincidencias=zeros(6,1);

mae=zeros(6,1);

casosalterados=zeros(6,1);

totalgumes(1)=sum(gumeslorenco);

totalgumes(2)=sum(gumessemfiltro);

coincidencias(1)=ncasos;

coincidencias(2)=sum(gumessemfiltro==gumeslorenco);

mae(1)=0;

mae(2)=mean(abs(giovanelisemfiltro-giovanelilorenco));

casosalterados(1)=0;

casosalterados(2)=0;

for filtro=1:nfiltros

    linha=filtro+2;

    totalgumes(linha)=sum(gumesfiltros(:,filtro));

    coincidencias(linha)=sum(gumesfiltros(:,filtro)==gumeslorenco);

    mae(linha)=mean(abs(giovanelifiltros(:,filtro)-giovanelilorenco));

    casosalterados(linha)=sum(gumesfiltros(:,filtro)~=gumessemfiltro | abs(giovanelifiltros(:,filtro)-giovanelisemfiltro)>10^-10);

end

tabelaresumo=table(nomeseries,totalgumes,coincidencias,mae,casosalterados);

tabelaresumo.Properties.VariableNames={'Serie','TotalGumes','GumesIguaisLorenco','MAEGiovaneli','CasosAlteradosSemFiltro'};

fprintf('\n')
fprintf('============================================================\n')
fprintf('RESUMO FINAL\n')
fprintf('============================================================\n')
fprintf('\n')

disp(tabelaresumo)

%% Salvar resumo

arquivoresumo=fullfile(pastasaida,'ResumoComparacaoFiltros85.csv');

writetable(tabelaresumo,arquivoresumo);

%% Conferir aplicação dos filtros

fprintf('\n')
fprintf('============================================================\n')
fprintf('CONFERÊNCIA DA APLICAÇÃO DOS FILTROS\n')
fprintf('============================================================\n')
fprintf('\n')

for filtro=1:nfiltros

    config=configuracoes(filtro);

    mudougumes=sum(gumesfiltros(:,filtro)~=gumessemfiltro);

    mudougiovaneli=sum(abs(giovanelifiltros(:,filtro)-giovanelisemfiltro)>10^-10);

    fprintf('Filtro %d\n',config)
    fprintf('Casos com número de gumes alterado: %d de %d\n',mudougumes,ncasos)
    fprintf('Casos com Giovaneli alterado: %d de %d\n',mudougiovaneli,ncasos)

    if mudougumes>0 && mudougiovaneli>0

        fprintf('Resultado: filtro aplicado e com efeito no cálculo.\n')

    elseif mudougumes>0 && mudougiovaneli==0

        fprintf('ATENÇÃO: os gumes mudaram, mas Giovaneli não mudou.\n')

    else

        fprintf('ATENÇÃO: essa configuração não alterou os resultados.\n')

    end

    fprintf('\n')

end

%% Mostrar arquivos gerados

fprintf('============================================================\n')
fprintf('ARQUIVOS GERADOS\n')
fprintf('============================================================\n')
fprintf('\n')

fprintf('%s\n',arquivogumes)
fprintf('%s\n',arquivogiovaneli)
fprintf('%s\n',arquivocompleto)
fprintf('%s\n',arquivoresumo)

%% Ordenar arquivos pelo número do caso

function arquivos=ordenaarquivos(arquivos)

numeros=zeros(length(arquivos),1);

for i=1:length(arquivos)

    partes=regexp(arquivos(i).name,'\d+','match');

    if isempty(partes)==true

        numeros(i)=Inf;

    else

        numeros(i)=str2double(partes{end});

    end

end

[~,ordem]=sort(numeros);

arquivos=arquivos(ordem);

end