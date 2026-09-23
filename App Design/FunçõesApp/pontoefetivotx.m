function pefftx=pontoefetivotx(ptx,pprincipal,indexgumes,principal,perfil)

%% Verificar se o gume principal é o primeiro

if principal==1

    pefftx=ptx;

else

    %% Definir pontos anteriores ao gume principal

    if principal==2

        pantes2=ptx;

    else

        pantes2=perfil(indexgumes(principal-2),:);

    end

    pantes=perfil(indexgumes(principal-1),:);

    %% Construir reta de referência

    a=pantes2(1)-pprincipal(1);

    b=pprincipal(2)-pantes2(2);

    c=pantes2(2)*pprincipal(1)-pprincipal(2)*pantes2(1);

    retaantes=-(a*pantes(2)+c)/b;

    %% Calcular ponto efetivo do transmissor

    if pantes(1)<=retaantes

        hefftx=-(a*ptx(2)+c)/b;

        pefftx=[hefftx ptx(2) ptx(3)];

    else

        a1=pantes(1)-pprincipal(1);

        b1=pprincipal(2)-pantes(2);

        c1=pantes(2)*pprincipal(1)-pprincipal(2)*pantes(1);

        hefftx=-(a1*ptx(2)+c1)/b1;

        pefftx=[hefftx ptx(2) ptx(3)];

    end

end

end