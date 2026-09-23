function desenhagiovaneli(dadoselev,indexgumes,alturat,alturar,freq)

%% Informações iniciais

n=size(dadoselev,2);

lambda=(3*10^8)/freq;

coresquerda=[0 0.6 0];

corcentral='b';

cordireita=[0.85 0.65 0];

%% Adicionar alturas das antenas

dadoselev(3,1)=dadoselev(3,1)+alturat;

dadoselev(3,end)=dadoselev(3,end)+alturar;

%% Calcular distâncias acumuladas

wgs84=wgs84Ellipsoid("m");

distancia=zeros(1,n);

for i=2:1:n

    distancia(i)=distancia(i-1)+distance(dadoselev(1,i-1),dadoselev(2,i-1),dadoselev(1,i),dadoselev(2,i),wgs84);

end

%% Preparar perfil

perfil=[dadoselev(3,:)' distancia' (1:n)'];

ptx=perfil(1,:);

prx=perfil(end,:);

hold("on")

grid("on")

%% Desenhar relevo

hrelevo=plot(1:n,dadoselev(3,:),'k','LineWidth',2.5);

%% Desenhar gumes

hgumes=desenhagumes(indexgumes,dadoselev(3,:));

%% Criar objetos para legenda

hesquerda=plot(nan,nan,'Color',coresquerda,'LineWidth',2);

hcentral=plot(nan,nan,'Color',corcentral,'LineWidth',2);

hdireita=plot(nan,nan,'Color',cordireita,'LineWidth',2);

%% Construir geometria de Giovaneli

desenharecursaogio(ptx,prx,indexgumes,perfil,dadoselev,lambda)

%% Desenhar transmissor

plot(1,dadoselev(3,1),'ro','MarkerFaceColor','r','MarkerSize',6,'HandleVisibility','off')

text(1,dadoselev(3,1)+2,'Tx')

%% Desenhar receptor

plot(n,dadoselev(3,end),'bo','MarkerFaceColor','b','MarkerSize',6,'HandleVisibility','off')

text(n,dadoselev(3,end)+2,'Rx')

%% Formatar gráfico

xlabel('Índice')

ylabel('Elevação (m)')

title('Geometria Giovaneli')

ax=gca;

ax.FontSize=16;

ax.LineWidth=1.5;

legenda=legend([hrelevo hgumes hesquerda hcentral hdireita],{'Relevo','Gumes','Lado esquerdo','Gume principal','Lado direito'},'Location','best');

legenda.AutoUpdate='off';

end