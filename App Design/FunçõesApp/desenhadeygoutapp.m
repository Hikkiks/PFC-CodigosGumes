function desenhadeygoutapp(eixo,dadoselev,indexgumes,alturat,alturar,freq)

% Quantidade de amostras e gumes
amostras=size(dadoselev,2);

gumes=length(indexgumes);

lambda=(3*10^8)/freq;

% Cores utilizadas na representação do modelo
coresquerda=[0 0.6 0];

corcentral='b';

cordireita=[0.85 0.65 0];

% Criar perfil apenas para representação gráfica das antenas
dadoselevplot=dadoselev;

dadoselevplot(3,1)=dadoselevplot(3,1)+alturat;

dadoselevplot(3,end)=dadoselevplot(3,end)+alturar;

% Preparar eixo do aplicativo
legend(eixo,'off')

cla(eixo)

hold(eixo,"on")

grid(eixo,"on")

%% Relevo

hrelevo=plot(eixo,1:amostras,dadoselevplot(3,:),'k','LineWidth',2.5);

%% Construção Deygout

if gumes==0

    % Representar ligação direta entre Tx e Rx
    retacorte=linspace(dadoselevplot(3,1),dadoselevplot(3,end),amostras);

    plot(eixo,1:amostras,retacorte,'Color',corcentral,'LineWidth',2)

elseif gumes==1

    % Representar as construções para um único gume
    retacorte1=linspace(dadoselevplot(3,1),dadoselevplot(3,indexgumes(1)),indexgumes(1));

    retacorte2=linspace(dadoselevplot(3,indexgumes(1)),dadoselevplot(3,end),(amostras-indexgumes(1)+1));

    retacorte3=linspace(dadoselevplot(3,1),dadoselevplot(3,end),amostras);

    plot(eixo,1:indexgumes(1),retacorte1,'Color',corcentral,'LineWidth',2)

    plot(eixo,indexgumes(1):amostras,retacorte2,'Color',corcentral,'LineWidth',2)

    plot(eixo,1:amostras,retacorte3,'Color',corcentral,'LineWidth',2)

else

    % Calcular o parâmetro de difração de cada gume
    valoresv=zeros(1,length(indexgumes));

    for gume=1:1:length(indexgumes)

        d1=txrx(1,indexgumes(gume),alturat,0,dadoselev);

        d2=txrx(indexgumes(gume),amostras,0,alturar,dadoselev);

        d3=txrx(1,amostras,alturat,alturar,dadoselev);

        [hf,d1f,d2f]=valorcos(d1,d2,d3);

        % Conferir o sinal da altura relativa do gume
        hf=checarh(dadoselev(3,1)+alturat,dadoselev(3,end)+alturar,amostras,dadoselev(3,indexgumes(gume)),indexgumes(gume),hf);

        valoresv(gume)=fresnel(hf,d1f,d2f,lambda);

    end

    % Identificar o gume principal
    [~,indextemp]=min(valoresv);

    indexprincipal=indexgumes(indextemp);

    % Identificar referência do lado esquerdo
    if indextemp==1

        indexesq=1;

    else

        [~,indextemp1]=min(valoresv(1:(indextemp-1)));

        indexesq=indexgumes(indextemp1);

    end

    % Identificar referência do lado direito
    if indextemp==length(indexgumes)

        indexdir=amostras;

    else

        [~,indextemp2]=min(valoresv((indextemp+1):end));

        indextemp2=indextemp2+indextemp;

        indexdir=indexgumes(indextemp2);

    end

    %% Gume principal

    retacorte1=linspace(dadoselevplot(3,1),dadoselevplot(3,indexprincipal),indexprincipal);

    retacorte2=linspace(dadoselevplot(3,indexprincipal),dadoselevplot(3,end),(amostras-indexprincipal+1));

    retacorte3=linspace(dadoselevplot(3,1),dadoselevplot(3,end),amostras);

    %% Lado esquerdo

    retacorte4=linspace(dadoselevplot(3,1),dadoselevplot(3,indexesq),indexesq);

    retacorte5=linspace(dadoselevplot(3,indexesq),dadoselevplot(3,indexprincipal),(indexprincipal-indexesq+1));

    retacorte6=linspace(dadoselevplot(3,1),dadoselevplot(3,indexprincipal),indexprincipal);

    %% Lado direito

    retacorte7=linspace(dadoselevplot(3,indexprincipal),dadoselevplot(3,indexdir),(indexdir-indexprincipal+1));

    retacorte8=linspace(dadoselevplot(3,indexdir),dadoselevplot(3,end),(amostras-indexdir+1));

    retacorte9=linspace(dadoselevplot(3,indexprincipal),dadoselevplot(3,end),(amostras-indexprincipal+1));

    %% Desenho do gume principal

    plot(eixo,1:indexprincipal,retacorte1,'Color',corcentral,'LineWidth',2)

    plot(eixo,indexprincipal:amostras,retacorte2,'Color',corcentral,'LineWidth',2)

    plot(eixo,1:amostras,retacorte3,'Color',corcentral,'LineWidth',2)

    %% Desenho do lado esquerdo

    plot(eixo,1:indexesq,retacorte4,'Color',coresquerda,'LineWidth',2)

    plot(eixo,indexesq:indexprincipal,retacorte5,'Color',coresquerda,'LineWidth',2)

    plot(eixo,1:indexprincipal,retacorte6,'Color',coresquerda,'LineWidth',2)

    %% Desenho do lado direito

    plot(eixo,indexprincipal:indexdir,retacorte7,'Color',cordireita,'LineWidth',2)

    plot(eixo,indexdir:amostras,retacorte8,'Color',cordireita,'LineWidth',2)

    plot(eixo,indexprincipal:amostras,retacorte9,'Color',cordireita,'LineWidth',2)

end

%% Gumes

hgumes=desenhagumesapp(eixo,indexgumes,dadoselevplot(3,:));

%% Objetos utilizados somente na legenda

hesquerda=plot(eixo,nan,nan,'Color',coresquerda,'LineWidth',2);

hcentral=plot(eixo,nan,nan,'Color',corcentral,'LineWidth',2);

hdireita=plot(eixo,nan,nan,'Color',cordireita,'LineWidth',2);

%% Tx

plot(eixo,1,dadoselevplot(3,1),'ro','MarkerFaceColor','r','MarkerSize',6)

text(eixo,1,dadoselevplot(3,1)+2,'Tx')

%% Rx

plot(eixo,amostras,dadoselevplot(3,end),'bo','MarkerFaceColor','b','MarkerSize',6)

text(eixo,amostras,dadoselevplot(3,end)+2,'Rx')

%% Formatação

xlabel(eixo,'Índice')

ylabel(eixo,'Elevação (m)')

title(eixo,'Geometria Deygout')

eixo.FontSize=16;

eixo.LineWidth=1.5;

legend(eixo,[hrelevo hgumes hesquerda hcentral hdireita],{'Relevo','Gumes','Lado esquerdo','Gume principal','Lado direito'},'Location','best')

drawnow

end