clear
clc
close all

%% Definir caminhos

pastateste=fileparts(mfilename('fullpath'));

pastavarredura=fullfile(pastateste,'ResultadosVarredura85');

arquivodados=fullfile(pastavarredura,'ResumoTodasConfiguracoes.csv');

pastasaida=fullfile(pastateste,'ResultadosTendenciaMAE85');

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
fprintf('ANÁLISE DE TENDÊNCIA DOS FILTROS - 85 CASOS\n')
fprintf('============================================================\n')
fprintf('Configurações totais: %d\n',height(dados))

%% Manter somente configurações sem limite de distância

dados=dados(isinf(dados.LimiteDistancia),:);

fprintf('Configurações sem limite de distância: %d\n',height(dados))
fprintf('============================================================\n')

%% Obter valores dos parâmetros

valoresh=unique(dados.Limiteh);

valoresv=unique(dados.Limitev);

valoresangulo=unique(dados.LimiteAnguloGraus);

%% Calcular tendência para h

medianamaeh=zeros(length(valoresh),1);

mediamaeh=zeros(length(valoresh),1);

minimomaeh=zeros(length(valoresh),1);

q25h=zeros(length(valoresh),1);

q75h=zeros(length(valoresh),1);

for i=1:length(valoresh)

    mascara=dados.Limiteh==valoresh(i);

    valores=dados.MAEGiovaneli(mascara);

    medianamaeh(i)=median(valores);

    mediamaeh(i)=mean(valores);

    minimomaeh(i)=min(valores);

    q25h(i)=prctile(valores,25);

    q75h(i)=prctile(valores,75);

end

%% Calcular tendência para v

medianamaev=zeros(length(valoresv),1);

mediamaev=zeros(length(valoresv),1);

minimomaev=zeros(length(valoresv),1);

q25v=zeros(length(valoresv),1);

q75v=zeros(length(valoresv),1);

for i=1:length(valoresv)

    mascara=dados.Limitev==valoresv(i);

    valores=dados.MAEGiovaneli(mascara);

    medianamaev(i)=median(valores);

    mediamaev(i)=mean(valores);

    minimomaev(i)=min(valores);

    q25v(i)=prctile(valores,25);

    q75v(i)=prctile(valores,75);

end

%% Calcular tendência para limite angular

medianamaeangulo=zeros(length(valoresangulo),1);

mediamaeangulo=zeros(length(valoresangulo),1);

minimomaeangulo=zeros(length(valoresangulo),1);

q25angulo=zeros(length(valoresangulo),1);

q75angulo=zeros(length(valoresangulo),1);

for i=1:length(valoresangulo)

    mascara=dados.LimiteAnguloGraus==valoresangulo(i);

    valores=dados.MAEGiovaneli(mascara);

    medianamaeangulo(i)=median(valores);

    mediamaeangulo(i)=mean(valores);

    minimomaeangulo(i)=min(valores);

    q25angulo(i)=prctile(valores,25);

    q75angulo(i)=prctile(valores,75);

end

%% Mostrar tendência de h

fig1=figure('Color','w');

fig1.Position=[100 100 1200 700];

hold on

grid on

box on

scatter(dados.Limiteh,dados.MAEGiovaneli,12,'filled','MarkerFaceAlpha',0.08)

plot(valoresh,medianamaeh,'-o','LineWidth',2.5,'MarkerSize',6)

plot(valoresh,minimomaeh,'--','LineWidth',2)

xlabel('Limite de h (m)','FontSize',18)

ylabel('MAE de Giovaneli (dB)','FontSize',18)

title('Influência do limite de h sobre o erro','FontSize',20)

legend('Configurações avaliadas','Mediana do MAE','Menor MAE','Location','best','FontSize',13)

set(gca,'FontSize',16,'LineWidth',1.2)

arquivografico1=fullfile(pastasaida,'TendenciaMAE_h.png');

exportgraphics(fig1,arquivografico1,'Resolution',300);

%% Mostrar tendência de v

fig2=figure('Color','w');

fig2.Position=[100 100 1200 700];

hold on

grid on

box on

scatter(dados.Limitev,dados.MAEGiovaneli,12,'filled','MarkerFaceAlpha',0.08)

plot(valoresv,medianamaev,'-o','LineWidth',2.5,'MarkerSize',6)

plot(valoresv,minimomaev,'--','LineWidth',2)

xlabel('Limite de v','FontSize',18)

ylabel('MAE de Giovaneli (dB)','FontSize',18)

title('Influência do limite de v sobre o erro','FontSize',20)

legend('Configurações avaliadas','Mediana do MAE','Menor MAE','Location','best','FontSize',13)

set(gca,'FontSize',16,'LineWidth',1.2)

arquivografico2=fullfile(pastasaida,'TendenciaMAE_v.png');

exportgraphics(fig2,arquivografico2,'Resolution',300);

%% Mostrar tendência do limite angular

fig3=figure('Color','w');

fig3.Position=[100 100 1200 700];

hold on

grid on

box on

scatter(dados.LimiteAnguloGraus,dados.MAEGiovaneli,12,'filled','MarkerFaceAlpha',0.08)

plot(valoresangulo,medianamaeangulo,'-o','LineWidth',2.5,'MarkerSize',6)

plot(valoresangulo,minimomaeangulo,'--','LineWidth',2)

xlabel('Limite angular (graus)','FontSize',18)

ylabel('MAE de Giovaneli (dB)','FontSize',18)

title('Influência do limite angular sobre o erro','FontSize',20)

legend('Configurações avaliadas','Mediana do MAE','Menor MAE','Location','best','FontSize',13)

set(gca,'FontSize',16,'LineWidth',1.2)

arquivografico3=fullfile(pastasaida,'TendenciaMAE_Angulo.png');

exportgraphics(fig3,arquivografico3,'Resolution',300);

%% Criar tabelas de tendência

tendenciah=table(valoresh,mediamaeh,medianamaeh,q25h,q75h,minimomaeh);

tendenciah.Properties.VariableNames={'h','MediaMAE','MedianaMAE','Q25','Q75','MenorMAE'};

tendenciav=table(valoresv,mediamaev,medianamaev,q25v,q75v,minimomaev);

tendenciav.Properties.VariableNames={'v','MediaMAE','MedianaMAE','Q25','Q75','MenorMAE'};

tendenciaangulo=table(valoresangulo,mediamaeangulo,medianamaeangulo,q25angulo,q75angulo,minimomaeangulo);

tendenciaangulo.Properties.VariableNames={'Angulo','MediaMAE','MedianaMAE','Q25','Q75','MenorMAE'};

%% Salvar tabelas

writetable(tendenciah,fullfile(pastasaida,'TendenciaMAE_h.csv'));

writetable(tendenciav,fullfile(pastasaida,'TendenciaMAE_v.csv'));

writetable(tendenciaangulo,fullfile(pastasaida,'TendenciaMAE_Angulo.csv'));

%% Mostrar resumo

fprintf('\n')
fprintf('============================================================\n')
fprintf('TENDÊNCIA DE h\n')
fprintf('============================================================\n')

disp(tendenciah)

fprintf('\n')
fprintf('============================================================\n')
fprintf('TENDÊNCIA DE v\n')
fprintf('============================================================\n')

disp(tendenciav)

fprintf('\n')
fprintf('============================================================\n')
fprintf('TENDÊNCIA DO ÂNGULO\n')
fprintf('============================================================\n')

disp(tendenciaangulo)

%% Mostrar arquivos gerados

fprintf('\n')
fprintf('============================================================\n')
fprintf('ARQUIVOS GERADOS\n')
fprintf('============================================================\n')
fprintf('%s\n',arquivografico1)
fprintf('%s\n',arquivografico2)
fprintf('%s\n',arquivografico3)