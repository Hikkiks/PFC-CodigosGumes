function desenhagiovaneliapp(eixo,dadoselev,indexgumes,alturat,alturar,freq)

%% Quantidade de amostras

n=size(dadoselev,2);

%% Comprimento de onda

lambda=(3*10^8)/freq;

%% Cores utilizadas na geometria

coresquerda=[0 0.6 0];

corcentral='b';

cordireita=[0.85 0.65 0];

%% Criar perfil para desenho com alturas das antenas

dadoselevplot=dadoselev;

dadoselevplot(3,1)=dadoselevplot(3,1)+alturat;

dadoselevplot(3,end)=dadoselevplot(3,end)+alturar;

%% Calcular distância acumulada ao longo do perfil

wgs84=wgs84Ellipsoid("m");

distancia=zeros(1,n);

for i=2:1:n

    distancia(i)=distancia(i-1)+distance(dadoselev(1,i-1),dadoselev(2,i-1),dadoselev(1,i),dadoselev(2,i),wgs84);

end

%% Montar perfil com altitude, distância e índice

perfil=[dadoselevplot(3,:)' distancia' (1:n)'];

%% Definir Tx e Rx

ptx=perfil(1,:);

prx=perfil(end,:);

%% Preparar eixo do aplicativo

legend(eixo,'off')

cla(eixo)

hold(eixo,"on")

grid(eixo,"on")

%% Desenhar relevo

hrelevo=plot(eixo,1:n,dadoselevplot(3,:),'k','LineWidth',2.5);

%% Construção da geometria de Giovaneli

desenharecursaogioapp(eixo,ptx,prx,indexgumes,perfil,dadoselev,lambda)

%% Marcar gumes

hgumes=desenhagumesapp(eixo,indexgumes,dadoselevplot(3,:));

%% Criar objetos auxiliares para a legenda

hesquerda=plot(eixo,nan,nan,'Color',coresquerda,'LineWidth',2);

hcentral=plot(eixo,nan,nan,'Color',corcentral,'LineWidth',2);

hdireita=plot(eixo,nan,nan,'Color',cordireita,'LineWidth',2);

%% Marcar transmissor

plot(eixo,1,dadoselevplot(3,1),'ro','MarkerFaceColor','r','MarkerSize',6)

text(eixo,1,dadoselevplot(3,1)+2,'Tx')

%% Marcar receptor

plot(eixo,n,dadoselevplot(3,end),'bo','MarkerFaceColor','b','MarkerSize',6)

text(eixo,n,dadoselevplot(3,end)+2,'Rx')

%% Formatação final

xlabel(eixo,'Índice')

ylabel(eixo,'Elevação (m)')

title(eixo,'Geometria Giovaneli')

eixo.FontSize=16;

eixo.LineWidth=1.5;

legend(eixo,[hrelevo hgumes hesquerda hcentral hdireita],{'Relevo','Gumes','Lado esquerdo','Gume principal','Lado direito'},'Location','best')

drawnow

end