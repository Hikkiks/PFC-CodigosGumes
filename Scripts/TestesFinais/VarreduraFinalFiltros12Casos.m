clear
clc
close all

%% Definir caminhos

pastateste=fileparts(mfilename('fullpath'));

pastascripts=fileparts(pastateste);

addpath(fullfile(pastascripts,'Funções'))

pastasaida=fullfile(pastateste,'ResultadosVarredura12Casos');

arquivopreparacao=fullfile(pastasaida,'PreparacaoVarredura12Casos.mat');

if exist(arquivopreparacao,'file')~=2
    error('O arquivo PreparacaoVarredura12Casos.mat não foi encontrado.')
end

if exist('aplicafiltrodinamico','file')~=2
    error('A função aplicafiltrodinamico não foi encontrada.')
end

%% Carregar preparação

load(arquivopreparacao,'relevos','indicessemfresnel','indicescomfresnel','geometriasemfresnel','geometriacomfresnel','gumessemfresnel','gumescomfresnel','campolivre','camposemfresnel','campocomfresnel','casos','freqvetor','alturatvetor','alturar','campogiolorencovetor','medidovetor','gumeslorencovetor')

quantidade=length(casos);

if quantidade~=12
    error('A preparação carregada não possui exatamente 12 casos.')
end

%% Definir grade final dos filtros

valoresh=[0.05:0.025:0.80 0.85:0.05:1.30 1.40 1.50 1.60 1.70 1.75];

valoresv=[0.02 0.025 0.03 0.04 0.05 0.06 0.075 0.09 0.10 0.125 0.15 0.175 0.20 0.25 0.30 0.35 0.40 0.50];

valoresangulo=[0.025 0.05 0.075 0.10 0.125 0.15 0.175 0.20 0.25 0.30 0.35 0.40 0.50 0.75 1.00 1.25 1.50];

valoresdistancia=[20 30 50 75 100 125 150 200 250 300 400 500 750 1000 Inf];

nconfig=length(valoresh)*length(valoresv)*length(valoresangulo)*length(valoresdistancia);

%% Mostrar início

fprintf('\n')
fprintf('====================================================================\n')
fprintf('VARREDURA FINAL DOS FILTROS - 12 CASOS REAIS\n')
fprintf('====================================================================\n')
fprintf('Valores de h:          %d\n',length(valoresh))
fprintf('Valores de v:          %d\n',length(valoresv))
fprintf('Valores de ângulo:     %d\n',length(valoresangulo))
fprintf('Valores de distância:  %d\n',length(valoresdistancia))
fprintf('Configurações:         %d\n',nconfig)
fprintf('Casos por condição:    %d\n',quantidade)
fprintf('Condições:             2\n')
fprintf('Avaliações totais:     %d\n',nconfig*quantidade*2)
fprintf('====================================================================\n')

%% Executar varredura sem Fresnel

fprintf('\n')
fprintf('====================================================================\n')
fprintf('INICIANDO VARREDURA SEM FRESNEL\n')
fprintf('====================================================================\n')

[resumosem,gumesmatsem,campomatsem,estatisticassem]=executavarredura('Sem Fresnel',indicessemfresnel,geometriasemfresnel,gumessemfresnel,camposemfresnel,relevos,freqvetor,alturatvetor,alturar,campolivre,medidovetor,campogiolorencovetor,gumeslorencovetor,valoresh,valoresv,valoresangulo,valoresdistancia);

[resumosem,rankingmedidosem,rankinglorencosem,rankinggumessem,rankingcoberturasem,rankingequilibradosem]=criarrankings(resumosem);

%% Salvar resultados sem Fresnel

writetable(resumosem,fullfile(pastasaida,'ResumoVarredura12CasosSemFresnel.csv'));

writetable(rankingmedidosem,fullfile(pastasaida,'RankingMedido12CasosSemFresnel.csv'));

writetable(rankinglorencosem,fullfile(pastasaida,'RankingLorenco12CasosSemFresnel.csv'));

writetable(rankinggumessem,fullfile(pastasaida,'RankingGumes12CasosSemFresnel.csv'));

writetable(rankingcoberturasem,fullfile(pastasaida,'RankingCobertura12CasosSemFresnel.csv'));

writetable(rankingequilibradosem,fullfile(pastasaida,'RankingEquilibrado12CasosSemFresnel.csv'));

save(fullfile(pastasaida,'Varredura12CasosSemFresnel.mat'),'resumosem','gumesmatsem','campomatsem','estatisticassem','-v7.3');

%% Mostrar resultados sem Fresnel

mostravencedores('SEM FRESNEL',rankingmedidosem,rankinglorencosem,rankinggumessem,rankingcoberturasem,rankingequilibradosem);

%% Executar varredura com Fresnel

fprintf('\n')
fprintf('====================================================================\n')
fprintf('INICIANDO VARREDURA COM FRESNEL\n')
fprintf('====================================================================\n')

[resumocom,gumesmatcom,campomatcom,estatisticascom]=executavarredura('Com Fresnel',indicescomfresnel,geometriacomfresnel,gumescomfresnel,campocomfresnel,relevos,freqvetor,alturatvetor,alturar,campolivre,medidovetor,campogiolorencovetor,gumeslorencovetor,valoresh,valoresv,valoresangulo,valoresdistancia);

[resumocom,rankingmedidocom,rankinglorencocom,rankinggumescom,rankingcoberturacom,rankingequilibradocom]=criarrankings(resumocom);

%% Salvar resultados com Fresnel

writetable(resumocom,fullfile(pastasaida,'ResumoVarredura12CasosComFresnel.csv'));

writetable(rankingmedidocom,fullfile(pastasaida,'RankingMedido12CasosComFresnel.csv'));

writetable(rankinglorencocom,fullfile(pastasaida,'RankingLorenco12CasosComFresnel.csv'));

writetable(rankinggumescom,fullfile(pastasaida,'RankingGumes12CasosComFresnel.csv'));

writetable(rankingcoberturacom,fullfile(pastasaida,'RankingCobertura12CasosComFresnel.csv'));

writetable(rankingequilibradocom,fullfile(pastasaida,'RankingEquilibrado12CasosComFresnel.csv'));

save(fullfile(pastasaida,'Varredura12CasosComFresnel.mat'),'resumocom','gumesmatcom','campomatcom','estatisticascom','-v7.3');

%% Mostrar resultados com Fresnel

mostravencedores('COM FRESNEL',rankingmedidocom,rankinglorencocom,rankinggumescom,rankingcoberturacom,rankingequilibradocom);

%% Comparar as duas condições

modosem=repmat("Sem Fresnel",height(resumosem),1);

modocom=repmat("Com Fresnel",height(resumocom),1);

resumosemgeral=addvars(resumosem,modosem,'Before',1,'NewVariableNames','Modo');

resumocomgeral=addvars(resumocom,modocom,'Before',1,'NewVariableNames','Modo');

resumogeral=[resumosemgeral;resumocomgeral];

rankingmedidogeral=sortrows(resumogeral,{'MAEMedido','RMSEMedido','AbsErroMedioMedido','ErroMaximoMedido','ErroTotalGumes'},{'ascend','ascend','ascend','ascend','ascend'});

rankinglorencogeral=sortrows(resumogeral,{'MAELorenco','RMSELorenco','AbsErroMedioLorenco','ErroMaximoLorenco','ErroTotalGumes'},{'ascend','ascend','ascend','ascend','ascend'});

writetable(rankingmedidogeral,fullfile(pastasaida,'RankingMedido12CasosGeral.csv'));

writetable(rankinglorencogeral,fullfile(pastasaida,'RankingLorenco12CasosGeral.csv'));

%% Mostrar melhor resultado geral contra medição

melhor=rankingmedidogeral(1,:);

fprintf('\n')
fprintf('====================================================================================================================\n')
fprintf('MELHOR RESULTADO GLOBAL CONTRA O CAMPO REALMENTE MEDIDO\n')
fprintf('====================================================================================================================\n')
fprintf('Modo:              %s\n',char(melhor.Modo))
fprintf('Número de série:   %d\n',melhor.NumeroSerie)
fprintf('h:                 %.3f m\n',melhor.h)
fprintf('v:                 %.3f\n',melhor.v)
fprintf('Ângulo:            %.3f graus\n',melhor.Angulo)
fprintf('Distância:         %.3f m\n',melhor.Distancia)
fprintf('MAE medido:        %.6f dB\n',melhor.MAEMedido)
fprintf('RMSE medido:       %.6f dB\n',melhor.RMSEMedido)
fprintf('Erro médio:        %+.6f dB\n',melhor.ErroMedioMedido)
fprintf('MAE Lorenço:       %.6f dB\n',melhor.MAELorenco)
fprintf('Gumes totais:      %d\n',melhor.TotalGumes)
fprintf('Acertos de gumes:  %d de 12\n',melhor.AcertosGumes)
fprintf('Erro total gumes:  %d\n',melhor.ErroTotalGumes)
fprintf('====================================================================================================================\n')

%% Mostrar finalização

fprintf('\n')
fprintf('====================================================================\n')
fprintf('VARREDURA DOS 12 CASOS CONCLUÍDA\n')
fprintf('====================================================================\n')
fprintf('Sem Fresnel - novos cálculos Giovaneli: %d\n',estatisticassem.NovosCalculos)
fprintf('Sem Fresnel - reutilizações do cache:   %d\n',estatisticassem.CacheHits)
fprintf('Com Fresnel - novos cálculos Giovaneli: %d\n',estatisticascom.NovosCalculos)
fprintf('Com Fresnel - reutilizações do cache:   %d\n',estatisticascom.CacheHits)
fprintf('\n')
fprintf('Resultados salvos em:\n')
fprintf('%s\n',pastasaida)
fprintf('====================================================================\n')

%% Executar varredura

function [resumo,gumesmat,campomat,estatisticas]=executavarredura(nome,indicesoriginais,geometrias,gumesoriginais,campooriginal,relevos,freqvetor,alturatvetor,alturar,campolivre,medidovetor,campogiolorencovetor,gumeslorencovetor,valoresh,valoresv,valoresangulo,valoresdistancia)

quantidade=length(indicesoriginais);

nconfig=length(valoresh)*length(valoresv)*length(valoresangulo)*length(valoresdistancia);

%% Preparar resultados individuais

gumesmat=zeros(nconfig,quantidade,'uint16');

campomat=zeros(nconfig,quantidade);

%% Preparar parâmetros das configurações

numeroserie=(1:nconfig)';

hconfig=zeros(nconfig,1);

vconfig=zeros(nconfig,1);

anguloconfig=zeros(nconfig,1);

distanciaconfig=zeros(nconfig,1);

%% Preparar métricas contra medição

erromediomedido=zeros(nconfig,1);

desviomedido=zeros(nconfig,1);

maemedido=zeros(nconfig,1);

rmsemedido=zeros(nconfig,1);

erromaximomedido=zeros(nconfig,1);

%% Preparar métricas contra Lorenço

erromediolorenco=zeros(nconfig,1);

desviolorenco=zeros(nconfig,1);

maelorenco=zeros(nconfig,1);

rmselorenco=zeros(nconfig,1);

erromaximolorenco=zeros(nconfig,1);

%% Preparar métricas dos gumes

totalgumes=zeros(nconfig,1);

diferencatotalgumes=zeros(nconfig,1);

acertosgumes=zeros(nconfig,1);

errototalgumes=zeros(nconfig,1);

casosacimagumes=zeros(nconfig,1);

casosiguaisgumes=zeros(nconfig,1);

casosabaixogumes=zeros(nconfig,1);

casoscobertosgumes=zeros(nconfig,1);

coberturagumes=zeros(nconfig,1);

excessototalgumes=zeros(nconfig,1);

deficittotalgumes=zeros(nconfig,1);

gumesremovidos=zeros(nconfig,1);

casosalterados=zeros(nconfig,1);

%% Preparar comparação com condição original

melhorasmedido=zeros(nconfig,1);

piorasmedido=zeros(nconfig,1);

iguaismedido=zeros(nconfig,1);

errooriginalmedido=campooriginal-medidovetor;

totalgumesoriginal=sum(gumesoriginais);

totalgumeslorenco=sum(gumeslorencovetor);

%% Preparar caches

cache=cell(quantidade,1);

for caso=1:quantidade

    cache{caso}=containers.Map('KeyType','char','ValueType','double');

    chave=chaveindices(indicesoriginais{caso});

    cache{caso}(chave)=campooriginal(caso);

end

novoscalculos=0;

cachehits=0;

%% Executar combinações

numero=0;

inicio=tic;

for idistancia=1:length(valoresdistancia)

    limitedistancia=valoresdistancia(idistancia);

    for iangulo=1:length(valoresangulo)

        limiteangulo=valoresangulo(iangulo);

        for iv=1:length(valoresv)

            limitev=valoresv(iv);

            for ih=1:length(valoresh)

                limiteh=valoresh(ih);

                numero=numero+1;

                hconfig(numero)=limiteh;

                vconfig(numero)=limitev;

                anguloconfig(numero)=limiteangulo;

                distanciaconfig(numero)=limitedistancia;

                %% Processar os 12 casos

                for caso=1:quantidade

                    indexfiltrado=aplicafiltrodinamico(indicesoriginais{caso},geometrias{caso},limiteh,limitev,limiteangulo,limitedistancia);

                    gumes=length(indexfiltrado);

                    gumesmat(numero,caso)=gumes;

                    chave=chaveindices(indexfiltrado);

                    if isKey(cache{caso},chave)==true

                        campo=cache{caso}(chave);

                        cachehits=cachehits+1;

                    else

                        perda=perdagiovaneli(indexfiltrado,relevos{caso},freqvetor(caso),gumes,alturar,alturatvetor(caso));

                        perdadif=-perda;

                        campo=campolivre(caso)-perdadif;

                        cache{caso}(chave)=campo;

                        novoscalculos=novoscalculos+1;

                    end

                    campomat(numero,caso)=campo;

                end

                %% Organizar resultados da configuração

                campos=campomat(numero,:)';

                gumescalc=double(gumesmat(numero,:))';

                %% Calcular erro contra medição real

                erromedido=campos-medidovetor;

                erromediomedido(numero)=mean(erromedido);

                desviomedido(numero)=std(erromedido,1);

                maemedido(numero)=mean(abs(erromedido));

                rmsemedido(numero)=sqrt(mean(erromedido.^2));

                erromaximomedido(numero)=max(abs(erromedido));

                %% Calcular erro contra Lorenço

                errolorenco=campos-campogiolorencovetor;

                erromediolorenco(numero)=mean(errolorenco);

                desviolorenco(numero)=std(errolorenco,1);

                maelorenco(numero)=mean(abs(errolorenco));

                rmselorenco(numero)=sqrt(mean(errolorenco.^2));

                erromaximolorenco(numero)=max(abs(errolorenco));

                %% Calcular quantidade de gumes

                difgumes=gumescalc-gumeslorencovetor;

                totalgumes(numero)=sum(gumescalc);

                diferencatotalgumes(numero)=totalgumes(numero)-totalgumeslorenco;

                acertosgumes(numero)=sum(difgumes==0);

                errototalgumes(numero)=sum(abs(difgumes));

                casosacimagumes(numero)=sum(difgumes>0);

                casosiguaisgumes(numero)=sum(difgumes==0);

                casosabaixogumes(numero)=sum(difgumes<0);

                casoscobertosgumes(numero)=sum(difgumes>=0);

                coberturagumes(numero)=100*casoscobertosgumes(numero)/quantidade;

                excessototalgumes(numero)=sum(max(difgumes,0));

                deficittotalgumes(numero)=sum(max(-difgumes,0));

                gumesremovidos(numero)=totalgumesoriginal-totalgumes(numero);

                casosalterados(numero)=sum(gumescalc~=gumesoriginais);

                %% Comparar com condição original

                diferencaerro=abs(erromedido)-abs(errooriginalmedido);

                melhorasmedido(numero)=sum(diferencaerro<-1e-10);

                piorasmedido(numero)=sum(diferencaerro>1e-10);

                iguaismedido(numero)=sum(abs(diferencaerro)<=1e-10);

                %% Mostrar progresso

                if mod(numero,1000)==0 || numero==nconfig

                    tempodecorrido=toc(inicio);

                    percentual=100*numero/nconfig;

                    fprintf('%-12s | %6d / %6d | %6.2f %% | %8.1f s | novos Gio: %5d | cache: %8d\n',nome,numero,nconfig,percentual,tempodecorrido,novoscalculos,cachehits)

                end

            end

        end

    end

end

tempo=toc(inicio);

%% Calcular valores absolutos dos erros médios

abserromediomedido=abs(erromediomedido);

abserromediolorenco=abs(erromediolorenco);

%% Criar tabela de resumo

resumo=table(numeroserie,hconfig,vconfig,anguloconfig,distanciaconfig,erromediomedido,abserromediomedido,desviomedido,maemedido,rmsemedido,erromaximomedido,erromediolorenco,abserromediolorenco,desviolorenco,maelorenco,rmselorenco,erromaximolorenco,totalgumes,diferencatotalgumes,acertosgumes,errototalgumes,casosacimagumes,casosiguaisgumes,casosabaixogumes,casoscobertosgumes,coberturagumes,excessototalgumes,deficittotalgumes,gumesremovidos,casosalterados,melhorasmedido,piorasmedido,iguaismedido);

resumo.Properties.VariableNames={'NumeroSerie','h','v','Angulo','Distancia','ErroMedioMedido','AbsErroMedioMedido','DesvioMedido','MAEMedido','RMSEMedido','ErroMaximoMedido','ErroMedioLorenco','AbsErroMedioLorenco','DesvioLorenco','MAELorenco','RMSELorenco','ErroMaximoLorenco','TotalGumes','DiferencaTotalGumes','AcertosGumes','ErroTotalGumes','CasosAcimaGumes','CasosIguaisGumes','CasosAbaixoGumes','CasosCobertosGumes','CoberturaGumes','ExcessoTotalGumes','DeficitTotalGumes','GumesRemovidos','CasosAlterados','MelhorasMedido','PiorasMedido','IguaisMedido'};

%% Guardar estatísticas computacionais

estatisticas=struct;

estatisticas.Modo=nome;

estatisticas.Configuracoes=nconfig;

estatisticas.Casos=quantidade;

estatisticas.Avaliacoes=nconfig*quantidade;

estatisticas.NovosCalculos=novoscalculos;

estatisticas.CacheHits=cachehits;

estatisticas.Tempo=tempo;

end

%% Criar rankings

function [resumo,rankingmedido,rankinglorenco,rankinggumes,rankingcobertura,rankingequilibrado]=criarrankings(resumo)

n=height(resumo);

%% Ranking contra campo medido

tempmedido=sortrows(resumo,{'MAEMedido','RMSEMedido','AbsErroMedioMedido','ErroMaximoMedido','ErroTotalGumes'},{'ascend','ascend','ascend','ascend','ascend'});

rankmedido=zeros(n,1);

rankmedido(tempmedido.NumeroSerie)=(1:n)';

%% Ranking contra Lorenço

templorenco=sortrows(resumo,{'MAELorenco','RMSELorenco','AbsErroMedioLorenco','ErroMaximoLorenco','ErroTotalGumes'},{'ascend','ascend','ascend','ascend','ascend'});

ranklorenco=zeros(n,1);

ranklorenco(templorenco.NumeroSerie)=(1:n)';

%% Ranking da quantidade de gumes

tempgumes=sortrows(resumo,{'ErroTotalGumes','AcertosGumes','CasosAbaixoGumes','DeficitTotalGumes','MAEMedido'},{'ascend','descend','ascend','ascend','ascend'});

rankgumes=zeros(n,1);

rankgumes(tempgumes.NumeroSerie)=(1:n)';

%% Adicionar posições ao resumo

resumo.RankMedido=rankmedido;

resumo.RankLorenco=ranklorenco;

resumo.RankGumes=rankgumes;

resumo.RankEquilibrado=(rankmedido+ranklorenco+rankgumes)/3;

%% Criar rankings finais

rankingmedido=sortrows(resumo,{'MAEMedido','RMSEMedido','AbsErroMedioMedido','ErroMaximoMedido','ErroTotalGumes'},{'ascend','ascend','ascend','ascend','ascend'});

rankinglorenco=sortrows(resumo,{'MAELorenco','RMSELorenco','AbsErroMedioLorenco','ErroMaximoLorenco','ErroTotalGumes'},{'ascend','ascend','ascend','ascend','ascend'});

rankinggumes=sortrows(resumo,{'ErroTotalGumes','AcertosGumes','CasosAbaixoGumes','DeficitTotalGumes','MAEMedido'},{'ascend','descend','ascend','ascend','ascend'});

rankingcobertura=sortrows(resumo,{'CasosAbaixoGumes','DeficitTotalGumes','ErroTotalGumes','AcertosGumes','MAEMedido'},{'ascend','ascend','ascend','descend','ascend'});

rankingequilibrado=sortrows(resumo,{'RankEquilibrado','MAEMedido','MAELorenco','ErroTotalGumes'},{'ascend','ascend','ascend','ascend'});

end

%% Mostrar melhores configurações

function mostravencedores(nome,rankingmedido,rankinglorenco,rankinggumes,rankingcobertura,rankingequilibrado)

fprintf('\n')
fprintf('====================================================================================================================\n')
fprintf('MELHORES CONFIGURAÇÕES - %s\n',nome)
fprintf('====================================================================================================================\n')
fprintf('Critério       Série      h       v     Ângulo     Dist.     MAE Med.   MAE Lor.   Gumes   Acertos   Erro gumes\n')
fprintf('--------------------------------------------------------------------------------------------------------------------\n')

linha=rankingmedido(1,:);

fprintf('Medido       %7d   %5.3f   %5.3f   %6.3f   %7.1f     %7.3f    %7.3f     %3d      %2d         %3d\n',linha.NumeroSerie,linha.h,linha.v,linha.Angulo,linha.Distancia,linha.MAEMedido,linha.MAELorenco,linha.TotalGumes,linha.AcertosGumes,linha.ErroTotalGumes)

linha=rankinglorenco(1,:);

fprintf('Lorenço      %7d   %5.3f   %5.3f   %6.3f   %7.1f     %7.3f    %7.3f     %3d      %2d         %3d\n',linha.NumeroSerie,linha.h,linha.v,linha.Angulo,linha.Distancia,linha.MAEMedido,linha.MAELorenco,linha.TotalGumes,linha.AcertosGumes,linha.ErroTotalGumes)

linha=rankinggumes(1,:);

fprintf('Gumes        %7d   %5.3f   %5.3f   %6.3f   %7.1f     %7.3f    %7.3f     %3d      %2d         %3d\n',linha.NumeroSerie,linha.h,linha.v,linha.Angulo,linha.Distancia,linha.MAEMedido,linha.MAELorenco,linha.TotalGumes,linha.AcertosGumes,linha.ErroTotalGumes)

linha=rankingcobertura(1,:);

fprintf('Cobertura    %7d   %5.3f   %5.3f   %6.3f   %7.1f     %7.3f    %7.3f     %3d      %2d         %3d\n',linha.NumeroSerie,linha.h,linha.v,linha.Angulo,linha.Distancia,linha.MAEMedido,linha.MAELorenco,linha.TotalGumes,linha.AcertosGumes,linha.ErroTotalGumes)

linha=rankingequilibrado(1,:);

fprintf('Equilibrado  %7d   %5.3f   %5.3f   %6.3f   %7.1f     %7.3f    %7.3f     %3d      %2d         %3d\n',linha.NumeroSerie,linha.h,linha.v,linha.Angulo,linha.Distancia,linha.MAEMedido,linha.MAELorenco,linha.TotalGumes,linha.AcertosGumes,linha.ErroTotalGumes)

fprintf('====================================================================================================================\n')

end

%% Criar chave para cache

function chave=chaveindices(indexgumes)

if isempty(indexgumes)==true

    chave='semgumes';

else

    chave=sprintf('%d-',indexgumes);

end

end