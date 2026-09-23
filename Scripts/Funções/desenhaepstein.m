function desenhaepstein(dadoselev,indexgumes,alturat,alturar)

%% Informações iniciais

amostras=size(dadoselev,2);

gumes=length(indexgumes);

corgeometria='b';

%% Adicionar alturas das antenas

dadoselev(3,1)=dadoselev(3,1)+alturat;

dadoselev(3,end)=dadoselev(3,end)+alturar;

hold("on")

grid("on")

%% Desenhar relevo

hrelevo=plot(1:amostras,dadoselev(3,:),'k','LineWidth',2.5);

%% Desenhar gumes

hgumes=desenhagumes(indexgumes,dadoselev(3,:));

%% Criar objeto para legenda

hgeometria=plot(nan,nan,'Color',corgeometria,'LineWidth',2);

%% Construir geometria de Epstein-Peterson

if gumes==0

    retacorte=linspace(dadoselev(3,1),dadoselev(3,end),amostras);

    plot(1:amostras,retacorte,'Color',corgeometria,'LineWidth',2,'HandleVisibility','off')

else

    pontos=[1 indexgumes amostras];

    for y=2:1:(length(pontos)-1)

        indexesqaux=pontos(y-1);

        indexcentro=pontos(y);

        indexdiraux=pontos(y+1);

        reta1=linspace(dadoselev(3,indexesqaux),dadoselev(3,indexcentro),(indexcentro-indexesqaux+1));

        reta2=linspace(dadoselev(3,indexcentro),dadoselev(3,indexdiraux),(indexdiraux-indexcentro+1));

        reta3=linspace(dadoselev(3,indexesqaux),dadoselev(3,indexdiraux),(indexdiraux-indexesqaux+1));

        plot(indexesqaux:indexcentro,reta1,'Color',corgeometria,'LineWidth',2,'HandleVisibility','off')

        plot(indexcentro:indexdiraux,reta2,'Color',corgeometria,'LineWidth',2,'HandleVisibility','off')

        plot(indexesqaux:indexdiraux,reta3,'Color',corgeometria,'LineWidth',2,'HandleVisibility','off')

    end

end

%% Desenhar transmissor

plot(1,dadoselev(3,1),'ro','MarkerFaceColor','r','MarkerSize',6,'HandleVisibility','off')

text(1,dadoselev(3,1)+2,'Tx')

%% Desenhar receptor

plot(amostras,dadoselev(3,end),'bo','MarkerFaceColor','b','MarkerSize',6,'HandleVisibility','off')

text(amostras,dadoselev(3,end)+2,'Rx')

%% Formatar gráfico

xlabel('Índice')

ylabel('Elevação (m)')

title('Geometria Epstein-Peterson')

ax=gca;

ax.FontSize=16;

ax.LineWidth=1.5;

legend([hrelevo hgumes hgeometria],{'Relevo','Gumes','Retas da Geometria'},'Location','best')

end