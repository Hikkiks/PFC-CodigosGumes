function desenhatriogio(ptx,p,prx,correta)

%% Identificar os pontos

indextx=ptx(3);

indexgume=p(3);

indexrx=prx(3);

%% Construir as retas

reta1=linspace(ptx(1),p(1),indexgume-indextx+1);

reta2=linspace(p(1),prx(1),indexrx-indexgume+1);

reta3=linspace(ptx(1),prx(1),indexrx-indextx+1);

%% Desenhar a geometria

plot(indextx:indexgume,reta1,'Color',correta,'LineWidth',2,'HandleVisibility','off')

plot(indexgume:indexrx,reta2,'Color',correta,'LineWidth',2,'HandleVisibility','off')

plot(indextx:indexrx,reta3,'Color',correta,'LineWidth',2,'HandleVisibility','off')

end