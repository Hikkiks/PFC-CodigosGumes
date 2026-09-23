function desenhatriogioapp(eixo,ptx,p,prx,correta)

%% Definir cor da geometria

if nargin<5

    correta='b';

end

%% Obter índices dos três pontos

indextx=ptx(3);

indexgume=p(3);

indexrx=prx(3);

%% Construir as três retas da geometria

reta1=linspace(ptx(1),p(1),indexgume-indextx+1);

reta2=linspace(p(1),prx(1),indexrx-indexgume+1);

reta3=linspace(ptx(1),prx(1),indexrx-indextx+1);

%% Desenhar geometria no eixo do aplicativo

plot(eixo,indextx:indexgume,reta1,'Color',correta,'LineWidth',2)

plot(eixo,indexgume:indexrx,reta2,'Color',correta,'LineWidth',2)

plot(eixo,indextx:indexrx,reta3,'Color',correta,'LineWidth',2)

end