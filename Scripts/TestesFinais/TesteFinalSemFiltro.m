clear
clc
close all

%% Definir caminhos

pastateste=fileparts(mfilename('fullpath'));

pastascripts=fileparts(pastateste);

addpath(fullfile(pastascripts,'Funções'))

pastaperfis=fullfile(pastascripts,'DadosSalvos','DadosConclusao');

pastasaida=fullfile(pastateste,'Resultados12CasosSemFiltro');

if exist(pastasaida,'dir')==0
    mkdir(pastasaida);
end

%% Definir dados das emissoras

freq=[557.142857*10^6 581.142857*10^6];

alturat=[76.2 113];

alturar=1.5;

%% Definir distâncias apresentadas por Lorenço

distancias=[4.76007 4.90242 5.57821 11.62309 10.55351 15.94797;
            3.93443 4.15807 6.28328 12.03950 11.27558 16.73901];

%% Definir ERP em cada ponto

erp=[0.05631 1.49906 5.09155 3.01382 3.23998 2.12244;
     0.32496 1.13006 3.22440 3.14907 3.08243 3.10165];

%% Definir resultados de Giovaneli apresentados por Lorenço

giolorenco=[60.90812 68.02893 68.38195 65.51763 69.00870 69.05509;
            77.91189 78.03863 71.02870 67.12174 66.92914 75.73337];

%% Definir valores medidos em campo

medido=[64.6 65.3 67.3 64.1 66.9 65.7;
        78.9 78.3 72.0 64.5 66.8 65.0];

%% Definir gumes apresentados por Lorenço

gumeslorenco=[3 3 4 3 3 2;
              2 2 3 3 3 1];

%% Preparar vetores de resultados

casos=strings(12,1);

campolivre=zeros(12,1);

campooriginal=zeros(12,1);

perdagiovanelioriginal=zeros(12,1);

gumesoriginal=zeros(12,1);

%% Processar os 12 casos

linha=0;

for emissora=1:2

    for ponto=1:6

        linha=linha+1;

        casos(linha)="E"+string(emissora)+"-P"+string(ponto);

        %% Carregar perfil original

        nomearquivo=['DadosConclusaoE' num2str(emissora) 'P' num2str(ponto) '.mat'];

        caminhoarquivo=fullfile(pastaperfis,nomearquivo);

        dadosarquivo=load(caminhoarquivo,'dadoselev');

        dadoselev=dadosarquivo.dadoselev;

        %% Aplicar correção do raio efetivo

        dadoselev=raioefetivo(dadoselev);

        %% Identificar gumes sem filtro e sem Fresnel adicional

        [indexgumes,gumes]=indexgumess(dadoselev,alturat(emissora),alturar,freq(emissora),false);

        gumesoriginal(linha)=gumes;

        %% Calcular campo antes da difração

        erpkw=erp(emissora,ponto);

        distkm=distancias(emissora,ponto);

        campolivre(linha)=100+10*log10((4.92*erpkw)/(distkm^2));

        %% Calcular perda pelo modelo de Giovaneli

        perda=perdagiovaneli(indexgumes,dadoselev,freq(emissora),gumes,alturar,alturat(emissora));

        perdadif=-perda;

        perdagiovanelioriginal(linha)=perdadif;

        %% Calcular campo final

        campooriginal(linha)=campolivre(linha)-perdadif;

    end

end

%% Organizar dados de referência

giolorencovetor=reshape(giolorenco',[],1);

medidovetor=reshape(medido',[],1);

gumeslorencovetor=reshape(gumeslorenco',[],1);

%% Calcular erros em relação às medições

errolorenco=giolorencovetor-medidovetor;

errooriginal=campooriginal-medidovetor;

%% Calcular diferença em relação a Lorenço

diflorenco=campooriginal-giolorencovetor;

%% Calcular diferença na quantidade de gumes

difgumes=gumesoriginal-gumeslorencovetor;

%% Criar tabela completa

tabelacompleta=table(casos,medidovetor,giolorencovetor,campooriginal,errolorenco,errooriginal,diflorenco,gumeslorencovetor,gumesoriginal,difgumes,campolivre,perdagiovanelioriginal);

tabelacompleta.Properties.VariableNames={'Caso','Medido','Lorenco','Original','ErroLorenco','ErroOriginal','OriginalMenosLorenco','GumesLorenco','GumesOriginal','DiferencaGumes','CampoLivre','PerdaGiovaneliOriginal'};

%% Calcular métricas de Lorenço

biaslorenco=mean(errolorenco);

desviolorenco=std(errolorenco,1);

maelorenco=mean(abs(errolorenco));

rmselorenco=sqrt(mean(errolorenco.^2));

maxlorenco=max(abs(errolorenco));

%% Calcular métricas da implementação original

biasoriginal=mean(errooriginal);

desviooriginal=std(errooriginal,1);

maeoriginal=mean(abs(errooriginal));

rmseoriginal=sqrt(mean(errooriginal.^2));

maxoriginal=max(abs(errooriginal));

%% Calcular métricas em relação a Lorenço

biascomparacao=mean(diflorenco);

desviocomparacao=std(diflorenco,1);

maecomparacao=mean(abs(diflorenco));

rmsecomparacao=sqrt(mean(diflorenco.^2));

maxcomparacao=max(abs(diflorenco));

%% Comparar quantidade de gumes

totalgumeslorenco=sum(gumeslorencovetor);

totalgumesoriginal=sum(gumesoriginal);

acertosgumes=sum(gumesoriginal==gumeslorencovetor);

errototalgumes=sum(abs(difgumes));

%% Criar resumo comparado ao campo medido

metodo=["Lorenco"; "Original sem filtro"];

bias=[biaslorenco; biasoriginal];

desvio=[desviolorenco; desviooriginal];

mae=[maelorenco; maeoriginal];

rmse=[rmselorenco; rmseoriginal];

erromaximo=[maxlorenco; maxoriginal];

resumocampo=table(metodo,bias,desvio,mae,rmse,erromaximo);

resumocampo.Properties.VariableNames={'Metodo','ErroMedio','Desvio','MAE','RMSE','ErroMaximo'};

%% Criar resumo da comparação direta com Lorenço

resumocomparacao=table(biascomparacao,desviocomparacao,maecomparacao,rmsecomparacao,maxcomparacao,totalgumeslorenco,totalgumesoriginal,acertosgumes,errototalgumes);

resumocomparacao.Properties.VariableNames={'ErroMedio','Desvio','MAE','RMSE','ErroMaximo','TotalGumesLorenco','TotalGumesOriginal','AcertosGumes','ErroTotalGumes'};

%% Mostrar resultados

disp(' ')
disp('================ RESULTADOS COMPLETOS ================')
disp(tabelacompleta)

disp(' ')
disp('================ CAMPO X MEDIDO ======================')
disp(resumocampo)

disp(' ')
disp('================ ORIGINAL X LORENCO ==================')
disp(resumocomparacao)

%% Salvar CSVs

writetable(tabelacompleta,fullfile(pastasaida,'ComparacaoOriginal12Casos.csv'));

writetable(resumocampo,fullfile(pastasaida,'ResumoCampoOriginal.csv'));

writetable(resumocomparacao,fullfile(pastasaida,'ResumoOriginalVsLorenco.csv'));

%% Criar tabela visual principal

fig=figure('Color','w');

fig.Position=[80 80 1650 620];

dadosfigura=cell(12,10);

for i=1:12

    dadosfigura{i,1}=char(casos(i));

    dadosfigura{i,2}=sprintf('%.2f',medidovetor(i));

    dadosfigura{i,3}=sprintf('%.2f',giolorencovetor(i));

    dadosfigura{i,4}=sprintf('%.2f',campooriginal(i));

    dadosfigura{i,5}=sprintf('%.2f',errolorenco(i));

    dadosfigura{i,6}=sprintf('%.2f',errooriginal(i));

    dadosfigura{i,7}=sprintf('%.2f',diflorenco(i));

    dadosfigura{i,8}=sprintf('%d',gumeslorencovetor(i));

    dadosfigura{i,9}=sprintf('%d',gumesoriginal(i));

    dadosfigura{i,10}=sprintf('%+d',difgumes(i));

end

tabela=uitable(fig);

tabela.Data=dadosfigura;

tabela.ColumnName={'Caso','Medido','Lorenço','Original sem filtro','Erro Lorenço','Erro original','Original - Lorenço','Gumes Lorenço','Gumes original','Dif. gumes'};

tabela.RowName=[];

tabela.FontSize=12;

tabela.Position=[30 30 1590 510];

tabela.ColumnWidth={75 90 90 130 105 105 125 110 110 90};

annotation(fig,'textbox',[0.02 0.92 0.96 0.06],'String','Comparação da implementação original sem filtro com os resultados de Lorenço','HorizontalAlignment','center','VerticalAlignment','middle','FontSize',18,'FontWeight','bold','EdgeColor','none');

%% Salvar tabela principal

exportgraphics(fig,fullfile(pastasaida,'TabelaOriginal12Casos.png'),'Resolution',300);

%% Criar tabela visual de resumo

fig2=figure('Color','w');

fig2.Position=[200 150 1000 330];

dadosresumo=cell(2,6);

for i=1:2

    dadosresumo{i,1}=char(resumocampo.Metodo(i));

    dadosresumo{i,2}=sprintf('%.3f',resumocampo.ErroMedio(i));

    dadosresumo{i,3}=sprintf('%.3f',resumocampo.Desvio(i));

    dadosresumo{i,4}=sprintf('%.3f',resumocampo.MAE(i));

    dadosresumo{i,5}=sprintf('%.3f',resumocampo.RMSE(i));

    dadosresumo{i,6}=sprintf('%.3f',resumocampo.ErroMaximo(i));

end

tabela2=uitable(fig2);

tabela2.Data=dadosresumo;

tabela2.ColumnName={'Método','Erro médio (dB)','Desvio (dB)','MAE (dB)','RMSE (dB)','Erro máximo (dB)'};

tabela2.RowName=[];

tabela2.FontSize=12;

tabela2.Position=[30 30 940 210];

tabela2.ColumnWidth={170 140 130 120 120 150};

annotation(fig2,'textbox',[0.02 0.82 0.96 0.10],'String','Desempenho nos 12 casos de validação em campo','HorizontalAlignment','center','VerticalAlignment','middle','FontSize',18,'FontWeight','bold','EdgeColor','none');

%% Salvar resumo

exportgraphics(fig2,fullfile(pastasaida,'TabelaResumoOriginal.png'),'Resolution',300);

%% Mostrar resumo final

fprintf('\n')
fprintf('====================================================\n')
fprintf('IMPLEMENTACAO ORIGINAL SEM FILTRO\n')
fprintf('====================================================\n')
fprintf('MAE contra medido: %.3f dB\n',maeoriginal)
fprintf('RMSE contra medido: %.3f dB\n',rmseoriginal)
fprintf('Erro medio contra medido: %.3f dB\n',biasoriginal)
fprintf('Erro maximo contra medido: %.3f dB\n',maxoriginal)
fprintf('\n')
fprintf('MAE direto contra Lorenco: %.3f dB\n',maecomparacao)
fprintf('RMSE direto contra Lorenco: %.3f dB\n',rmsecomparacao)
fprintf('Erro medio direto contra Lorenco: %.3f dB\n',biascomparacao)
fprintf('\n')
fprintf('Gumes Lorenco: %d\n',totalgumeslorenco)
fprintf('Gumes original: %d\n',totalgumesoriginal)
fprintf('Casos com mesma quantidade de gumes: %d de 12\n',acertosgumes)
fprintf('Erro total de quantidade de gumes: %d\n',errototalgumes)
fprintf('====================================================\n')

fprintf('\n')
fprintf('Resultados salvos em:\n')
fprintf('%s\n',pastasaida)