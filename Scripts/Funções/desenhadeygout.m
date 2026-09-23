function desenhadeygout(dadoselev,indexgumes,alturat,alturar,freq)

%% Informações iniciais

amostras=size(dadoselev,2);

gumes=length(indexgumes);

lambda=(3*10^8)/freq;

coresquerda=[0 0.6 0];

corcentral='b';

cordireita=[0.85 0.65 0];

%% Preparar perfil para o desenho

dadosdesenho=dadoselev;

dadosdesenho(3,1)=dadosdesenho(3,1)+alturat;

dadosdesenho(3,end)=dadosdesenho(3,end)+alturar;

hold("on")

grid("on")

%% Desenhar relevo

hrelevo=plot(1:amostras,dadosdesenho(3,:),'k','LineWidth',2.5);

%% Criar objetos para legenda

hgumes=desenhagumes(indexgumes,dadosdesenho(3,:));

hesquerda=plot(nan,nan,'Color',coresquerda,'LineWidth',2);

hcentral=plot(nan,nan,'Color',corcentral,'LineWidth',2);

hdireita=plot(nan,nan,'Color',cordireita,'LineWidth',2);

%% Construir geometria de Deygout

if gumes==0

    retacorte=linspace(dadosdesenho(3,1),dadosdesenho(3,end),amostras);

    plot(1:amostras,retacorte,'Color',corcentral,'LineWidth',2,'HandleVisibility','off')

elseif gumes==1

    retacorte1=linspace(dadosdesenho(3,1),dadosdesenho(3,indexgumes(1)),indexgumes(1));

    retacorte2=linspace(dadosdesenho(3,indexgumes(1)),dadosdesenho(3,end),(amostras-indexgumes(1)+1));

    retacorte3=linspace(dadosdesenho(3,1),dadosdesenho(3,end),amostras);

    plot(1:amostras,retacorte3,'Color',corcentral,'LineWidth',2,'HandleVisibility','off')

    plot(1:indexgumes(1),retacorte1,'Color',corcentral,'LineWidth',2,'HandleVisibility','off')

    plot(indexgumes(1):amostras,retacorte2,'Color',corcentral,'LineWidth',2,'HandleVisibility','off')

else

    valoresv=zeros(1,length(indexgumes));

    %% Identificar gume principal

    for gume=1:1:length(indexgumes)

        d1=txrx(1,indexgumes(gume),alturat,0,dadoselev);

        d2=txrx(indexgumes(gume),amostras,0,alturar,dadoselev);

        d3=txrx(1,amostras,alturat,alturar,dadoselev);

        [hf,d1f,d2f]=valorcos(d1,d2,d3);

        hf=checarh(dadoselev(3,1)+alturat,dadoselev(3,end)+alturar,amostras,dadoselev(3,indexgumes(gume)),indexgumes(gume),hf);

        valoresv(gume)=fresnel(hf,d1f,d2f,lambda);

    end

    [~,indextemp]=min(valoresv);

    indexprincipal=indexgumes(indextemp);

    %% Identificar gume auxiliar esquerdo

    if indextemp==1

        indexesq=1;

    else

        [~,indextemp1]=min(valoresv(1:(indextemp-1)));

        indexesq=indexgumes(indextemp1);

    end

    %% Identificar gume auxiliar direito

    if indextemp==length(indexgumes)

        indexdir=amostras;

    else

        [~,indextemp2]=min(valoresv((indextemp+1):end));

        indextemp2=indextemp2+indextemp;

        indexdir=indexgumes(indextemp2);

    end

    %% Construir linhas do gume principal

    retacorte1=linspace(dadosdesenho(3,1),dadosdesenho(3,indexprincipal),indexprincipal);

    retacorte2=linspace(dadosdesenho(3,indexprincipal),dadosdesenho(3,end),(amostras-indexprincipal+1));

    retacorte3=linspace(dadosdesenho(3,1),dadosdesenho(3,end),amostras);

    %% Construir linhas do lado esquerdo

    retacorte4=linspace(dadosdesenho(3,1),dadosdesenho(3,indexesq),indexesq);

    retacorte5=linspace(dadosdesenho(3,indexesq),dadosdesenho(3,indexprincipal),(indexprincipal-indexesq+1));

    retacorte6=linspace(dadosdesenho(3,1),dadosdesenho(3,indexprincipal),indexprincipal);

    %% Construir linhas do lado direito

    retacorte7=linspace(dadosdesenho(3,indexprincipal),dadosdesenho(3,indexdir),(indexdir-indexprincipal+1));

    retacorte8=linspace(dadosdesenho(3,indexdir),dadosdesenho(3,end),(amostras-indexdir+1));

    retacorte9=linspace(dadosdesenho(3,indexprincipal),dadosdesenho(3,end),(amostras-indexprincipal+1));

    %% Desenhar gume principal

    plot(1:indexprincipal,retacorte1,'Color',corcentral,'LineWidth',2,'HandleVisibility','off')

    plot(indexprincipal:amostras,retacorte2,'Color',corcentral,'LineWidth',2,'HandleVisibility','off')

    plot(1:amostras,retacorte3,'Color',corcentral,'LineWidth',2,'HandleVisibility','off')

    %% Desenhar lado esquerdo

    plot(1:indexesq,retacorte4,'Color',coresquerda,'LineWidth',2,'HandleVisibility','off')

    plot(indexesq:indexprincipal,retacorte5,'Color',coresquerda,'LineWidth',2,'HandleVisibility','off')

    plot(1:indexprincipal,retacorte6,'Color',coresquerda,'LineWidth',2,'HandleVisibility','off')

    %% Desenhar lado direito

    plot(indexprincipal:indexdir,retacorte7,'Color',cordireita,'LineWidth',2,'HandleVisibility','off')

    plot(indexdir:amostras,retacorte8,'Color',cordireita,'LineWidth',2,'HandleVisibility','off')

    plot(indexprincipal:amostras,retacorte9,'Color',cordireita,'LineWidth',2,'HandleVisibility','off')

end

%% Desenhar transmissor

plot(1,dadosdesenho(3,1),'ro','MarkerFaceColor','r','MarkerSize',6,'HandleVisibility','off')

text(1,dadosdesenho(3,1)+2,'Tx')

%% Desenhar receptor

plot(amostras,dadosdesenho(3,end),'bo','MarkerFaceColor','b','MarkerSize',6,'HandleVisibility','off')

text(amostras,dadosdesenho(3,end)+2,'Rx')

%% Formatar gráfico

xlabel('Índice')

ylabel('Elevação (m)')

title('Geometria Deygout')

ax=gca;

ax.FontSize=16;

ax.LineWidth=1.5;

legend([hrelevo hgumes hesquerda hcentral hdireita],{'Relevo','Gumes','Lado esquerdo','Gume principal','Lado direito'},'Location','best')

end