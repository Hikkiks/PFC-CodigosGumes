function hgumes=desenhagumesapp(eixo,indexgumes,alturas)

%% Definir limite inferior das linhas dos gumes

elevmin=min(alturas);

%% Criar objeto auxiliar para a legenda

hgumes=plot(eixo,nan,nan,'r--o','MarkerFaceColor','r','MarkerEdgeColor','r','MarkerSize',6,'LineWidth',1.5);

%% Desenhar gumes identificados

for i=1:length(indexgumes)

    indice=indexgumes(i);

    alturagume=alturas(indice);

    % Linha vertical até a altura do gume
    line(eixo,[indice indice],[elevmin alturagume],'Color','r','LineStyle','--','LineWidth',1.5)

    % Marcação do gume
    plot(eixo,indice,alturagume,'ro','MarkerFaceColor','r','MarkerEdgeColor','r','MarkerSize',6,'LineWidth',1.2)

end

end