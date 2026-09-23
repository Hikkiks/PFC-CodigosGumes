clear
clc
close all

%% Definir caminhos

pastateste=fileparts(mfilename('fullpath'));

pastavarredura=fullfile(pastateste,'ResultadosVarredura85');

arquivodados=fullfile(pastavarredura,'ResumoTodasConfiguracoes.csv');

pastasaida=fullfile(pastateste,'ResultadosTendenciaGumes85');

if exist(pastasaida,'dir')==0
    mkdir(pastasaida)
end

if exist(arquivodados,'file')~=2
    error('O arquivo ResumoTodasConfiguracoes.csv não foi encontrado.')
end

%% Carregar resultados

dados=readtable(arquivodados);

fprintf('\n')
fprintf('============================================================\n')
fprintf('ANÁLISE DE TENDÊNCIA DA QUANTIDADE DE GUMES - 85 CASOS\n')
fprintf('============================================================\n')
fprintf('Configurações totais: %d\n',height(dados))

%% Conferir colunas

nomesvariaveis=dados.Properties.VariableNames;

if ismember('Limiteh',nomesvariaveis)==false
    error('A coluna Limiteh não foi encontrada.')
end

if ismember('Limitev',nomesvariaveis)==false
    error('A coluna Limitev não foi encontrada.')
end

if ismember('LimiteAnguloGraus',nomesvariaveis)==false
    error('A coluna LimiteAnguloGraus não foi encontrada.')
end

if ismember('LimiteDistancia',nomesvariaveis)==false
    error('A coluna LimiteDistancia não foi encontrada.')
end

%% Manter somente configurações sem limite de distância

dados=dados(isinf(dados.LimiteDistancia),:);

fprintf('Configurações sem limite de distância: %d\n',height(dados))

%% Localizar dados de gumes

[valoresgumes,rotuloy,nomedadosgumes]=localizagumes(dados);

fprintf('Coluna utilizada para gumes: %s\n',nomedadosgumes)
fprintf('============================================================\n')

%% Calcular tendências

tabelah=resumetendencia(dados.Limiteh,valoresgumes,'h');

tabelav=resumetendencia(dados.Limitev,valoresgumes,'v');

tabelaangulo=resumetendencia(dados.LimiteAnguloGraus,valoresgumes,'angulo');

%% Mostrar quantidade de amostras

fprintf('\n')
fprintf('============================================================\n')
fprintf('QUANTIDADE DE AMOSTRAS POR VALOR DO PARÂMETRO\n')
fprintf('============================================================\n')
fprintf('h:       %d amostras por valor\n',tabelah.QuantidadeConfiguracoes(1))
fprintf('v:       %d amostras por valor\n',tabelav.QuantidadeConfiguracoes(1))
fprintf('Ângulo:  %d amostras por valor\n',tabelaangulo.QuantidadeConfiguracoes(1))
fprintf('============================================================\n')

%% Mostrar tabelas

imprimetabela(tabelah,'TENDÊNCIA DE h - GUMES MANTIDOS','h');

imprimetabela(tabelav,'TENDÊNCIA DE v - GUMES MANTIDOS','v');

imprimetabela(tabelaangulo,'TENDÊNCIA DE ÂNGULO - GUMES MANTIDOS','Ângulo');

%% Mostrar tendência de h

figurah=figure('Color','w');

hold on

scatter(dados.Limiteh,valoresgumes,8,[0.3010 0.7450 0.9330],'filled','MarkerFaceAlpha',0.15,'MarkerEdgeAlpha',0.15)

plot(tabelah.ValorParametro,tabelah.Mediana,'-o','Color',[0.8500 0.3250 0.0980],'LineWidth',1.8,'MarkerSize',5)

plot(tabelah.ValorParametro,tabelah.Minimo,'--','Color',[0.9290 0.6940 0.1250],'LineWidth',1.5)

xlabel('Limite de h (m)','FontSize',14)

ylabel(rotuloy,'FontSize',14)

title('Influência do limite de h sobre a quantidade de gumes mantidos','FontSize',16)

legend('Configurações avaliadas','Mediana dos gumes','Menor valor observado','Location','best')

set(gca,'FontSize',12,'LineWidth',1.2)

grid on

hold off

%% Mostrar tendência de v

figurav=figure('Color','w');

hold on

scatter(dados.Limitev,valoresgumes,8,[0.3010 0.7450 0.9330],'filled','MarkerFaceAlpha',0.15,'MarkerEdgeAlpha',0.15)

plot(tabelav.ValorParametro,tabelav.Mediana,'-o','Color',[0.8500 0.3250 0.0980],'LineWidth',1.8,'MarkerSize',5)

plot(tabelav.ValorParametro,tabelav.Minimo,'--','Color',[0.9290 0.6940 0.1250],'LineWidth',1.5)

xlabel('Limite de v','FontSize',14)

ylabel(rotuloy,'FontSize',14)

title('Influência do limite de v sobre a quantidade de gumes mantidos','FontSize',16)

legend('Configurações avaliadas','Mediana dos gumes','Menor valor observado','Location','best')

set(gca,'FontSize',12,'LineWidth',1.2)

grid on

hold off

%% Mostrar tendência do limite angular

figuraangulo=figure('Color','w');

hold on

scatter(dados.LimiteAnguloGraus,valoresgumes,8,[0.3010 0.7450 0.9330],'filled','MarkerFaceAlpha',0.15,'MarkerEdgeAlpha',0.15)

plot(tabelaangulo.ValorParametro,tabelaangulo.Mediana,'-o','Color',[0.8500 0.3250 0.0980],'LineWidth',1.8,'MarkerSize',5)

plot(tabelaangulo.ValorParametro,tabelaangulo.Minimo,'--','Color',[0.9290 0.6940 0.1250],'LineWidth',1.5)

xlabel('Limite angular (graus)','FontSize',14)

ylabel(rotuloy,'FontSize',14)

title('Influência do limite angular sobre a quantidade de gumes mantidos','FontSize',16)

legend('Configurações avaliadas','Mediana dos gumes','Menor valor observado','Location','best')

set(gca,'FontSize',12,'LineWidth',1.2)

grid on

hold off

%% Salvar gráficos

arquivoh=fullfile(pastasaida,'TendenciaGumes_h.png');

arquivov=fullfile(pastasaida,'TendenciaGumes_v.png');

arquivoangulo=fullfile(pastasaida,'TendenciaGumes_Angulo.png');

exportgraphics(figurah,arquivoh,'Resolution',300)

exportgraphics(figurav,arquivov,'Resolution',300)

exportgraphics(figuraangulo,arquivoangulo,'Resolution',300)

%% Salvar tabelas

writetable(tabelah,fullfile(pastasaida,'TabelaTendenciaGumes_h.csv'))

writetable(tabelav,fullfile(pastasaida,'TabelaTendenciaGumes_v.csv'))

writetable(tabelaangulo,fullfile(pastasaida,'TabelaTendenciaGumes_Angulo.csv'))

%% Mostrar arquivos gerados

fprintf('\n')
fprintf('============================================================\n')
fprintf('ARQUIVOS GERADOS\n')
fprintf('============================================================\n')
fprintf('%s\n',arquivoh)
fprintf('%s\n',arquivov)
fprintf('%s\n',arquivoangulo)
fprintf('============================================================\n')

%% Localizar coluna de gumes

function [valoresgumes,rotuloy,nomedados]=localizagumes(dados)

nomes=dados.Properties.VariableNames;

candidatos={'TotalGumes','TotalGumesFinais','GumesFinaisTotal','GumesMantidos','GumesTotais','SomaGumes','SomaGumesFinais','MediaGumes','MediaGumesFinais'};

indiceencontrado=0;

nomedados='';

for i=1:length(candidatos)

    if ismember(candidatos{i},nomes)==true

        indiceencontrado=i;

        nomedados=candidatos{i};

        break

    end

end

if indiceencontrado==0

    fprintf('\n')
    fprintf('Variáveis disponíveis no arquivo:\n')
    fprintf('\n')

    for i=1:length(nomes)
        fprintf('%s\n',nomes{i})
    end

    error('Nenhuma coluna de quantidade de gumes foi encontrada no arquivo.')

end

valoresgumes=dados.(nomedados);

if contains(lower(nomedados),'media')

    rotuloy='Média de gumes mantidos por caso';

else

    rotuloy='Total de gumes mantidos';

end

end

%% Calcular tendência

function tabela=resumetendencia(valoresparametro,valoresgumes,nomeparametro)

valoresunicos=unique(valoresparametro);

n=length(valoresunicos);

parametro=zeros(n,1);

mediagumes=zeros(n,1);

medianagumes=zeros(n,1);

q25=zeros(n,1);

q75=zeros(n,1);

minimogumes=zeros(n,1);

maximogumes=zeros(n,1);

desviogumes=zeros(n,1);

quantidadeconfigs=zeros(n,1);

for i=1:n

    valor=valoresunicos(i);

    mascara=valoresparametro==valor;

    gumes=valoresgumes(mascara);

    parametro(i)=valor;

    mediagumes(i)=mean(gumes);

    medianagumes(i)=median(gumes);

    q25(i)=prctile(gumes,25);

    q75(i)=prctile(gumes,75);

    minimogumes(i)=min(gumes);

    maximogumes(i)=max(gumes);

    desviogumes(i)=std(gumes,1);

    quantidadeconfigs(i)=length(gumes);

end

tabela=table(parametro,mediagumes,medianagumes,q25,q75,minimogumes,maximogumes,desviogumes,quantidadeconfigs);

tabela.Properties.VariableNames={'ValorParametro','Media','Mediana','Q25','Q75','Minimo','Maximo','Desvio','QuantidadeConfiguracoes'};

if strcmp(nomeparametro,'h')==true

    tabela.Properties.Description='Tendência de h';

elseif strcmp(nomeparametro,'v')==true

    tabela.Properties.Description='Tendência de v';

else

    tabela.Properties.Description='Tendência de ângulo';

end

end

%% Mostrar tabela

function imprimetabela(tabela,titulo,colunaprincipal)

fprintf('\n')
fprintf('------------------------------------------------------------\n')
fprintf('%s\n',titulo)
fprintf('------------------------------------------------------------\n')
fprintf('\n')

fprintf('%-12s %-12s %-12s %-12s %-12s %-12s %-12s %-12s %-12s\n',colunaprincipal,'Média','Mediana','Q25','Q75','Mínimo','Máximo','Desvio','Ncfg')
fprintf('%-12s %-12s %-12s %-12s %-12s %-12s %-12s %-12s %-12s\n','------------','------------','------------','------------','------------','------------','------------','------------','------------')

for i=1:height(tabela)

    fprintf('%-12.4g %-12.4f %-12.4f %-12.4f %-12.4f %-12.4f %-12.4f %-12.4f %-12d\n',tabela.ValorParametro(i),tabela.Media(i),tabela.Mediana(i),tabela.Q25(i),tabela.Q75(i),tabela.Minimo(i),tabela.Maximo(i),tabela.Desvio(i),tabela.QuantidadeConfiguracoes(i))

end

end