clear
clc
close all

%% Definir caminhos

pastateste=fileparts(mfilename('fullpath'));

pastascripts=fileparts(pastateste);

addpath(fullfile(pastascripts,'Funções'))

pastarelevos=fullfile(pastascripts,'DadosSalvos','RelevosLorenco85');

pastasaida=fullfile(pastateste,'ResultadosTesteVerificaFresnel85');

if exist(pastasaida,'dir')==0
    mkdir(pastasaida)
end

%% Conferir caminhos

if exist(pastarelevos,'dir')~=7
    error('A pasta RelevosLorenco85 não foi encontrada.')
end

if exist('verificafresnel','file')~=2
    error('A função verificafresnel não foi encontrada.')
end

%% Definir parâmetros

freq=575.142857*10^6;

lambda=(3*10^8)/freq;

alturat=10;

alturar=10;

quantidade=85;

%% Definir gráfico

casografico=1;

% Use 0 para selecionar automaticamente o trecho
% com maior invasão da zona de Fresnel.
segmentografico=0;

salvarcsv=true;

%% Preparar vetores gerais

casos=[];

segmentos=[];

pontosiniciais=[];

pontosfinais=[];

indicesfresnelatual=[];

indicesfresnelindependente=[];

quantidadeobstrucoes=[];

maximainvasao=[];

vmaximo=[];

coincidencia=[];

gumessemfresnel=zeros(quantidade,1);

gumescomfresnel=zeros(quantidade,1);

fresneladicionados=zeros(quantidade,1);

integracaocorreta=false(quantidade,1);

%% Iniciar teste

fprintf('\n')
fprintf('====================================================================\n')
fprintf('TESTE DA FUNÇÃO VERIFICAFRESNEL\n')
fprintf('====================================================================\n')
fprintf('Perfis: %d\n',quantidade)
fprintf('Frequência: %.6f MHz\n',freq/10^6)
fprintf('Altura Tx: %.2f m\n',alturat)
fprintf('Altura Rx: %.2f m\n',alturar)
fprintf('Zona analisada: 60%% da primeira zona de Fresnel\n')
fprintf('====================================================================\n\n')

tic

wgs84=wgs84Ellipsoid("m");

%% Testar todos os casos

for caso=1:quantidade

    %% Carregar perfil

    nomearquivo=['DadosElevLorenco' num2str(caso) '.mat'];

    caminhoarquivo=fullfile(pastarelevos,nomearquivo);

    if exist(caminhoarquivo,'file')~=2
        error(['Arquivo não encontrado: ' nomearquivo])
    end

    dadosrelevo=load(caminhoarquivo,'dadoselev');

    dadoselev=dadosrelevo.dadoselev;

    %% Aplicar raio efetivo

    dadoselev=raioefetivo(dadoselev);

    n=size(dadoselev,2);

    %% Preparar alturas utilizadas pelo detector

    altura=dadoselev(3,:);

    altura(1)=altura(1)+alturat;

    altura(end)=altura(end)+alturar;

    %% Calcular distância acumulada

    distancia=zeros(1,n);

    for i=2:n

        distancia(i)=distancia(i-1)+distance(dadoselev(1,i-1),dadoselev(2,i-1),dadoselev(1,i),dadoselev(2,i),wgs84);

    end

    %% Identificar gumes apenas pelo horizonte móvel

    [indexhorizonte,gumesnormal]=indexgumess(dadoselev,alturat,alturar,freq,false);

    gumessemfresnel(caso)=gumesnormal;

    %% Identificar gumes com Fresnel

    [indexcomfresnel,gumesfresnel]=indexgumess(dadoselev,alturat,alturar,freq,true);

    gumescomfresnel(caso)=gumesfresnel;

    %% Calcular quantidade de pontos adicionados por Fresnel

    indicesnovos=setdiff(indexcomfresnel,indexhorizonte,'stable');

    fresneladicionados(caso)=length(indicesnovos);

    %% Construir trechos analisados pelo algoritmo

    pontosinicio=[1 indexhorizonte];

    pontosfim=[indexhorizonte n];

    quantidadesegmentos=length(pontosinicio);

    %% Reconstruir manualmente o resultado final

    indicesreconstruidos=[];

    for segmento=1:quantidadesegmentos

        ponto1=pontosinicio(segmento);

        ponto2=pontosfim(segmento);

        %% Executar função atual

        indiceatual=verificafresnel(altura,distancia,ponto1,ponto2,lambda);

        if isempty(indiceatual)==true

            indiceatualnumerico=0;

        else

            indiceatualnumerico=indiceatual;

        end

        %% Executar verificação independente

        [indiceindependente,obstrucoessegmento,invasao,vsegmento]=verificafresnelindependente(altura,distancia,ponto1,ponto2,lambda);

        if isempty(indiceindependente)==true

            indiceindependentenumerico=0;

        else

            indiceindependentenumerico=indiceindependente;

        end

        %% Comparar resultados

        igual=indiceatualnumerico==indiceindependentenumerico;

        %% Armazenar resultados

        casos=[casos;caso];

        segmentos=[segmentos;segmento];

        pontosiniciais=[pontosiniciais;ponto1];

        pontosfinais=[pontosfinais;ponto2];

        indicesfresnelatual=[indicesfresnelatual;indiceatualnumerico];

        indicesfresnelindependente=[indicesfresnelindependente;indiceindependentenumerico];

        quantidadeobstrucoes=[quantidadeobstrucoes;obstrucoessegmento];

        maximainvasao=[maximainvasao;invasao];

        vmaximo=[vmaximo;vsegmento];

        coincidencia=[coincidencia;igual];

        %% Reconstruir ordem da indexgumess

        if isempty(indiceatual)==false

            indicesreconstruidos=[indicesreconstruidos indiceatual];

        end

        %% Adicionar horizonte quando não for o trecho final

        if segmento<=length(indexhorizonte)

            indicesreconstruidos=[indicesreconstruidos ponto2];

        end

    end

    indicesreconstruidos=unique(indicesreconstruidos,'stable');

    %% Comparar reconstrução com indexgumess completa

    integracaocorreta(caso)=isequal(indicesreconstruidos,indexcomfresnel);

    fprintf('Caso %2d | Sem Fresnel: %2d | Com Fresnel: %2d | Novos: %2d | Integração: %d\n',caso,gumesnormal,gumesfresnel,fresneladicionados(caso),integracaocorreta(caso))

end

tempo=toc;

%% Criar tabela dos segmentos

resultado=table(casos,segmentos,pontosiniciais,pontosfinais,indicesfresnelatual,indicesfresnelindependente,quantidadeobstrucoes,maximainvasao,vmaximo,coincidencia);

resultado.Properties.VariableNames={'Caso','Segmento','PontoInicial','PontoFinal','IndiceVerificaFresnel','IndiceIndependente','PontosObstruindo60Fresnel','MaximaInvasao_m','VMaximo','Coincide'};

%% Calcular métricas gerais

totalsegmentos=height(resultado);

segmentoscomfresnel=sum(indicesfresnelatual>0);

segmentossemfresnel=sum(indicesfresnelatual==0);

segmentoscoincidentes=sum(coincidencia);

segmentosdiferentes=sum(coincidencia==false);

casosintegracaocorreta=sum(integracaocorreta);

totalgumessem=sum(gumessemfresnel);

totalgumescom=sum(gumescomfresnel);

totaladicionados=sum(fresneladicionados);

%% Mostrar resumo

fprintf('\n')
fprintf('====================================================================\n')
fprintf('RESUMO DO TESTE\n')
fprintf('====================================================================\n')
fprintf('Segmentos analisados:                       %d\n',totalsegmentos)
fprintf('Segmentos com ponto Fresnel:                %d\n',segmentoscomfresnel)
fprintf('Segmentos sem ponto Fresnel:                %d\n',segmentossemfresnel)
fprintf('Função atual = teste independente:          %d de %d\n',segmentoscoincidentes,totalsegmentos)
fprintf('Diferenças encontradas:                     %d\n',segmentosdiferentes)
fprintf('--------------------------------------------------------------------\n')
fprintf('Casos com integração indexgumess correta:   %d de %d\n',casosintegracaocorreta,quantidade)
fprintf('--------------------------------------------------------------------\n')
fprintf('Gumes totais sem Fresnel:                   %d\n',totalgumessem)
fprintf('Gumes totais com Fresnel:                   %d\n',totalgumescom)
fprintf('Pontos adicionais únicos por Fresnel:       %d\n',totaladicionados)
fprintf('--------------------------------------------------------------------\n')
fprintf('Tempo de execução:                          %.2f s\n',tempo)
fprintf('====================================================================\n')

%% Mostrar diferenças

if segmentosdiferentes>0

    fprintf('\n')
    fprintf('ATENÇÃO: foram encontradas diferenças entre os dois métodos.\n')
    fprintf('Os segmentos abaixo devem ser analisados visualmente:\n\n')

    disp(resultado(coincidencia==false,:))

else

    fprintf('\n')
    fprintf('Nenhuma diferença foi encontrada entre a função atual e o teste independente.\n')

end

%% Verificar integração com indexgumess

if casosintegracaocorreta<quantidade

    fprintf('\n')
    fprintf('ATENÇÃO: houve diferença na reconstrução da indexgumess nos casos:\n')

    disp(find(integracaocorreta==false)')

else

    fprintf('\n')
    fprintf('A sequência Fresnel + horizonte reproduziu a indexgumess em todos os casos.\n')

end

%% Salvar resultados

if salvarcsv==true

    writetable(resultado,fullfile(pastasaida,'TesteVerificaFresnel.csv'));

    resumocasos=table((1:quantidade)',gumessemfresnel,gumescomfresnel,fresneladicionados,integracaocorreta);

    resumocasos.Properties.VariableNames={'Caso','GumesSemFresnel','GumesComFresnel','FresnelAdicionados','IntegracaoCorreta'};

    writetable(resumocasos,fullfile(pastasaida,'ResumoTesteVerificaFresnel.csv'));

end

%% Mostrar gráfico do caso escolhido

if casografico<1 || casografico>quantidade
    error('casografico deve estar entre 1 e 85.')
end

%% Carregar novamente o caso escolhido

nomearquivo=['DadosElevLorenco' num2str(casografico) '.mat'];

caminhoarquivo=fullfile(pastarelevos,nomearquivo);

dadosrelevo=load(caminhoarquivo,'dadoselev');

dadoselev=dadosrelevo.dadoselev;

dadoselev=raioefetivo(dadoselev);

n=size(dadoselev,2);

altura=dadoselev(3,:);

alturaantena=altura;

alturaantena(1)=alturaantena(1)+alturat;

alturaantena(end)=alturaantena(end)+alturar;

%% Calcular distância

distancia=zeros(1,n);

for i=2:n

    distancia(i)=distancia(i-1)+distance(dadoselev(1,i-1),dadoselev(2,i-1),dadoselev(1,i),dadoselev(2,i),wgs84);

end

distanciakm=distancia/1000;

%% Identificar gumes

[indexsem,gumessem]=indexgumess(dadoselev,alturat,alturar,freq,false);

[indexcom,gumescom]=indexgumess(dadoselev,alturat,alturar,freq,true);

indicesfresnel=setdiff(indexcom,indexsem,'stable');

%% Mostrar perfil geral

figure

hold on
grid on

plot(distanciakm,altura,'k','LineWidth',1.5)

plot([distanciakm(1) distanciakm(1)],[altura(1) alturaantena(1)],'r','LineWidth',2)

plot([distanciakm(end) distanciakm(end)],[altura(end) alturaantena(end)],'b','LineWidth',2)

plot(distanciakm(1),alturaantena(1),'ro','MarkerFaceColor','r','MarkerSize',7)

plot(distanciakm(end),alturaantena(end),'bo','MarkerFaceColor','b','MarkerSize',7)

if isempty(indexsem)==false

    plot(distanciakm(indexsem),altura(indexsem),'ko','MarkerFaceColor','k','MarkerSize',6)

end

if isempty(indicesfresnel)==false

    plot(distanciakm(indicesfresnel),altura(indicesfresnel),'rs','MarkerFaceColor','r','MarkerSize',7)

end

xlabel('Distância (km)')

ylabel('Elevação (m)')

title(['Caso ' num2str(casografico) ' | Sem Fresnel: ' num2str(gumessem) ' | Com Fresnel: ' num2str(gumescom)])

legend('Terreno','Tx','Rx','Topo Tx','Topo Rx','Gumes de horizonte','Gumes adicionais por Fresnel','Location','best')

fontsize(16,"points");

%% Mostrar segmentos do caso escolhido

linhascaso=find(casos==casografico);

resultadocaso=resultado(linhascaso,:);

fprintf('\n')
fprintf('====================================================================\n')
fprintf('SEGMENTOS DO CASO %d\n',casografico)
fprintf('====================================================================\n')

disp(resultadocaso)

%% Selecionar segmento para o gráfico detalhado

if segmentografico==0

    valores=resultadocaso.MaximaInvasao_m;

    valores(isnan(valores))=-Inf;

    [~,segmentografico]=max(valores);

end

if segmentografico<1 || segmentografico>height(resultadocaso)
    error('segmentografico inválido para o caso escolhido.')
end

ponto1=resultadocaso.PontoInicial(segmentografico);

ponto2=resultadocaso.PontoFinal(segmentografico);

indiceatual=resultadocaso.IndiceVerificaFresnel(segmentografico);

indiceindependente=resultadocaso.IndiceIndependente(segmentografico);

%% Calcular geometria detalhada do trecho

[~,~,~,~,dadosgrafico]=verificafresnelindependente(alturaantena,distancia,ponto1,ponto2,lambda);

%% Mostrar gráfico detalhado

figure

hold on
grid on

indicesperfil=ponto1:ponto2;

plot(distanciakm(indicesperfil),alturaantena(indicesperfil),'k','LineWidth',1.5)

plot(dadosgrafico.xlos/1000,dadosgrafico.hlos,'k--','LineWidth',1.2)

plot(dadosgrafico.xfresnel/1000,dadosgrafico.hfresnel,'b--','LineWidth',1.5)

if isempty(dadosgrafico.indicesobstruidos)==false

    plot(distanciakm(dadosgrafico.indicesobstruidos),alturaantena(dadosgrafico.indicesobstruidos),'ko','MarkerFaceColor','k','MarkerSize',5)

end

if indiceatual>0

    plot(distanciakm(indiceatual),alturaantena(indiceatual),'rs','MarkerFaceColor','r','MarkerSize',9)

end

if indiceindependente>0

    plot(distanciakm(indiceindependente),alturaantena(indiceindependente),'bo','MarkerSize',10,'LineWidth',1.5)

end

xlabel('Distância (km)')

ylabel('Elevação (m)')

title(['Caso ' num2str(casografico) ' | Segmento ' num2str(segmentografico) ' | Índices ' num2str(ponto1) ' a ' num2str(ponto2)])

legend('Terreno','Linha de visada','Limite inferior de 60% de Fresnel','Pontos que invadem a zona','verificafresnel atual','Teste independente','Location','best')

fontsize(16,"points");

%% Mostrar informações do segmento

fprintf('\n')
fprintf('====================================================================\n')
fprintf('SEGMENTO MOSTRADO NO GRÁFICO\n')
fprintf('====================================================================\n')
fprintf('Caso:                         %d\n',casografico)
fprintf('Segmento:                     %d\n',segmentografico)
fprintf('Ponto inicial:                %d\n',ponto1)
fprintf('Ponto final:                  %d\n',ponto2)
fprintf('Pontos invadindo 60%% Fresnel: %d\n',resultadocaso.PontosObstruindo60Fresnel(segmentografico))
fprintf('Máxima invasão:               %.6f m\n',resultadocaso.MaximaInvasao_m(segmentografico))
fprintf('Índice verificafresnel:       %d\n',indiceatual)
fprintf('Índice independente:          %d\n',indiceindependente)
fprintf('v máximo independente:        %.6f\n',resultadocaso.VMaximo(segmentografico))
fprintf('Coincidem:                    %d\n',resultadocaso.Coincide(segmentografico))
fprintf('====================================================================\n')

%% Verificação independente da zona de Fresnel

function [indicefresnel,quantidadeobstrucoes,maximainvasao,vmaximo,dadosgrafico]=verificafresnelindependente(altura,distancia,ponto1,ponto2,lambda)

indicefresnel=[];

quantidadeobstrucoes=0;

maximainvasao=NaN;

vmaximo=NaN;

dadosgrafico=struct;

x1=distancia(ponto1);

x2=distancia(ponto2);

h1=altura(ponto1);

h2=altura(ponto2);

D=x2-x1;

if D<=0

    return

end

d=sqrt(D^2+(h2-h1)^2);

theta=atan2(h2-h1,D);

%% Calcular linha e zona de Fresnel para o gráfico

splot=linspace(0,d,1000);

raioplot=0.6*sqrt(lambda*splot.*(d-splot)./d);

xlos=x1+splot.*cos(theta);

hlos=h1+splot.*sin(theta);

xfresnel=x1+splot.*cos(theta)+raioplot.*sin(theta);

hfresnel=h1+splot.*sin(theta)-raioplot.*cos(theta);

dadosgrafico.xlos=xlos;

dadosgrafico.hlos=hlos;

dadosgrafico.xfresnel=xfresnel;

dadosgrafico.hfresnel=hfresnel;

dadosgrafico.indicesobstruidos=[];

%% Verificar existência de pontos internos

if ponto2-ponto1<=1

    return

end

indices=ponto1+1:ponto2-1;

quantidadepontos=length(indices);

margens=zeros(1,quantidadepontos);

valoresv=nan(1,quantidadepontos);

validos=false(1,quantidadepontos);

%% Analisar pontos em coordenadas locais da linha de visada

for i=1:quantidadepontos

    indice=indices(i);

    dx=distancia(indice)-x1;

    dz=altura(indice)-h1;

    %% Calcular projeção ao longo da linha Tx-Rx

    s=dx*cos(theta)+dz*sin(theta);

    %% Calcular distância perpendicular assinada à linha

    hperpendicular=-dx*sin(theta)+dz*cos(theta);

    if s<=0 || s>=d

        margens(i)=-Inf;

        continue

    end

    %% Calcular 60% da primeira zona de Fresnel

    raio=0.6*sqrt(lambda*s*(d-s)/d);

    %% Calcular margem em relação ao limite inferior da zona

    margem=hperpendicular+raio;

    margens(i)=margem;

    %% Verificar invasão

    if margem>=0

        validos(i)=true;

        d1f=s;

        d2f=d-s;

        valoresv(i)=hperpendicular*sqrt((2/lambda)*(1/d1f+1/d2f));

    end

end

%% Calcular maior invasão

if isempty(margens)==false

    margensfinitas=margens(isfinite(margens));

    if isempty(margensfinitas)==false

        maximainvasao=max(margensfinitas);

    end

end

%% Identificar pontos que invadem a zona

indicesobstruidos=indices(validos);

dadosgrafico.indicesobstruidos=indicesobstruidos;

quantidadeobstrucoes=length(indicesobstruidos);

if quantidadeobstrucoes==0

    return

end

%% Selecionar maior v

valoresvalidos=valoresv(validos);

[vmaximo,posicao]=max(valoresvalidos);

indicefresnel=indicesobstruidos(posicao);

end