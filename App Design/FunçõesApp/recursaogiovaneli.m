function pathlossgio=recursaogiovaneli(ptx,prx,indexgumes,perfil,dadoselev,lambda)

%% Inicializar perda

pathlossgio=0;

%% Verificar existência de gumes

if isempty(indexgumes)==true

    return

end

%% Calcular caso com um único gume

if length(indexgumes)==1

    p=perfil(indexgumes(1),:);

    pathlossgio=calculagume(ptx,p,prx,dadoselev,lambda);

else

    %% Calcular perda de cada gume

    valoresv=zeros(1,length(indexgumes));

    for i=1:1:length(indexgumes)

        p=perfil(indexgumes(i),:);

        valoresv(i)=calculagume(ptx,p,prx,dadoselev,lambda);

    end

    %% Identificar gume principal

    [~,principal]=min(valoresv);

    indexprincipal=indexgumes(principal);

    pprincipal=perfil(indexprincipal,:);

    %% Calcular pontos efetivos

    pefftx=pontoefetivotx(ptx,pprincipal,indexgumes,principal,perfil);

    peffrx=pontoefetivorx(prx,pprincipal,indexgumes,principal,perfil);

    %% Calcular perda do gume principal

    pathlossprincipal=calculagume(pefftx,pprincipal,peffrx,dadoselev,lambda);

    %% Calcular perdas recursivas

    perdasleft=recursaogiovaneli(ptx,pprincipal,indexgumes(1:principal-1),perfil,dadoselev,lambda);

    perdasright=recursaogiovaneli(pprincipal,prx,indexgumes(principal+1:end),perfil,dadoselev,lambda);

    %% Calcular perda total

    pathlossgio=pathlossprincipal+perdasleft+perdasright;

end

end