clear
clc
close all

%% Definir caminhos

pastateste=fileparts(mfilename('fullpath'));

pastascripts=fileparts(pastateste);

pastavarredura=fullfile(pastascripts,'TestesFinais','ResultadosVarredura85');

arquivovarredura=fullfile(pastavarredura,'VarreduraFinalFiltros85.mat');

arquivopreparacao=fullfile(pastavarredura,'PreparacaoVarredura85.mat');

%% Definir configurações analisadas

configs=[206554 203964 200330 206074];

%% Conferir arquivos

if exist(arquivovarredura,'file')~=2
    error('O arquivo VarreduraFinalFiltros85.mat não foi encontrado.')
end

if exist(arquivopreparacao,'file')~=2
    error('O arquivo PreparacaoVarredura85.mat não foi encontrado.')
end

%% Carregar resultados da varredura

load(arquivovarredura,'gumesmat','giomat','resumo')

%% Carregar condição original e referência

load(arquivopreparacao,'gumesoriginais','giooriginal','giovanelilorenco','quantidade')

if quantidade~=85
    error(['A preparação contém ' num2str(quantidade) ' casos em vez de 85.'])
end

ncasos=quantidade;

if size(gumesmat,2)~=ncasos
    error('A matriz gumesmat não possui 85 casos.')
end

if size(giomat,2)~=ncasos
    error('A matriz giomat não possui 85 casos.')
end

if max(configs)>size(giomat,1)
    error('Uma das configurações selecionadas não existe na varredura.')
end

%% Preparar resumo da verificação

resumoverificacao=table;

%% Verificar configurações

fprintf('\n')
fprintf('============================================================\n')
fprintf('VERIFICAÇÃO DAS CONFIGURAÇÕES\n')
fprintf('============================================================\n')
fprintf('\n')

for i=1:length(configs)

    config=configs(i);

    %% Localizar configuração no resumo da varredura

    linha=resumo(resumo.Config==config,:);

    if height(linha)~=1
        error(['A configuração ' num2str(config) ' não foi encontrada de forma única no resumo.'])
    end

    %% Obter resultados dos 85 casos

    gumesfiltrados=double(gumesmat(config,:))';

    giovanelifiltrado=giomat(config,:)';

    if any(isnan(giovanelifiltrado))==true
        error(['A configuração ' num2str(config) ' possui resultados NaN.'])
    end

    %% Comparar com condição original

    difgumes=gumesfiltrados-gumesoriginais;

    difgiovaneli=giovanelifiltrado-giooriginal;

    alterougumes=abs(difgumes)>0;

    alterougiovaneli=abs(difgiovaneli)>10^-10;

    casosgumes=sum(alterougumes);

    casosgiovaneli=sum(alterougiovaneli);

    gumesremovidos=sum(gumesoriginais-gumesfiltrados);

    maxdifgiovaneli=max(abs(difgiovaneli));

    mediadifgiovaneli=mean(abs(difgiovaneli));

    %% Recalcular erros em relação a Lorenço

    errofiltrado=giovanelifiltrado-giovanelilorenco;

    mediaerro=mean(errofiltrado);

    mae=mean(abs(errofiltrado));

    rmse=sqrt(mean(errofiltrado.^2));

    %% Conferir métricas com o resumo da varredura

    diferencamedia=abs(mediaerro-linha.MediaErroGiovaneli);

    diferencamae=abs(mae-linha.MAEGiovaneli);

    diferencarmse=abs(rmse-linha.RMSEGiovaneli);

    diferencacasos=abs(casosgumes-linha.CasosAlterados);

    diferencagumes=abs(gumesremovidos-linha.GumesRemovidos);

    diferencametrica=max([diferencamedia diferencamae diferencarmse]);

    %% Mostrar resultado

    fprintf('Configuração %d\n',config)
    fprintf('Casos analisados: %d\n',ncasos)
    fprintf('Casos com alteração na quantidade de gumes: %d de %d\n',casosgumes,ncasos)
    fprintf('Total de gumes removidos: %d\n',gumesremovidos)
    fprintf('Casos com alteração no Giovaneli: %d de %d\n',casosgiovaneli,ncasos)
    fprintf('Maior alteração no Giovaneli: %.6f dB\n',maxdifgiovaneli)
    fprintf('Alteração absoluta média no Giovaneli: %.6f dB\n',mediadifgiovaneli)
    fprintf('Diferença máxima nas métricas conferidas: %.12f dB\n',diferencametrica)
    fprintf('Diferença na conferência de casos alterados: %d\n',diferencacasos)
    fprintf('Diferença na conferência de gumes removidos: %d\n',diferencagumes)

    if casosgumes>0 && casosgiovaneli>0 && diferencametrica<10^-10 && diferencacasos==0 && diferencagumes==0

        fprintf('RESULTADO: o filtro foi aplicado e os resultados conferem com a varredura.\n')

    elseif casosgumes>0 && casosgiovaneli==0

        fprintf('ATENÇÃO: os gumes mudaram, mas o resultado de Giovaneli não mudou.\n')

    elseif casosgumes==0

        fprintf('ATENÇÃO: nenhum gume foi alterado nessa configuração.\n')

    else

        fprintf('ATENÇÃO: foram encontradas diferenças na conferência da varredura.\n')

    end

    fprintf('\n')

    %% Adicionar ao resumo

    linharesumo=table(config,ncasos,casosgumes,gumesremovidos,casosgiovaneli,maxdifgiovaneli,mediadifgiovaneli,diferencametrica,diferencacasos,diferencagumes);

    resumoverificacao=[resumoverificacao;linharesumo];

end

%% Definir nomes das colunas

resumoverificacao.Properties.VariableNames={'Config','Casos','CasosGumesAlterados','GumesRemovidos','CasosGiovaneliAlterados','MaiorDifGiovaneli','MediaDifGiovaneli','MaiorDiferencaMetricas','DiferencaCasosAlterados','DiferencaGumesRemovidos'};

%% Mostrar resumo

fprintf('============================================================\n')
fprintf('RESUMO\n')
fprintf('============================================================\n')
fprintf('\n')

disp(resumoverificacao)

%% Mostrar casos alterados em cada configuração

fprintf('============================================================\n')
fprintf('CASOS ALTERADOS EM CADA CONFIGURAÇÃO\n')
fprintf('============================================================\n')
fprintf('\n')

for i=1:length(configs)

    config=configs(i);

    gumesfiltrados=double(gumesmat(config,:))';

    giovanelifiltrado=giomat(config,:)';

    errooriginal=giooriginal-giovanelilorenco;

    errofiltrado=giovanelifiltrado-giovanelilorenco;

    mascara=gumesoriginais~=gumesfiltrados | abs(giooriginal-giovanelifiltrado)>10^-10;

    caso=(1:ncasos)';

    alterados=table(caso,gumesoriginais,gumesfiltrados,giooriginal,giovanelifiltrado,giovanelilorenco,errooriginal,errofiltrado);

    alterados.Properties.VariableNames={'Caso','GumesOriginal','GumesFiltrado','GiovaneliOriginal','GiovaneliFiltrado','GiovaneliLorenco','ErroGiovaneliOriginal','ErroGiovaneliFiltrado'};

    alterados=alterados(mascara,:);

    fprintf('Configuração %d\n',config)
    fprintf('\n')

    if isempty(alterados)==true

        fprintf('Nenhum caso alterado.\n')

    else

        disp(alterados)

    end

    fprintf('\n')

end