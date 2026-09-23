function hgumes=desenhagumes(indexgumes,alturas)

%% Identificar elevação mínima

elevmin=min(alturas);

%% Criar objeto para legenda

hgumes=plot(nan,nan,'r--o','MarkerFaceColor','r','MarkerSize',6,'LineWidth',1.5);

%% Desenhar gumes

for i=1:length(indexgumes)

    indice=indexgumes(i);

    alturagume=alturas(indice);

    line([indice indice],[elevmin alturagume],'Color','r','LineStyle','--','LineWidth',1.5,'HandleVisibility','off')

    plot(indice,alturagume,'ro','MarkerFaceColor','r','MarkerSize',6,'LineWidth',1.2,'HandleVisibility','off')

end

end