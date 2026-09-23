clear
clc
close all

%% Definir caminhos

pastateste=fileparts(mfilename('fullpath'));

pastascripts=fileparts(pastateste);

addpath(fullfile(pastascripts,'Funções'))

pastaperfis=fullfile(pastascripts,'DadosSalvos','DadosConclusao');

pastasaida=fullfile(pastateste,'ResultadosVarredura12Casos');

if exist(pastasaida,'dir')==0
    mkdir(pastasaida)
end

%% Conferir função de preparação geométrica

if exist('preparageometria','file')~=2
    error('A função preparageometria não foi encontrada.')
end

%% Definir dados gerais

freq=[557.142857*10^6 581.142857*10^6];

alturat=[76.2 113];

alturar=1.5;

%% Definir coordenadas das transmissoras

lattx=[-18.885 -18.8825];

lontx=[-48.25833 -48.25083];

%% Definir coordenadas dos receptores

latrx=[-18.865 -18.88917 -18.87167 -18.98833 -18.95861 -18.975];

lonrx=[-48.21833 -48.21194 -48.30944 -48.275 -48.32167 -48.37639];

%% Definir distâncias apresentadas por Lorenço

distancias=[4.76007 4.90242 5.57821 11.62309 10.55351 15.94797;
            3.93443 4.15807 6.28328 12.03950 11.27558 16.73901];

%% Definir ERP em cada ponto

erp=[0.05631 1.49906 5.09155 3.01382 3.23998 2.12244;
     0.32496 1.13006 3.22440 3.14907 3.08243 3.10165];

%% Definir campo calculado por Giovaneli apresentado por Lorenço

campogiolorenco=[60.90812 68.02893 68.38195 65.51763 69.00870 69.05509;
                  77.91189 78.03863 71.02870 67.12174 66.92914 75.73337];

%% Definir valores medidos

medido=[64.6 65.3 67.3 64.1 66.9 65.7;
        78.9 78.3 72.0 64.5 66.8 65.0];

%% Definir quantidade de gumes apresentada por Lorenço

gumeslorenco=[3 3 4 3 3 2;
              2 2 3 3 3 1];

%% Preparar vetores

quantidade=12;

casos=strings(quantidade,1);

emissoravetor=zeros(quantidade,1);

pontovetor=zeros(quantidade,1);

freqvetor=zeros(quantidade,1);

alturatvetor=zeros(quantidade,1);

distanciasvetor=zeros(quantidade,1);

erpvetor=zeros(quantidade,1);

campogiolorencovetor=zeros(quantidade,1);

medidovetor=zeros(quantidade,1);

gumeslorencovetor=zeros(quantidade,1);

%% Preparar estruturas dos perfis

relevos=cell(quantidade,1);

indicessemfresnel=cell(quantidade,1);

indicescomfresnel=cell(quantidade,1);

geometriasemfresnel=cell(quantidade,1);

geometriacomfresnel=cell(quantidade,1);

%% Preparar resultados originais

gumessemfresnel=zeros(quantidade,1);

gumescomfresnel=zeros(quantidade,1);

perdasemfresnel=zeros(quantidade,1);

perdacomfresnel=zeros(quantidade,1);

campolivre=zeros(quantidade,1);

camposemfresnel=zeros(quantidade,1);

campocomfresnel=zeros(quantidade,1);

distanciaperfil=zeros(quantidade,1);

%% Iniciar preparação

fprintf('\n')
fprintf('============================================================\n')
fprintf('PREPARAÇÃO DOS 12 CASOS REAIS\n')
fprintf('============================================================\n')
fprintf('Perfis: %s\n',pastaperfis)
fprintf('Saída: %s\n',pastasaida)
fprintf('============================================================\n\n')

tic

linha=0;

wgs84=wgs84Ellipsoid("m");

%% Processar os 12 casos

for emissora=1:2

    for ponto=1:6

        linha=linha+1;

        %% Identificar caso

        casos(linha)="E"+string(emissora)+"-P"+string(ponto);

        emissoravetor(linha)=emissora;

        pontovetor(linha)=ponto;

        freqvetor(linha)=freq(emissora);

        alturatvetor(linha)=alturat(emissora);

        distanciasvetor(linha)=distancias(emissora,ponto);

        erpvetor(linha)=erp(emissora,ponto);

        campogiolorencovetor(linha)=campogiolorenco(emissora,ponto);

        medidovetor(linha)=medido(emissora,ponto);

        gumeslorencovetor(linha)=gumeslorenco(emissora,ponto);

        %% Carregar perfil

        nomearquivo=['DadosConclusaoE' num2str(emissora) 'P' num2str(ponto) '.mat'];

        caminhoarquivo=fullfile(pastaperfis,nomearquivo);

        if exist(caminhoarquivo,'file')~=2
            error(['Perfil não encontrado: ' caminhoarquivo])
        end

        dadosarquivo=load(caminhoarquivo,'dadoselev');

        if isfield(dadosarquivo,'dadoselev')==false
            error(['A variável dadoselev não foi encontrada em ' nomearquivo])
        end

        dadoselev=dadosarquivo.dadoselev;

        %% Conferir perfil

        if size(dadoselev,1)~=3
            error(['O perfil ' char(casos(linha)) ' não possui 3 linhas.'])
        end

        if any(isfinite(dadoselev(:))==false)
            error(['O perfil ' char(casos(linha)) ' possui NaN ou Inf.'])
        end

        %% Conferir transmissor

        if abs(dadoselev(1,1)-lattx(emissora))>1e-4 || abs(dadoselev(2,1)-lontx(emissora))>1e-4
            error(['Coordenada Tx incorreta no perfil ' char(casos(linha))])
        end

        %% Conferir receptor

        if abs(dadoselev(1,end)-latrx(ponto))>1e-4 || abs(dadoselev(2,end)-lonrx(ponto))>1e-4
            error(['Coordenada Rx incorreta no perfil ' char(casos(linha))])
        end

        %% Calcular distância horizontal do perfil

        distanciaatual=0;

        for i=2:size(dadoselev,2)

            distanciaatual=distanciaatual+distance(dadoselev(1,i-1),dadoselev(2,i-1),dadoselev(1,i),dadoselev(2,i),wgs84);

        end

        distanciaperfil(linha)=distanciaatual/1000;

        %% Aplicar correção do raio efetivo

        dadoselev=raioefetivo(dadoselev);

        relevos{linha}=dadoselev;

        %% Identificar gumes sem Fresnel

        [indexgumes,gumes]=indexgumess(dadoselev,alturat(emissora),alturar,freq(emissora),false);

        indicessemfresnel{linha}=indexgumes;

        gumessemfresnel(linha)=gumes;

        geometriasemfresnel{linha}=preparageometria(indexgumes,dadoselev,alturat(emissora),alturar,freq(emissora));

        perda=perdagiovaneli(indexgumes,dadoselev,freq(emissora),gumes,alturar,alturat(emissora));

        perdasemfresnel(linha)=-perda;

        %% Identificar gumes com Fresnel

        [indexgumes,gumes]=indexgumess(dadoselev,alturat(emissora),alturar,freq(emissora),true);

        indicescomfresnel{linha}=indexgumes;

        gumescomfresnel(linha)=gumes;

        geometriacomfresnel{linha}=preparageometria(indexgumes,dadoselev,alturat(emissora),alturar,freq(emissora));

        perda=perdagiovaneli(indexgumes,dadoselev,freq(emissora),gumes,alturar,alturat(emissora));

        perdacomfresnel(linha)=-perda;

        %% Calcular campo sem difração

        campolivre(linha)=100+10*log10((4.92*erpvetor(linha))/(distanciasvetor(linha)^2));

        %% Calcular campos com difração

        camposemfresnel(linha)=campolivre(linha)-perdasemfresnel(linha);

        campocomfresnel(linha)=campolivre(linha)-perdacomfresnel(linha);

        %% Mostrar progresso

        fprintf('%5s | Sem Fresnel: %2d | Com Fresnel: %2d | Lorenço: %2d\n',char(casos(linha)),gumessemfresnel(linha),gumescomfresnel(linha),gumeslorencovetor(linha))

    end

end

tempo=toc;

%% Calcular perda equivalente de Giovaneli de Lorenço

perdalorenco=campolivre-campogiolorencovetor;

%% Calcular diferenças de quantidade de gumes

difgumessemfresnel=gumessemfresnel-gumeslorencovetor;

difgumescomfresnel=gumescomfresnel-gumeslorencovetor;

%% Calcular erros contra medição

errolorencomedido=campogiolorencovetor-medidovetor;

errosemfresnelmedido=camposemfresnel-medidovetor;

errocomfresnelmedido=campocomfresnel-medidovetor;

%% Calcular erros contra Lorenço

errosemfresnellorenco=camposemfresnel-campogiolorencovetor;

errocomfresnellorenco=campocomfresnel-campogiolorencovetor;

%% Calcular diferenças entre distâncias

diferencadistancia=distanciaperfil-distanciasvetor;

%% Calcular métricas de Lorenço contra medição

biaslorenco=mean(errolorencomedido);

desviolorenco=std(errolorencomedido,1);

maelorenco=mean(abs(errolorencomedido));

rmselorenco=sqrt(mean(errolorencomedido.^2));

maxlorenco=max(abs(errolorencomedido));

%% Calcular métricas sem Fresnel contra medição

biassem=mean(errosemfresnelmedido);

desviosem=std(errosemfresnelmedido,1);

maesem=mean(abs(errosemfresnelmedido));

rmsesem=sqrt(mean(errosemfresnelmedido.^2));

maxsem=max(abs(errosemfresnelmedido));

%% Calcular métricas com Fresnel contra medição

biascom=mean(errocomfresnelmedido);

desviocom=std(errocomfresnelmedido,1);

maecom=mean(abs(errocomfresnelmedido));

rmsecom=sqrt(mean(errocomfresnelmedido.^2));

maxcom=max(abs(errocomfresnelmedido));

%% Calcular métricas sem Fresnel contra Lorenço

biassemlorenco=mean(errosemfresnellorenco);

desviosemlorenco=std(errosemfresnellorenco,1);

maesemlorenco=mean(abs(errosemfresnellorenco));

rmsesemlorenco=sqrt(mean(errosemfresnellorenco.^2));

maxsemlorenco=max(abs(errosemfresnellorenco));

%% Calcular métricas com Fresnel contra Lorenço

biascomlorenco=mean(errocomfresnellorenco);

desviocomlorenco=std(errocomfresnellorenco,1);

maecomlorenco=mean(abs(errocomfresnellorenco));

rmsecomlorenco=sqrt(mean(errocomfresnellorenco.^2));

maxcomlorenco=max(abs(errocomfresnellorenco));

%% Calcular métricas de gumes sem Fresnel

totalgumeslorenco=sum(gumeslorencovetor);

totalgumessem=sum(gumessemfresnel);

acertosgumessem=sum(difgumessemfresnel==0);

errototalgumessem=sum(abs(difgumessemfresnel));

casosacimasem=sum(difgumessemfresnel>0);

casosiguaissem=sum(difgumessemfresnel==0);

casosabaixosem=sum(difgumessemfresnel<0);

%% Calcular métricas de gumes com Fresnel

totalgumescom=sum(gumescomfresnel);

acertosgumescom=sum(difgumescomfresnel==0);

errototalgumescom=sum(abs(difgumescomfresnel));

casosacimacom=sum(difgumescomfresnel>0);

casosiguaiscom=sum(difgumescomfresnel==0);

casosabaixocom=sum(difgumescomfresnel<0);

%% Criar tabela completa

base=table(casos,emissoravetor,pontovetor,freqvetor,alturatvetor,distanciasvetor,distanciaperfil,diferencadistancia,erpvetor,campolivre,medidovetor,campogiolorencovetor,perdalorenco,gumeslorencovetor,gumessemfresnel,difgumessemfresnel,perdasemfresnel,camposemfresnel,errosemfresnelmedido,errosemfresnellorenco,gumescomfresnel,difgumescomfresnel,perdacomfresnel,campocomfresnel,errocomfresnelmedido,errocomfresnellorenco);

base.Properties.VariableNames={'Caso','Emissora','Ponto','FrequenciaHz','AlturaTx','DistanciaLorenco_km','DistanciaPerfil_km','DiferencaDistancia_km','ERP_kW','CampoLivre','CampoMedido','CampoGiovaneliLorenco','PerdaGiovaneliLorenco','GumesLorenco','GumesSemFresnel','DiferencaGumesSemFresnel','PerdaGiovaneliSemFresnel','CampoSemFresnel','ErroSemFresnelMedido','ErroSemFresnelLorenco','GumesComFresnel','DiferencaGumesComFresnel','PerdaGiovaneliComFresnel','CampoComFresnel','ErroComFresnelMedido','ErroComFresnelLorenco'};

%% Criar resumo contra medição real

metodo=["Lorenço";"Lucas sem Fresnel";"Lucas com Fresnel"];

bias=[biaslorenco;biassem;biascom];

desvio=[desviolorenco;desviosem;desviocom];

mae=[maelorenco;maesem;maecom];

rmse=[rmselorenco;rmsesem;rmsecom];

erromaximo=[maxlorenco;maxsem;maxcom];

resumomedido=table(metodo,bias,desvio,mae,rmse,erromaximo);

resumomedido.Properties.VariableNames={'Metodo','ErroMedio','Desvio','MAE','RMSE','ErroMaximo'};

%% Criar resumo contra Lorenço

metodo=["Lucas sem Fresnel";"Lucas com Fresnel"];

bias=[biassemlorenco;biascomlorenco];

desvio=[desviosemlorenco;desviocomlorenco];

mae=[maesemlorenco;maecomlorenco];

rmse=[rmsesemlorenco;rmsecomlorenco];

erromaximo=[maxsemlorenco;maxcomlorenco];

resumolorenco=table(metodo,bias,desvio,mae,rmse,erromaximo);

resumolorenco.Properties.VariableNames={'Metodo','ErroMedio','Desvio','MAE','RMSE','ErroMaximo'};

%% Criar resumo de gumes

metodo=["Sem Fresnel";"Com Fresnel"];

totalgumes=[totalgumessem;totalgumescom];

acertos=[acertosgumessem;acertosgumescom];

errototal=[errototalgumessem;errototalgumescom];

casosacima=[casosacimasem;casosacimacom];

casosiguais=[casosiguaissem;casosiguaiscom];

casosabaixo=[casosabaixosem;casosabaixocom];

resumogumes=table(metodo,totalgumes,acertos,errototal,casosacima,casosiguais,casosabaixo);

resumogumes.Properties.VariableNames={'Metodo','TotalGumes','AcertosExatos','ErroTotalGumes','CasosAcima','CasosIguais','CasosAbaixo'};

%% Mostrar tabela dos 12 casos

clc

fprintf('\n')
fprintf('=============================================================================================\n')
fprintf('PREPARAÇÃO DOS 12 CASOS REAIS CONCLUÍDA\n')
fprintf('=============================================================================================\n')
fprintf('Caso  |        Gumes         |             Campo calculado\n')
fprintf('      | Sem   Com   Lorenço  | Medido   Lorenço   Sem Fresnel   Com Fresnel\n')
fprintf('---------------------------------------------------------------------------------------------\n')

for i=1:quantidade

    fprintf('%5s | %3d   %3d      %3d   | %6.2f   %7.2f      %7.2f        %7.2f\n',char(casos(i)),gumessemfresnel(i),gumescomfresnel(i),gumeslorencovetor(i),medidovetor(i),campogiolorencovetor(i),camposemfresnel(i),campocomfresnel(i))

end

fprintf('=============================================================================================\n')

%% Mostrar resumo de gumes

fprintf('\n')
fprintf('============================================================\n')
fprintf('RESUMO DOS GUMES\n')
fprintf('============================================================\n')
fprintf('Total Lorenço: %d\n',totalgumeslorenco)
fprintf('------------------------------------------------------------\n')
fprintf('Sem Fresnel\n')
fprintf('Total calculado:       %d\n',totalgumessem)
fprintf('Acertos exatos:        %d de 12\n',acertosgumessem)
fprintf('Erro total de gumes:   %d\n',errototalgumessem)
fprintf('Casos acima:           %d\n',casosacimasem)
fprintf('Casos iguais:          %d\n',casosiguaissem)
fprintf('Casos abaixo:          %d\n',casosabaixosem)
fprintf('------------------------------------------------------------\n')
fprintf('Com Fresnel\n')
fprintf('Total calculado:       %d\n',totalgumescom)
fprintf('Acertos exatos:        %d de 12\n',acertosgumescom)
fprintf('Erro total de gumes:   %d\n',errototalgumescom)
fprintf('Casos acima:           %d\n',casosacimacom)
fprintf('Casos iguais:          %d\n',casosiguaiscom)
fprintf('Casos abaixo:          %d\n',casosabaixocom)
fprintf('============================================================\n')

%% Mostrar resumo contra campo medido

fprintf('\n')
fprintf('================================================================================================\n')
fprintf('COMPARAÇÃO COM O CAMPO REALMENTE MEDIDO\n')
fprintf('================================================================================================\n')
fprintf('Método                 Erro médio     Desvio       MAE       RMSE     Erro máximo\n')
fprintf('------------------------------------------------------------------------------------------------\n')
fprintf('Lorenço                 %+8.3f     %8.3f   %8.3f   %8.3f      %8.3f\n',biaslorenco,desviolorenco,maelorenco,rmselorenco,maxlorenco)
fprintf('Lucas sem Fresnel       %+8.3f     %8.3f   %8.3f   %8.3f      %8.3f\n',biassem,desviosem,maesem,rmsesem,maxsem)
fprintf('Lucas com Fresnel       %+8.3f     %8.3f   %8.3f   %8.3f      %8.3f\n',biascom,desviocom,maecom,rmsecom,maxcom)
fprintf('================================================================================================\n')

%% Mostrar resumo contra Lorenço

fprintf('\n')
fprintf('================================================================================================\n')
fprintf('COMPARAÇÃO DIRETA COM O CAMPO CALCULADO POR LORENÇO\n')
fprintf('================================================================================================\n')
fprintf('Método                 Erro médio     Desvio       MAE       RMSE     Erro máximo\n')
fprintf('------------------------------------------------------------------------------------------------\n')
fprintf('Lucas sem Fresnel       %+8.3f     %8.3f   %8.3f   %8.3f      %8.3f\n',biassemlorenco,desviosemlorenco,maesemlorenco,rmsesemlorenco,maxsemlorenco)
fprintf('Lucas com Fresnel       %+8.3f     %8.3f   %8.3f   %8.3f      %8.3f\n',biascomlorenco,desviocomlorenco,maecomlorenco,rmsecomlorenco,maxcomlorenco)
fprintf('================================================================================================\n')

%% Salvar resultados

writetable(base,fullfile(pastasaida,'BasePreparacao12Casos.csv'));

writetable(resumomedido,fullfile(pastasaida,'ResumoMedidoPreparacao12Casos.csv'));

writetable(resumolorenco,fullfile(pastasaida,'ResumoLorencoPreparacao12Casos.csv'));

writetable(resumogumes,fullfile(pastasaida,'ResumoGumesPreparacao12Casos.csv'));

save(fullfile(pastasaida,'PreparacaoVarredura12Casos.mat'),'relevos','indicessemfresnel','indicescomfresnel','geometriasemfresnel','geometriacomfresnel','gumessemfresnel','gumescomfresnel','perdasemfresnel','perdacomfresnel','campolivre','camposemfresnel','campocomfresnel','perdalorenco','casos','emissoravetor','pontovetor','freqvetor','alturatvetor','alturar','distanciasvetor','distanciaperfil','erpvetor','campogiolorencovetor','medidovetor','gumeslorencovetor','lattx','lontx','latrx','lonrx','-v7.3');

%% Mostrar finalização

fprintf('\n')
fprintf('Tempo de preparação: %.2f s\n',tempo)
fprintf('\n')
fprintf('Arquivos salvos em:\n')
fprintf('%s\n',pastasaida)