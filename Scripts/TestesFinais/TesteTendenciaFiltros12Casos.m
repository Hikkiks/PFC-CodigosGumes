clear
clc
close all

%% Definir caminhos

pastateste=fileparts(mfilename('fullpath'));

pasta12=fullfile(pastateste,'ResultadosVarredura12Casos');

arquivodados=fullfile(pasta12,'ResumoVarredura12CasosSemFresnel.csv');

pastasaida=fullfile(pasta12,'GraficosTendenciaFiltros12');

if exist(arquivodados,'file')~=2
    error('O arquivo ResumoVarredura12CasosSemFresnel.csv não foi encontrado.')
end

if exist(pastasaida,'dir')==0
    mkdir(pastasaida)
end

%% Carregar dados

dados=readtable(arquivodados);

fprintf('\n')
fprintf('============================================================\n')
fprintf('TENDÊNCIA DOS FILTROS - 12 CASOS SEM FRESNEL\n')
fprintf('============================================================\n')
fprintf('Arquivo utilizado:\n')
fprintf('%s\n',arquivodados)
fprintf('\n')
fprintf('Configurações totais: %d\n',height(dados))

%% Localizar colunas

nomes=string(dados.Properties.VariableNames);

nomeh=localizacoluna(nomes,["Limiteh" "h"]);

nomev=localizacoluna(nomes,["Limitev" "v"]);

nomeangulo=localizacoluna(nomes,["LimiteAnguloGraus" "LimiteAngulo" "Angulo"]);

nomedistancia=localizacoluna(nomes,["LimiteDistancia" "Distancia"]);

nomemae=localizacoluna(nomes,["MAEMedido" "MAE" "MAECampo" "MAEGiovaneli"]);

nomegumes=localizacoluna(nomes,["TotalGumes" "GumesFinais" "GumesTotais"]);

if nomeh==""
    error('Coluna de h não encontrada.')
end

if nomev==""
    error('Coluna de v não encontrada.')
end

if nomeangulo==""
    error('Coluna de ângulo não encontrada.')
end

if nomedistancia==""
    error('Coluna de distância não encontrada.')
end

if nomemae==""

    fprintf('\n')
    fprintf('Colunas disponíveis:\n')

    disp(nomes')

    error('Coluna de MAE não encontrada.')

end

if nomegumes==""

    fprintf('\n')
    fprintf('Colunas disponíveis:\n')

    disp(nomes')

    error('Coluna de quantidade de gumes não encontrada.')

end

%% Mostrar colunas utilizadas

fprintf('\n')
fprintf('Colunas utilizadas:\n')
fprintf('h:         %s\n',nomeh)
fprintf('v:         %s\n',nomev)
fprintf('Ângulo:    %s\n',nomeangulo)
fprintf('Distância: %s\n',nomedistancia)
fprintf('MAE:       %s\n',nomemae)
fprintf('Gumes:     %s\n',nomegumes)

%% Manter somente configurações sem limite de distância

mascara=isinf(dados.(char(nomedistancia)));

dados=dados(mascara,:);

fprintf('\n')
fprintf('============================================================\n')
fprintf('CONFIGURAÇÕES COM DISTÂNCIA = Inf\n')
fprintf('============================================================\n')
fprintf('Configurações consideradas: %d\n',height(dados))

%% Extrair vetores

h=dados.(char(nomeh));

v=dados.(char(nomev));

angulo=dados.(char(nomeangulo));

mae=dados.(char(nomemae));

gumes=dados.(char(nomegumes));

%% Calcular tendências

tabelah=resumetendencia(h,mae,gumes);

tabelav=resumetendencia(v,mae,gumes);

tabelaangulo=resumetendencia(angulo,mae,gumes);

%% Mostrar quantidade de amostras

fprintf('\n')
fprintf('============================================================\n')
fprintf('QUANTIDADE DE AMOSTRAS POR VALOR DE X\n')
fprintf('============================================================\n')

fprintf('h       | %3d valores | ',height(tabelah))

if all(tabelah.QuantidadeConfiguracoes==tabelah.QuantidadeConfiguracoes(1))

    fprintf('%d amostras por valor\n',tabelah.QuantidadeConfiguracoes(1))

else

    fprintf('quantidade variável de amostras\n')

end

fprintf('v       | %3d valores | ',height(tabelav))

if all(tabelav.QuantidadeConfiguracoes==tabelav.QuantidadeConfiguracoes(1))

    fprintf('%d amostras por valor\n',tabelav.QuantidadeConfiguracoes(1))

else

    fprintf('quantidade variável de amostras\n')

end

fprintf('Ângulo  | %3d valores | ',height(tabelaangulo))

if all(tabelaangulo.QuantidadeConfiguracoes==tabelaangulo.QuantidadeConfiguracoes(1))

    fprintf('%d amostras por valor\n',tabelaangulo.QuantidadeConfiguracoes(1))

else

    fprintf('quantidade variável de amostras\n')

end

fprintf('============================================================\n')

%% Definir escala vertical do MAE

yminmae=min(mae);

ymaxmae=max(mae);

margemmae=0.03*(ymaxmae-yminmae);

if margemmae==0
    margemmae=1;
end

yminmae=yminmae-margemmae;

ymaxmae=ymaxmae+margemmae;

%% Criar figura de MAE

figmae=figure('Color','w');

figmae.Position=[100 40 1050 1200];

layoutmae=tiledlayout(3,1);

layoutmae.TileSpacing='compact';

layoutmae.Padding='compact';

%% Mostrar h x MAE

nexttile

hold on

grid on

box on

scatter(h,mae,8,'filled','MarkerFaceAlpha',0.08,'MarkerEdgeAlpha',0.08)

plot(tabelah.ValorParametro,tabelah.MedianaMAE,'-o','LineWidth',2.2,'MarkerSize',5)

plot(tabelah.ValorParametro,tabelah.MinimoMAE,'--','LineWidth',1.8)

xlabel('Limite de h (m)','FontSize',13)

ylabel('MAE (dB)','FontSize',13)

title('Influência do limite de h','FontSize',15)

legend('Configurações avaliadas','Mediana do MAE','Menor MAE','Location','best','FontSize',10)

set(gca,'FontSize',12,'LineWidth',1.1)

ylim([yminmae ymaxmae])

hold off

%% Mostrar v x MAE

nexttile

hold on

grid on

box on

scatter(v,mae,8,'filled','MarkerFaceAlpha',0.08,'MarkerEdgeAlpha',0.08)

plot(tabelav.ValorParametro,tabelav.MedianaMAE,'-o','LineWidth',2.2,'MarkerSize',5)

plot(tabelav.ValorParametro,tabelav.MinimoMAE,'--','LineWidth',1.8)

xlabel('Limite de v','FontSize',13)

ylabel('MAE (dB)','FontSize',13)

title('Influência do limite de v','FontSize',15)

set(gca,'FontSize',12,'LineWidth',1.1)

ylim([yminmae ymaxmae])

hold off

%% Mostrar ângulo x MAE

nexttile

hold on

grid on

box on

scatter(angulo,mae,8,'filled','MarkerFaceAlpha',0.08,'MarkerEdgeAlpha',0.08)

plot(tabelaangulo.ValorParametro,tabelaangulo.MedianaMAE,'-o','LineWidth',2.2,'MarkerSize',5)

plot(tabelaangulo.ValorParametro,tabelaangulo.MinimoMAE,'--','LineWidth',1.8)

xlabel('Limite angular (graus)','FontSize',13)

ylabel('MAE (dB)','FontSize',13)

title('Influência do limite angular','FontSize',15)

set(gca,'FontSize',12,'LineWidth',1.1)

ylim([yminmae ymaxmae])

hold off

title(layoutmae,'Influência dos parâmetros do filtro sobre o MAE nos 12 casos medidos','FontSize',17,'FontWeight','bold')

%% Salvar figura de MAE

arquivomae=fullfile(pastasaida,'TendenciaMAE12_SemLimiteDistancia.png');

exportgraphics(figmae,arquivomae,'Resolution',300)

%% Definir escala vertical dos gumes

ymingumes=min(gumes);

ymaxgumes=max(gumes);

margemgumes=0.03*(ymaxgumes-ymingumes);

if margemgumes==0
    margemgumes=1;
end

ymingumes=ymingumes-margemgumes;

ymaxgumes=ymaxgumes+margemgumes;

%% Criar figura de gumes

figgumes=figure('Color','w');

figgumes.Position=[100 40 1050 1200];

layoutgumes=tiledlayout(3,1);

layoutgumes.TileSpacing='compact';

layoutgumes.Padding='compact';

%% Mostrar h x gumes

nexttile

hold on

grid on

box on

scatter(h,gumes,8,'filled','MarkerFaceAlpha',0.08,'MarkerEdgeAlpha',0.08)

plot(tabelah.ValorParametro,tabelah.MedianaGumes,'-o','LineWidth',2.2,'MarkerSize',5)

plot(tabelah.ValorParametro,tabelah.MinimoGumes,'--','LineWidth',1.8)

xlabel('Limite de h (m)','FontSize',13)

ylabel('Total de gumes mantidos','FontSize',13)

title('Influência do limite de h','FontSize',15)

legend('Configurações avaliadas','Mediana dos gumes','Menor quantidade','Location','best','FontSize',10)

set(gca,'FontSize',12,'LineWidth',1.1)

ylim([ymingumes ymaxgumes])

hold off

%% Mostrar v x gumes

nexttile

hold on

grid on

box on

scatter(v,gumes,8,'filled','MarkerFaceAlpha',0.08,'MarkerEdgeAlpha',0.08)

plot(tabelav.ValorParametro,tabelav.MedianaGumes,'-o','LineWidth',2.2,'MarkerSize',5)

plot(tabelav.ValorParametro,tabelav.MinimoGumes,'--','LineWidth',1.8)

xlabel('Limite de v','FontSize',13)

ylabel('Total de gumes mantidos','FontSize',13)

title('Influência do limite de v','FontSize',15)

set(gca,'FontSize',12,'LineWidth',1.1)

ylim([ymingumes ymaxgumes])

hold off

%% Mostrar ângulo x gumes

nexttile

hold on

grid on

box on

scatter(angulo,gumes,8,'filled','MarkerFaceAlpha',0.08,'MarkerEdgeAlpha',0.08)

plot(tabelaangulo.ValorParametro,tabelaangulo.MedianaGumes,'-o','LineWidth',2.2,'MarkerSize',5)

plot(tabelaangulo.ValorParametro,tabelaangulo.MinimoGumes,'--','LineWidth',1.8)

xlabel('Limite angular (graus)','FontSize',13)

ylabel('Total de gumes mantidos','FontSize',13)

title('Influência do limite angular','FontSize',15)

set(gca,'FontSize',12,'LineWidth',1.1)

ylim([ymingumes ymaxgumes])

hold off

title(layoutgumes,'Influência dos parâmetros do filtro sobre a quantidade de gumes nos 12 casos','FontSize',17,'FontWeight','bold')

%% Salvar figura de gumes

arquivogumes=fullfile(pastasaida,'TendenciaGumes12_SemLimiteDistancia.png');

exportgraphics(figgumes,arquivogumes,'Resolution',300)

%% Salvar tabelas de tendência

writetable(tabelah,fullfile(pastasaida,'Tendencia12_h_SemLimiteDistancia.csv'))

writetable(tabelav,fullfile(pastasaida,'Tendencia12_v_SemLimiteDistancia.csv'))

writetable(tabelaangulo,fullfile(pastasaida,'Tendencia12_Angulo_SemLimiteDistancia.csv'))

%% Mostrar tabelas de tendência

fprintf('\n')
fprintf('============================================================\n')
fprintf('TENDÊNCIA DE h\n')
fprintf('============================================================\n')

disp(tabelah)

fprintf('\n')
fprintf('============================================================\n')
fprintf('TENDÊNCIA DE v\n')
fprintf('============================================================\n')

disp(tabelav)

fprintf('\n')
fprintf('============================================================\n')
fprintf('TENDÊNCIA DO ÂNGULO\n')
fprintf('============================================================\n')

disp(tabelaangulo)

%% Mostrar arquivos gerados

fprintf('\n')
fprintf('============================================================\n')
fprintf('ARQUIVOS GERADOS\n')
fprintf('============================================================\n')
fprintf('Gráfico de MAE:\n')
fprintf('%s\n',arquivomae)

fprintf('\n')
fprintf('Gráfico de gumes:\n')
fprintf('%s\n',arquivogumes)

fprintf('\n')
fprintf('Tabelas de tendência:\n')
fprintf('%s\n',pastasaida)

fprintf('============================================================\n')

%% Localizar coluna pelo nome

function nome=localizacoluna(nomes,candidatos)

nome="";

for i=1:length(candidatos)

    indice=find(strcmpi(nomes,candidatos(i)),1);

    if isempty(indice)==false

        nome=nomes(indice);

        return

    end

end

end

%% Resumir tendência de um parâmetro

function tabela=resumetendencia(parametro,mae,gumes)

valores=unique(parametro);

n=length(valores);

valorparametro=zeros(n,1);

mediamae=zeros(n,1);

medianamae=zeros(n,1);

q25mae=zeros(n,1);

q75mae=zeros(n,1);

minimomae=zeros(n,1);

maximomae=zeros(n,1);

mediagumes=zeros(n,1);

medianagumes=zeros(n,1);

q25gumes=zeros(n,1);

q75gumes=zeros(n,1);

minimogumes=zeros(n,1);

maximogumes=zeros(n,1);

quantidadeconfiguracoes=zeros(n,1);

for i=1:n

    valor=valores(i);

    mascara=parametro==valor;

    valoresmae=mae(mascara);

    valoresgumes=gumes(mascara);

    valorparametro(i)=valor;

    mediamae(i)=mean(valoresmae);

    medianamae(i)=median(valoresmae);

    q25mae(i)=prctile(valoresmae,25);

    q75mae(i)=prctile(valoresmae,75);

    minimomae(i)=min(valoresmae);

    maximomae(i)=max(valoresmae);

    mediagumes(i)=mean(valoresgumes);

    medianagumes(i)=median(valoresgumes);

    q25gumes(i)=prctile(valoresgumes,25);

    q75gumes(i)=prctile(valoresgumes,75);

    minimogumes(i)=min(valoresgumes);

    maximogumes(i)=max(valoresgumes);

    quantidadeconfiguracoes(i)=length(valoresmae);

end

tabela=table(valorparametro,mediamae,medianamae,q25mae,q75mae,minimomae,maximomae,mediagumes,medianagumes,q25gumes,q75gumes,minimogumes,maximogumes,quantidadeconfiguracoes);

tabela.Properties.VariableNames={'ValorParametro','MediaMAE','MedianaMAE','Q25MAE','Q75MAE','MinimoMAE','MaximoMAE','MediaGumes','MedianaGumes','Q25Gumes','Q75Gumes','MinimoGumes','MaximoGumes','QuantidadeConfiguracoes'};

end