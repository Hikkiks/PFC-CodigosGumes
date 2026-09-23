clear
clc
close all

%% Definir caminhos

pastateste=fileparts(mfilename('fullpath'));

pastascripts=fileparts(pastateste);

addpath(fullfile(pastascripts,'Funções'))

pastasaida=fullfile(pastateste,'ResultadosVarredura85');

if exist(pastasaida,'dir')==0
    mkdir(pastasaida)
end

arquivopreparacao=fullfile(pastasaida,'PreparacaoVarredura85.mat');

arquivolog=fullfile(pastasaida,'ErrosVarreduraFinal.txt');

if exist(arquivolog,'file')==2
    delete(arquivolog)
end

%% Conferir funções

if exist('aplicafiltrodinamico','file')~=2
    error('A função aplicafiltrodinamico não foi encontrada.')
end

%% Carregar preparação

if exist(arquivopreparacao,'file')~=2
    error('O arquivo PreparacaoVarredura85.mat não foi encontrado.')
end

load(arquivopreparacao,'relevos','indicesoriginais','geometrias','gumesoriginais','giooriginal','giovanelilorenco','gumeslorenco','freq','alturat','alturar','quantidade');

if quantidade~=85
    error(['A preparação contém ' num2str(quantidade) ' casos em vez de 85.'])
end

%% Definir valores de h

valoresh=[0.05:0.025:0.80 0.85:0.05:1.30 1.40 1.50 1.60 1.70 1.75];

%% Definir valores de v

valoresv=[0.02 0.025 0.03 0.04 0.05 0.06 0.075 0.09 0.10 0.125 0.15 0.175 0.20 0.25 0.30 0.35 0.40 0.50];

%% Definir limites angulares

valoresangulo=[0.025 0.05 0.075 0.10 0.125 0.15 0.175 0.20 0.25 0.30 0.35 0.40 0.50 0.75 1.00 1.25 1.50];

%% Definir limites de distância

valoresdistancia=[20 30 50 75 100 125 150 200 250 300 400 500 750 1000 Inf];

%% Criar configurações

[gradeh,gradev,gradeangulo,gradedistancia]=ndgrid(valoresh,valoresv,valoresangulo,valoresdistancia);

vetorh=gradeh(:);

vetorv=gradev(:);

vetorangulo=gradeangulo(:);

vetordistancia=gradedistancia(:);

nconfig=length(vetorh);

%% Conferir quantidade de configurações

fprintf('\n')
fprintf('============================================================\n')
fprintf('VARREDURA FINAL DOS FILTROS - 85 CASOS\n')
fprintf('============================================================\n')
fprintf('Valores de h: %d\n',length(valoresh))
fprintf('Valores de v: %d\n',length(valoresv))
fprintf('Valores de ângulo: %d\n',length(valoresangulo))
fprintf('Valores de distância: %d\n',length(valoresdistancia))
fprintf('Configurações totais: %d\n',nconfig)
fprintf('Casos por configuração: %d\n',quantidade)
fprintf('Avaliações configuração x caso: %d\n',nconfig*quantidade)
fprintf('============================================================\n')

if nconfig~=211140
    error(['Foram geradas ' num2str(nconfig) ' configurações em vez de 211140.'])
end

%% Calcular condição original sem filtro

errooriginal=giooriginal-giovanelilorenco;

biasoriginal=mean(errooriginal);

medianaoriginal=median(errooriginal);

desviooriginal=std(errooriginal,1);

maeoriginal=mean(abs(errooriginal));

rmseoriginal=sqrt(mean(errooriginal.^2));

errocentraloriginal=errooriginal-biasoriginal;

maecentraloriginal=mean(abs(errocentraloriginal));

rmsecentraloriginal=sqrt(mean(errocentraloriginal.^2));

madoriginal=median(abs(errooriginal-median(errooriginal)));

erromaxoriginal=max(abs(errooriginal));

matrizcorrelacao=corrcoef(giooriginal,giovanelilorenco);

correlacaooriginal=matrizcorrelacao(1,2);

r2original=correlacaooriginal^2;

ajusteoriginal=polyfit(giovanelilorenco,giooriginal,1);

inclinacaooriginal=ajusteoriginal(1);

interceptooriginal=ajusteoriginal(2);

%% Criar cache de Giovaneli

cachegio=cell(quantidade,1);

for caso=1:quantidade

    cachegio{caso}=containers.Map('KeyType','char','ValueType','double');

    chave=chaveindices(indicesoriginais{caso});

    cachegio{caso}(chave)=giooriginal(caso);

end

%% Preparar matrizes dos resultados

gumesmat=zeros(nconfig,quantidade,'uint16');

giomat=nan(nconfig,quantidade);

%% Preparar métricas de Giovaneli

mediaerro=nan(nconfig,1);

medianaerro=nan(nconfig,1);

desvioerro=nan(nconfig,1);

mae=nan(nconfig,1);

rmse=nan(nconfig,1);

maecentralizado=nan(nconfig,1);

rmsecentralizado=nan(nconfig,1);

maderro=nan(nconfig,1);

erromaximo=nan(nconfig,1);

correlacao=nan(nconfig,1);

r2=nan(nconfig,1);

inclinacao=nan(nconfig,1);

intercepto=nan(nconfig,1);

pontuacao=nan(nconfig,1);

%% Preparar métricas dos gumes

acertosgumes=zeros(nconfig,1);

errogumestotal=zeros(nconfig,1);

mediadifgumes=zeros(nconfig,1);

totalgumes=zeros(nconfig,1);

gumesremovidos=zeros(nconfig,1);

casosalterados=zeros(nconfig,1);

%% Preparar métricas adicionais

casosmelhoraram=zeros(nconfig,1);

casospioraram=zeros(nconfig,1);

casosiguais=zeros(nconfig,1);

maiorganho=zeros(nconfig,1);

maiorpiora=zeros(nconfig,1);

casoserro10=zeros(nconfig,1);

casoserro15=zeros(nconfig,1);

%% Preparar contadores do cache

calculosgiovaneli=0;

resultadoscache=0;

%% Iniciar varredura

fprintf('\n')
fprintf('============================================================\n')
fprintf('INÍCIO DA VARREDURA FINAL\n')
fprintf('============================================================\n\n')

tic

for config=1:nconfig

    limiteh=vetorh(config);

    limitev=vetorv(config);

    limiteangulo=vetorangulo(config);

    limitedistancia=vetordistancia(config);

    gumesconfig=zeros(quantidade,1);

    gioconfig=nan(quantidade,1);

    %% Aplicar configuração nos 85 casos

    for caso=1:quantidade

        try

            indexoriginal=indicesoriginais{caso};

            geometria=geometrias{caso};

            %% Aplicar filtro

            indexfiltrado=aplicafiltrodinamico(indexoriginal,geometria,limiteh,limitev,limiteangulo,limitedistancia);

            gumesfiltrado=length(indexfiltrado);

            gumesconfig(caso)=gumesfiltrado;

            %% Verificar cache de Giovaneli

            chave=chaveindices(indexfiltrado);

            if isKey(cachegio{caso},chave)==true

                gioconfig(caso)=cachegio{caso}(chave);

                resultadoscache=resultadoscache+1;

            else

                perda=perdagiovaneli(indexfiltrado,relevos{caso},freq,gumesfiltrado,alturar,alturat);

                gioconfig(caso)=-perda;

                cachegio{caso}(chave)=gioconfig(caso);

                calculosgiovaneli=calculosgiovaneli+1;

            end

        catch erroexecucao

            arquivoerro=fopen(arquivolog,'a');

            fprintf(arquivoerro,'Configuração %d | Caso %d | %s\n',config,caso,erroexecucao.message);

            fclose(arquivoerro);

            gioconfig(caso)=NaN;

        end

    end

    %% Guardar resultados individuais

    gumesmat(config,:)=uint16(gumesconfig');

    giomat(config,:)=gioconfig';

    %% Calcular métricas

    if any(isnan(gioconfig))==false

        erro=gioconfig-giovanelilorenco;

        bias=mean(erro);

        errocentralizado=erro-bias;

        mediaerro(config)=bias;

        medianaerro(config)=median(erro);

        desvioerro(config)=std(erro,1);

        mae(config)=mean(abs(erro));

        rmse(config)=sqrt(mean(erro.^2));

        maecentralizado(config)=mean(abs(errocentralizado));

        rmsecentralizado(config)=sqrt(mean(errocentralizado.^2));

        maderro(config)=median(abs(erro-median(erro)));

        erromaximo(config)=max(abs(erro));

        matrizcorrelacao=corrcoef(gioconfig,giovanelilorenco);

        correlacao(config)=matrizcorrelacao(1,2);

        r2(config)=correlacao(config)^2;

        ajuste=polyfit(giovanelilorenco,gioconfig,1);

        inclinacao(config)=ajuste(1);

        intercepto(config)=ajuste(2);

        %% Calcular critério equilibrado

        pontuacao(config)=maecentralizado(config)+0.20*abs(mediaerro(config));

        %% Comparar efeito do filtro com a condição original

        erroabsoriginal=abs(errooriginal);

        erroabsfiltrado=abs(erro);

        tolerancia=10^-10;

        casosmelhoraram(config)=sum(erroabsfiltrado<erroabsoriginal-tolerancia);

        casospioraram(config)=sum(erroabsfiltrado>erroabsoriginal+tolerancia);

        casosiguais(config)=quantidade-casosmelhoraram(config)-casospioraram(config);

        ganho=erroabsoriginal-erroabsfiltrado;

        maiorganho(config)=max(ganho);

        maiorpiora(config)=min(ganho);

        casoserro10(config)=sum(erroabsfiltrado>=10);

        casoserro15(config)=sum(erroabsfiltrado>=15);

    else

        mediaerro(config)=Inf;

        medianaerro(config)=Inf;

        desvioerro(config)=Inf;

        mae(config)=Inf;

        rmse(config)=Inf;

        maecentralizado(config)=Inf;

        rmsecentralizado(config)=Inf;

        maderro(config)=Inf;

        erromaximo(config)=Inf;

        correlacao(config)=NaN;

        r2(config)=NaN;

        inclinacao(config)=NaN;

        intercepto(config)=NaN;

        pontuacao(config)=Inf;

    end

    %% Calcular métricas dos gumes

    diferencagumes=gumesconfig-gumeslorenco;

    acertosgumes(config)=sum(diferencagumes==0);

    errogumestotal(config)=sum(abs(diferencagumes));

    mediadifgumes(config)=mean(diferencagumes);

    totalgumes(config)=sum(gumesconfig);

    gumesremovidos(config)=sum(gumesoriginais-gumesconfig);

    casosalterados(config)=sum(gumesoriginais~=gumesconfig);

    %% Mostrar progresso

    if mod(config,100)==0 || config==1 || config==nconfig

        tempo=toc;

        percentual=config/nconfig;

        tempototal=tempo/percentual;

        restante=tempototal-tempo;

        fprintf('Configuração %6d de %6d | %6.2f %% | Restante estimado: %6.1f min\n',config,nconfig,percentual*100,restante/60)

    end

    %% Salvar checkpoint

    if mod(config,1000)==0

        caminhocheckpoint=fullfile(pastasaida,'CheckpointVarreduraFinal.mat');

        save(caminhocheckpoint,'config','gumesmat','giomat','mediaerro','medianaerro','desvioerro','mae','rmse','maecentralizado','rmsecentralizado','maderro','erromaximo','correlacao','r2','inclinacao','intercepto','pontuacao','acertosgumes','errogumestotal','mediadifgumes','totalgumes','gumesremovidos','casosalterados','casosmelhoraram','casospioraram','casosiguais','maiorganho','maiorpiora','casoserro10','casoserro15','vetorh','vetorv','vetorangulo','vetordistancia','calculosgiovaneli','resultadoscache','-v7.3');

    end

end

tempoexecucao=toc;

%% Criar tabela de resumo

configuracao=(1:nconfig)';

resumo=table(configuracao,vetorh,vetorv,vetorangulo,vetordistancia,mediaerro,medianaerro,desvioerro,mae,rmse,maecentralizado,rmsecentralizado,maderro,erromaximo,correlacao,r2,inclinacao,intercepto,pontuacao,acertosgumes,errogumestotal,mediadifgumes,totalgumes,gumesremovidos,casosalterados,casosmelhoraram,casospioraram,casosiguais,maiorganho,maiorpiora,casoserro10,casoserro15);

resumo.Properties.VariableNames={'Config','Limiteh','Limitev','LimiteAnguloGraus','LimiteDistancia','MediaErroGiovaneli','MedianaErroGiovaneli','DesvioErroGiovaneli','MAEGiovaneli','RMSEGiovaneli','MAECentralizado','RMSECentralizado','MADErro','ErroMaximoGiovaneli','Correlacao','R2','InclinacaoRegressao','InterceptoRegressao','PontuacaoEquilibrada','AcertosGumes','ErroTotalGumes','MediaDiferencaGumes','TotalGumes','GumesRemovidos','CasosAlterados','CasosMelhoraram','CasosPioraram','CasosIguais','MaiorGanhoCaso','MaiorPioraCaso','CasosErro10dB','CasosErro15dB'};

%% Criar rankings

rankingconsistencia=sortrows(resumo,{'MAECentralizado','DesvioErroGiovaneli','MADErro','MAEGiovaneli'},{'ascend','ascend','ascend','ascend'});

rankingequilibrado=sortrows(resumo,{'PontuacaoEquilibrada','MAECentralizado','MAEGiovaneli'},{'ascend','ascend','ascend'});

rankingmae=sortrows(resumo,{'MAEGiovaneli','MAECentralizado','DesvioErroGiovaneli'},{'ascend','ascend','ascend'});

%% Criar tabela da condição original

resumooriginal=table(biasoriginal,medianaoriginal,desviooriginal,maeoriginal,rmseoriginal,maecentraloriginal,rmsecentraloriginal,madoriginal,erromaxoriginal,correlacaooriginal,r2original,inclinacaooriginal,interceptooriginal);

resumooriginal.Properties.VariableNames={'MediaErroGiovaneli','MedianaErroGiovaneli','DesvioErroGiovaneli','MAEGiovaneli','RMSEGiovaneli','MAECentralizado','RMSECentralizado','MADErro','ErroMaximoGiovaneli','Correlacao','R2','InclinacaoRegressao','InterceptoRegressao'};

%% Salvar resultados

fprintf('\n')
fprintf('============================================================\n')
fprintf('SALVANDO RESULTADOS\n')
fprintf('============================================================\n')

writetable(resumo,fullfile(pastasaida,'ResumoTodasConfiguracoes.csv'));

writetable(rankingconsistencia,fullfile(pastasaida,'RankingConsistenciaFinal.csv'));

writetable(rankingequilibrado,fullfile(pastasaida,'RankingEquilibradoFinal.csv'));

writetable(rankingmae,fullfile(pastasaida,'RankingMAEFinal.csv'));

writetable(resumooriginal,fullfile(pastasaida,'ResumoOriginalVarreduraFinal.csv'));

save(fullfile(pastasaida,'VarreduraFinalFiltros85.mat'),'resumo','rankingconsistencia','rankingequilibrado','rankingmae','resumooriginal','gumesmat','giomat','valoresh','valoresv','valoresangulo','valoresdistancia','calculosgiovaneli','resultadoscache','tempoexecucao','-v7.3');

%% Apagar checkpoint após conclusão

caminhocheckpoint=fullfile(pastasaida,'CheckpointVarreduraFinal.mat');

if exist(caminhocheckpoint,'file')==2
    delete(caminhocheckpoint)
end

%% Mostrar condição original

fprintf('\n')
fprintf('============================================================\n')
fprintf('CONDIÇÃO ORIGINAL SEM FILTRO\n')
fprintf('============================================================\n')
fprintf('Média do erro: %+7.3f dB\n',biasoriginal)
fprintf('Desvio do erro: %7.3f dB\n',desviooriginal)
fprintf('MAE: %7.3f dB\n',maeoriginal)
fprintf('RMSE: %7.3f dB\n',rmseoriginal)
fprintf('MAE centralizado: %7.3f dB\n',maecentraloriginal)
fprintf('RMSE centralizado: %7.3f dB\n',rmsecentraloriginal)
fprintf('MAD do erro: %7.3f dB\n',madoriginal)
fprintf('Erro máximo: %7.3f dB\n',erromaxoriginal)
fprintf('Correlação: %7.4f\n',correlacaooriginal)
fprintf('R2: %7.4f\n',r2original)
fprintf('Inclinação da regressão: %7.4f\n',inclinacaooriginal)
fprintf('Intercepto da regressão: %+7.3f dB\n',interceptooriginal)

%% Mostrar melhores resultados

fprintf('\n')
fprintf('============================================================\n')
fprintf('20 MELHORES POR CONSISTÊNCIA\n')
fprintf('============================================================\n')

disp(rankingconsistencia(1:20,:))

fprintf('\n')
fprintf('============================================================\n')
fprintf('20 MELHORES PELO CRITÉRIO EQUILIBRADO\n')
fprintf('============================================================\n')

disp(rankingequilibrado(1:20,:))

fprintf('\n')
fprintf('============================================================\n')
fprintf('20 MELHORES POR MAE\n')
fprintf('============================================================\n')

disp(rankingmae(1:20,:))

%% Mostrar primeiro de cada ranking

fprintf('\n')
fprintf('============================================================\n')
fprintf('MELHORES RESULTADOS DA VARREDURA\n')
fprintf('============================================================\n')

fprintf('\n')
fprintf('Melhor por consistência:\n')

disp(rankingconsistencia(1,:))

fprintf('\n')
fprintf('Melhor pelo critério equilibrado:\n')

disp(rankingequilibrado(1,:))

fprintf('\n')
fprintf('Melhor por MAE:\n')

disp(rankingmae(1,:))

%% Mostrar estatísticas de execução

fprintf('\n')
fprintf('============================================================\n')
fprintf('EXECUÇÃO\n')
fprintf('============================================================\n')
fprintf('Tempo total: %.1f minutos\n',tempoexecucao/60)
fprintf('Novos cálculos de Giovaneli: %d\n',calculosgiovaneli)
fprintf('Resultados recuperados do cache: %d\n',resultadoscache)
fprintf('Arquivos salvos em:\n')
fprintf('%s\n',pastasaida)
fprintf('============================================================\n')

%% Criar chave para cache de Giovaneli

function chave=chaveindices(indexgumes)

if isempty(indexgumes)==true

    chave='semgumes';

else

    chave=sprintf('%d-',indexgumes);

end

end