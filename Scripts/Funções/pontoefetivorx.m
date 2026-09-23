function peffrx=pontoefetivorx(prx,pprincipal,indexgumes,principal,perfil)

%% Informações iniciais

fim=length(indexgumes);

%% Verificar se o gume principal é o último

if principal==fim

    peffrx=prx;

else

    %% Definir pontos posteriores ao gume principal

    if principal==fim-1

        pdepois2=prx;

    else

        pdepois2=perfil(indexgumes(principal+2),:);

    end

    pdepois=perfil(indexgumes(principal+1),:);

    %% Construir reta de referência

    a=pprincipal(1)-pdepois2(1);

    b=pdepois2(2)-pprincipal(2);

    c=pprincipal(2)*pdepois2(1)-pdepois2(2)*pprincipal(1);

    retadepois=-(a*pdepois(2)+c)/b;

    %% Calcular ponto efetivo do receptor

    if pdepois(1)<=retadepois

        heffrx=-(a*prx(2)+c)/b;

        peffrx=[heffrx prx(2) prx(3)];

    else

        a2=pprincipal(1)-pdepois(1);

        b2=pdepois(2)-pprincipal(2);

        c2=pprincipal(2)*pdepois(1)-pdepois(2)*pprincipal(1);

        heffrx=-(a2*prx(2)+c2)/b2;

        peffrx=[heffrx prx(2) prx(3)];

    end

end

end