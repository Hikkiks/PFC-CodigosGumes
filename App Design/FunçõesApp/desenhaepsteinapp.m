function desenhaepsteinapp(eixo,dadoselev,indexgumes,alturat,alturar)

% Quantidade de amostras e gumes
amostras=size(dadoselev,2);

gumes=length(indexgumes);

% Cor utilizada na representação da geometria
corgeometria='b';

% Adicionar as alturas das antenas somente para representação
dadoselev(3,1)=dadoselev(3,1)+alturat;

dadoselev(3,end)=dadoselev(3,end)+alturar;

% Preparar eixo do aplicativo
legend(eixo,'off')

cla(eixo)

hold(eixo,"on")

grid(eixo,"on")

%% Relevo

hrelevo=plot(eixo,1:amostras,dadoselev(3,:),'k','LineWidth',2.5);

%% Construção Epstein-Peterson

if gumes==0

    % Representar ligação direta entre Tx e Rx
    retacorte=linspace(dadoselev(3,1),dadoselev(3,end),amostras);

    plot(eixo,1:amostras,retacorte,'Color',corgeometria,'LineWidth',2)

else

    % Organizar Tx, gumes e Rx em sequência
    pontos=[1 indexgumes amostras];

    % Construir a geometria de cada gume com seus pontos vizinhos
    for y=2:1:(length(pontos)-1)

        indexesq=pontos(y-1);

        indexgume=pontos(y);

        indexdir=pontos(y+1);

        reta1=linspace(dadoselev(3,indexesq),dadoselev(3,indexgume),(indexgume-indexesq+1));

        reta2=linspace(dadoselev(3,indexgume),dadoselev(3,indexdir),(indexdir-indexgume+1));

        reta3=linspace(dadoselev(3,indexesq),dadoselev(3,indexdir),(indexdir-indexesq+1));

        plot(eixo,indexesq:indexgume,reta1,'Color',corgeometria,'LineWidth',2)

        plot(eixo,indexgume:indexdir,reta2,'Color',corgeometria,'LineWidth',2)

        plot(eixo,indexesq:indexdir,reta3,'Color',corgeometria,'LineWidth',2)

    end

end

%% Gumes

hgumes=desenhagumesapp(eixo,indexgumes,dadoselev(3,:));

%% Objeto utilizado somente na legenda

hgeometria=plot(eixo,nan,nan,'Color',corgeometria,'LineWidth',2);

%% Tx

plot(eixo,1,dadoselev(3,1),'ro','MarkerFaceColor','r','MarkerSize',6)

text(eixo,1,dadoselev(3,1)+2,'Tx')

%% Rx

plot(eixo,amostras,dadoselev(3,end),'bo','MarkerFaceColor','b','MarkerSize',6)

text(eixo,amostras,dadoselev(3,end)+2,'Rx')

%% Formatação

xlabel(eixo,'Índice')

ylabel(eixo,'Elevação (m)')

title(eixo,'Geometria Epstein-Peterson')

eixo.FontSize=16;

eixo.LineWidth=1.5;

legend(eixo,[hrelevo hgumes hgeometria],{'Relevo','Gumes','Retas da Geometria'},'Location','best')

drawnow

end