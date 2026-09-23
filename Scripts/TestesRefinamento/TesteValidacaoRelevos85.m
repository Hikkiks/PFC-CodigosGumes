clear
clc
close all

%% Definir caminhos

pastateste=fileparts(mfilename('fullpath'));

pastascripts=fileparts(pastateste);

addpath(fullfile(pastascripts,'Funções'))

pastarelevos=fullfile(pastascripts,'DadosSalvos','RelevosLorenco85');

arquivotxt=fullfile(pastascripts,'dadoslorencocompleto.txt');

pastasaida=fullfile(pastateste,'ResultadosValidacaoRelevos85');

if exist(pastasaida,'dir')==0
    mkdir(pastasaida)
end

%% Definir dados do transmissor

lattx=-18.8825;

lontx=-48.25083;

%% Definir configurações

amostrasesperadas=512;

toleranciacoordenada=5;

toleranciadistancia=0.5;

toleranciaespacamento=10;

%% Conferir caminhos

if exist(pastarelevos,'dir')~=7
    error('A pasta RelevosLorenco85 não foi encontrada.')
end

if exist(arquivotxt,'file')~=2
    error('O arquivo dadoslorencocompleto.txt não foi encontrado.')
end

%% Ler dados de referência do Lorenço

arquivo=fopen(arquivotxt,'r');

if arquivo==-1
    error('Não foi possível abrir dadoslorencocompleto.txt.')
end

dados=textscan(arquivo,'%s %s %s %s %s %f');

fclose(arquivo);

latitudes=str2double(strrep(dados{1},',','.'));

longitudes=str2double(strrep(dados{2},',','.'));

quantidade=length(latitudes);

%% Conferir quantidade de casos

if quantidade~=85
    error(['Foram encontrados ' num2str(quantidade) ' casos em vez de 85.'])
end

%% Mostrar informações iniciais

fprintf('\n')
fprintf('============================================================\n')
fprintf('VALIDAÇÃO DOS PERFIS DE ELEVAÇÃO - 85 CASOS\n')
fprintf('============================================================\n')
fprintf('Perfis esperados: %d\n',quantidade)
fprintf('Amostras esperadas por perfil: %d\n',amostrasesperadas)
fprintf('Tx esperada: %.5f, %.5f\n',lattx,lontx)
fprintf('============================================================\n')

%% Preparar resultados

arquivoexiste=false(quantidade,1);

temdadoselev=false(quantidade,1);

formatocorreto=false(quantidade,1);

dadosfinitos=false(quantidade,1);

iniciotxok=false(quantidade,1);

fimrxok=false(quantidade,1);

distanciaok=false(quantidade,1);

espacamentook=false(quantidade,1);

duplicado=false(quantidade,1);

duplicadocom=zeros(quantidade,1);

amostras=zeros(quantidade,1);

errotx=zeros(quantidade,1);

errorx=zeros(quantidade,1);

distanciadireta=zeros(quantidade,1);

distanciaacumulada=zeros(quantidade,1);

diferencadistancia=zeros(quantidade,1);

espacamentomedio=zeros(quantidade,1);

espacamentominimo=zeros(quantidade,1);

espacamentomaximo=zeros(quantidade,1);

variacaoespacamento=zeros(quantidade,1);

elevacaominima=zeros(quantidade,1);

elevacaomaxima=zeros(quantidade,1);

observacao=strings(quantidade,1);

perfis=cell(quantidade,1);

wgs84=wgs84Ellipsoid("m");

%% Validar cada perfil

for caso=1:quantidade

    nomearquivo=['DadosElevLorenco' num2str(caso) '.mat'];

    caminhoarquivo=fullfile(pastarelevos,nomearquivo);

    %% Verificar existência

    if exist(caminhoarquivo,'file')~=2

        observacao(caso)="Arquivo não encontrado";

        continue

    end

    arquivoexiste(caso)=true;

    %% Carregar arquivo

    dadosarquivo=load(caminhoarquivo);

    if isfield(dadosarquivo,'dadoselev')==false

        observacao(caso)="Variável dadoselev não encontrada";

        continue

    end

    temdadoselev(caso)=true;

    dadoselev=dadosarquivo.dadoselev;

    perfis{caso}=dadoselev;

    %% Verificar formato

    amostras(caso)=size(dadoselev,2);

    if size(dadoselev,1)==3 && size(dadoselev,2)==amostrasesperadas

        formatocorreto(caso)=true;

    else

        observacao(caso)=observacao(caso)+" Formato diferente de 3x512;";

    end

    %% Verificar NaN e Inf

    if all(isfinite(dadoselev),'all')==true

        dadosfinitos(caso)=true;

    else

        observacao(caso)=observacao(caso)+" Existem NaN ou Inf;";

        continue

    end

    %% Comparar coordenada inicial com Tx

    errotx(caso)=distance(lattx,lontx,dadoselev(1,1),dadoselev(2,1),wgs84);

    if errotx(caso)<=toleranciacoordenada

        iniciotxok(caso)=true;

    else

        observacao(caso)=observacao(caso)+" Coordenada Tx diferente;";

    end

    %% Comparar coordenada final com Rx da tabela

    errorx(caso)=distance(latitudes(caso),longitudes(caso),dadoselev(1,end),dadoselev(2,end),wgs84);

    if errorx(caso)<=toleranciacoordenada

        fimrxok(caso)=true;

    else

        observacao(caso)=observacao(caso)+" Coordenada Rx diferente;";

    end

    %% Calcular distância acumulada

    n=size(dadoselev,2);

    distancia=zeros(1,n);

    for i=2:n

        distancia(i)=distancia(i-1)+distance(dadoselev(1,i-1),dadoselev(2,i-1),dadoselev(1,i),dadoselev(2,i),wgs84);

    end

    distanciaacumulada(caso)=distancia(end);

    %% Calcular distância direta Tx-Rx

    distanciadireta(caso)=distance(dadoselev(1,1),dadoselev(2,1),dadoselev(1,end),dadoselev(2,end),wgs84);

    if distanciadireta(caso)>0

        diferencadistancia(caso)=abs(distanciaacumulada(caso)-distanciadireta(caso))/distanciadireta(caso)*100;

    else

        diferencadistancia(caso)=Inf;

    end

    if diferencadistancia(caso)<=toleranciadistancia

        distanciaok(caso)=true;

    else

        observacao(caso)=observacao(caso)+" Distância acumulada inconsistente;";

    end

    %% Verificar espaçamento entre amostras

    segmentos=diff(distancia);

    espacamentomedio(caso)=mean(segmentos);

    espacamentominimo(caso)=min(segmentos);

    espacamentomaximo(caso)=max(segmentos);

    if espacamentomedio(caso)>0

        variacaoespacamento(caso)=(espacamentomaximo(caso)-espacamentominimo(caso))/espacamentomedio(caso)*100;

    else

        variacaoespacamento(caso)=Inf;

    end

    if all(segmentos>0)==true && variacaoespacamento(caso)<=toleranciaespacamento

        espacamentook(caso)=true;

    else

        observacao(caso)=observacao(caso)+" Espaçamento irregular ou coordenadas repetidas;";

    end

    %% Obter limites de elevação

    elevacaominima(caso)=min(dadoselev(3,:));

    elevacaomaxima(caso)=max(dadoselev(3,:));

end

%% Verificar perfis exatamente duplicados

for i=1:quantidade-1

    if isempty(perfis{i})==true
        continue
    end

    for j=i+1:quantidade

        if isempty(perfis{j})==true
            continue
        end

        if isequal(perfis{i},perfis{j})==true

            duplicado(j)=true;

            duplicadocom(j)=i;

            observacao(j)=observacao(j)+" Perfil idêntico ao caso "+string(i)+";";

        end

    end

end

%% Determinar resultado final de cada perfil

valido=arquivoexiste & temdadoselev & formatocorreto & dadosfinitos & iniciotxok & fimrxok & distanciaok & espacamentook & ~duplicado;

%% Criar tabela completa

caso=(1:quantidade)';

resultado=table(caso,arquivoexiste,temdadoselev,amostras,formatocorreto,dadosfinitos,errotx,errorx,iniciotxok,fimrxok,distanciadireta,distanciaacumulada,diferencadistancia,espacamentomedio,espacamentominimo,espacamentomaximo,variacaoespacamento,espacamentook,elevacaominima,elevacaomaxima,duplicado,duplicadocom,valido,observacao);

resultado.Properties.VariableNames={'Caso','ArquivoExiste','TemDadoselev','Amostras','FormatoCorreto','DadosFinitos','ErroTx_m','ErroRx_m','TxOK','RxOK','DistanciaDireta_m','DistanciaAcumulada_m','DiferencaDistancia_percentual','EspacamentoMedio_m','EspacamentoMinimo_m','EspacamentoMaximo_m','VariacaoEspacamento_percentual','EspacamentoOK','ElevacaoMinima_m','ElevacaoMaxima_m','Duplicado','DuplicadoCom','Valido','Observacao'};

%% Calcular resumo

arquivosausentes=sum(arquivoexiste==false);

variavelausente=sum(arquivoexiste & ~temdadoselev);

formatoserrados=sum(temdadoselev & ~formatocorreto);

dadosinvalidos=sum(temdadoselev & ~dadosfinitos);

errostx=sum(dadosfinitos & ~iniciotxok);

errosrx=sum(dadosfinitos & ~fimrxok);

errosdistancia=sum(dadosfinitos & ~distanciaok);

errosespacamento=sum(dadosfinitos & ~espacamentook);

duplicados=sum(duplicado);

validos=sum(valido);

resumo=table(quantidade,validos,arquivosausentes,variavelausente,formatoserrados,dadosinvalidos,errostx,errosrx,errosdistancia,errosespacamento,duplicados);

resumo.Properties.VariableNames={'TotalPerfis','PerfisValidos','ArquivosAusentes','DadoselevAusente','FormatoIncorreto','DadosInvalidos','ErroTx','ErroRx','ErroDistancia','ErroEspacamento','PerfisDuplicados'};

%% Mostrar resumo

fprintf('\n')
fprintf('============================================================\n')
fprintf('RESULTADO DA VALIDAÇÃO\n')
fprintf('============================================================\n')
fprintf('Perfis esperados:                  %d\n',quantidade)
fprintf('Perfis completamente válidos:     %d\n',validos)
fprintf('Arquivos ausentes:                 %d\n',arquivosausentes)
fprintf('Arquivos sem dadoselev:            %d\n',variavelausente)
fprintf('Formato incorreto:                 %d\n',formatoserrados)
fprintf('Perfis com NaN ou Inf:             %d\n',dadosinvalidos)
fprintf('Problemas na coordenada Tx:        %d\n',errostx)
fprintf('Problemas na coordenada Rx:        %d\n',errosrx)
fprintf('Problemas na distância:            %d\n',errosdistancia)
fprintf('Problemas no espaçamento:          %d\n',errosespacamento)
fprintf('Perfis exatamente duplicados:      %d\n',duplicados)
fprintf('============================================================\n')

%% Mostrar casos problemáticos

problemas=resultado(resultado.Valido==false,:);

if isempty(problemas)==false

    fprintf('\n')
    fprintf('PERFIS QUE PRECISAM SER CONFERIDOS\n')
    fprintf('============================================================\n')

    disp(problemas)

else

    fprintf('\n')
    fprintf('Todos os %d perfis passaram nas verificações.\n',quantidade)

end

%% Salvar resultados

arquivocompleto=fullfile(pastasaida,'ValidacaoRelevos85.csv');

arquivoresumo=fullfile(pastasaida,'ResumoValidacaoRelevos85.csv');

writetable(resultado,arquivocompleto);

writetable(resumo,arquivoresumo);

save(fullfile(pastasaida,'ValidacaoRelevos85.mat'),'resultado','resumo');

%% Mostrar finalização

fprintf('\n')
fprintf('Resultados salvos em:\n')
fprintf('%s\n',pastasaida)