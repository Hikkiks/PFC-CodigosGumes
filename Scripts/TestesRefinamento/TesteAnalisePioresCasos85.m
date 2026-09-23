clear
clc
close all

%% Definir caminhos

pastateste=fileparts(mfilename('fullpath'));

pastascripts=fileparts(pastateste);

addpath(fullfile(pastascripts,'Funções'))

pastavarredura=fullfile(pastascripts,'TestesFinais','ResultadosVarredura85');

arquivovarredura=fullfile(pastavarredura,'VarreduraFinalFiltros85.mat');

arquivopreparacao=fullfile(pastavarredura,'PreparacaoVarredura85.mat');

pastasaida=fullfile(pastateste,'ResultadosAnalisePioresCasos85');

if exist(pastasaida,'dir')==0
    mkdir(pastasaida)
end

%% Definir configurações analisadas

configs=[206554 203964 200330 206074];

npiores=10;

limiteerro=15;

%% Conferir arquivos de entrada

if exist(arquivovarredura,'file')~=2
    error('O arquivo VarreduraFinalFiltros85.mat não foi encontrado.')
end

if exist(arquivopreparacao,'file')~=2
    error('O arquivo PreparacaoVarredura85.mat não foi encontrado.')
end

%% Carregar resultados da varredura

load(arquivovarredura,'giomat','gumesmat','resumo')

%% Carregar dados de referência e condição original

load(arquivopreparacao,'giovanelilorenco','gumeslorenco','gumesoriginais','giooriginal','quantidade')

ncasos=quantidade;

if ncasos~=85
    error(['A preparação contém ' num2str(ncasos) ' casos em vez de 85.'])
end

if size(giomat,2)~=ncasos
    error('A matriz giomat não possui 85 casos.')
end

if size(gumesmat,2)~=ncasos
    error('A matriz gumesmat não possui 85 casos.')
end

if max(configs)>size(giomat,1)
    error('Uma das configurações selecionadas não existe na varredura.')
end

%% Preparar matrizes das quatro configurações

nconfig=length(configs);

matrizerros=NaN(ncasos,nconfig);

matrizgio=NaN(ncasos,nconfig);

matrizgumes=NaN(ncasos,nconfig);

dadosselecionados=table;

%% Organizar resultados das quatro configurações

for i=1:nconfig

    config=configs(i);

    linha=resumo(resumo.Config==config,:);

    if height(linha)~=1
        error(['A configuração ' num2str(config) ' não foi encontrada de forma única no resumo.'])
    end

    giocalculado=giomat(config,:)';

    gumescalculados=double(gumesmat(config,:))';

    if any(isnan(giocalculado))==true
        error(['A configuração ' num2str(config) ' possui resultados NaN.'])
    end

    erro=giocalculado-giovanelilorenco;

    matrizerros(:,i)=erro;

    matrizgio(:,i)=giocalculado;

    matrizgumes(:,i)=gumescalculados;

    configuracao=repmat(config,ncasos,1);

    caso=(1:ncasos)';

    limiteh=repmat(linha.Limiteh,ncasos,1);

    limitev=repmat(linha.Limitev,ncasos,1);

    limiteangulo=repmat(linha.LimiteAnguloGraus,ncasos,1);

    limitedistancia=repmat(linha.LimiteDistancia,ncasos,1);

    erroabsoluto=abs(erro);

    temp=table(configuracao,caso,limiteh,limitev,limiteangulo,limitedistancia,gumesoriginais,gumescalculados,gumeslorenco,giooriginal,giocalculado,giovanelilorenco,erro,erroabsoluto);

    temp.Properties.VariableNames={'Config','Caso','Limiteh','Limitev','LimiteAnguloGraus','LimiteDistancia','GumesOriginal','GumesFiltrado','GumesLorenco','GiovaneliOriginal','GiovaneliFiltrado','GiovaneliLorenco','ErroGiovaneli','ErroAbsoluto'};

    dadosselecionados=[dadosselecionados;temp];

end

%% Encontrar piores casos de cada configuração

piores=table;

for i=1:nconfig

    config=configs(i);

    temp=dadosselecionados(dadosselecionados.Config==config,:);

    temp=sortrows(temp,'ErroAbsoluto','descend');

    quantidadepiores=min(npiores,height(temp));

    temp=temp(1:quantidadepiores,:);

    temp.OrdemPiorCaso=(1:quantidadepiores)';

    temp=movevars(temp,'OrdemPiorCaso','Before',1);

    piores=[piores;temp];

end

%% Mostrar piores casos

fprintf('\n')
fprintf('============================================================\n')
fprintf('PIORES CASOS DE CADA CONFIGURAÇÃO\n')
fprintf('============================================================\n')

for i=1:nconfig

    config=configs(i);

    temp=piores(piores.Config==config,:);

    fprintf('\n')
    fprintf('CONFIGURAÇÃO %d\n',config)
    fprintf('\n')

    disp(temp(:,{'OrdemPiorCaso','Caso','ErroGiovaneli','ErroAbsoluto','GiovaneliLorenco','GiovaneliFiltrado','GumesLorenco','GumesFiltrado'}))

end

%% Salvar piores casos

arquivopiores=fullfile(pastasaida,'PioresCasos4Configuracoes.csv');

writetable(piores,arquivopiores);

%% Comparar casos extremos entre os quatro filtros

casosextremos=unique(piores.Caso);

comparacao=table(casosextremos,'VariableNames',{'Caso'});

for i=1:nconfig

    config=configs(i);

    nomevariavel=['Erro' num2str(config)];

    comparacao.(nomevariavel)=matrizerros(casosextremos,i);

end

comparacao.MaiorErroAbsoluto=max(abs(comparacao{:,2:end}),[],2);

comparacao.MediaErroAbsoluto=mean(abs(comparacao{:,2:end}),2);

comparacao=sortrows(comparacao,'MaiorErroAbsoluto','descend');

%% Mostrar comparação dos casos extremos

fprintf('\n')
fprintf('============================================================\n')
fprintf('CASOS EXTREMOS COMPARADOS NOS QUATRO FILTROS\n')
fprintf('============================================================\n')
fprintf('\n')

disp(comparacao)

%% Salvar comparação dos casos extremos

arquivocomparacao=fullfile(pastasaida,'ComparacaoCasosExtremos.csv');

writetable(comparacao,arquivocomparacao);

%% Criar tabela completa dos 85 casos

todoscasos=table((1:ncasos)','VariableNames',{'Caso'});

for i=1:nconfig

    nomevariavel=['Erro' num2str(configs(i))];

    todoscasos.(nomevariavel)=matrizerros(:,i);

end

todoscasos.MaiorErroAbsoluto=max(abs(matrizerros),[],2);

todoscasos.MediaErroAbsoluto=mean(abs(matrizerros),2);

todoscasos=sortrows(todoscasos,'MaiorErroAbsoluto','descend');

%% Mostrar perfis mais problemáticos

fprintf('\n')
fprintf('============================================================\n')
fprintf('15 PERFIS MAIS PROBLEMÁTICOS CONSIDERANDO OS 4 FILTROS\n')
fprintf('============================================================\n')
fprintf('\n')

disp(todoscasos(1:15,:))

%% Salvar ranking dos perfis

arquivotodos=fullfile(pastasaida,'RankingPerfisProblematicos.csv');

writetable(todoscasos,arquivotodos);

%% Criar gráfico do erro absoluto

fig1=figure('Color','w');

fig1.Position=[100 100 1400 700];

hold on
grid on
box on

for i=1:nconfig

    plot(1:ncasos,abs(matrizerros(:,i)),'LineWidth',1.8)

end

xlabel('Caso','FontSize',18)

ylabel('Erro absoluto (dB)','FontSize',18)

title('Erro absoluto nos 85 perfis de referência','FontSize',20)

legend(string(configs),'Location','best','FontSize',14)

set(gca,'FontSize',16,'LineWidth',1.2)

xlim([1 ncasos])

arquivografico1=fullfile(pastasaida,'ErrosAbsolutos85Casos.png');

exportgraphics(fig1,arquivografico1,'Resolution',300);

%% Criar gráfico do erro assinado

fig2=figure('Color','w');

fig2.Position=[100 100 1400 700];

hold on
grid on
box on

for i=1:nconfig

    plot(1:ncasos,matrizerros(:,i),'LineWidth',1.8)

end

yline(0,'--','LineWidth',1.2)

xlabel('Caso','FontSize',18)

ylabel('Erro (dB)','FontSize',18)

title('Erro assinado nos 85 perfis de referência','FontSize',20)

legend(string(configs),'Location','best','FontSize',14)

set(gca,'FontSize',16,'LineWidth',1.2)

xlim([1 ncasos])

arquivografico2=fullfile(pastasaida,'ErrosAssinados85Casos.png');

exportgraphics(fig2,arquivografico2,'Resolution',300);

%% Identificar casos com erros elevados

quantidadeextrema=sum(abs(matrizerros)>=limiteerro,2);

casosgraves=find(quantidadeextrema>0);

if isempty(casosgraves)==false

    tabelagraves=table;

    tabelagraves.Caso=casosgraves;

    tabelagraves.ConfiguracoesAcima15dB=quantidadeextrema(casosgraves);

    tabelagraves.MaiorErroAbsoluto=max(abs(matrizerros(casosgraves,:)),[],2);

    tabelagraves=sortrows(tabelagraves,'MaiorErroAbsoluto','descend');

    fprintf('\n')
    fprintf('============================================================\n')
    fprintf('CASOS COM PELO MENOS UM ERRO ABSOLUTO >= %.1f dB\n',limiteerro)
    fprintf('============================================================\n')
    fprintf('\n')

    disp(tabelagraves)

else

    fprintf('\n')
    fprintf('Nenhum caso apresentou erro absoluto superior a %.1f dB.\n',limiteerro)

end

%% Mostrar arquivos gerados

fprintf('\n')
fprintf('============================================================\n')
fprintf('ARQUIVOS GERADOS\n')
fprintf('============================================================\n')
fprintf('\n')

fprintf('%s\n',arquivopiores)
fprintf('%s\n',arquivocomparacao)
fprintf('%s\n',arquivotodos)
fprintf('%s\n',arquivografico1)
fprintf('%s\n',arquivografico2)