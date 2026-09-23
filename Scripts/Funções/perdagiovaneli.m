function pathlossgio=perdagiovaneli(indexgumes,dadoselev,freq,gumes,alturar,alturat)

%% Informações iniciais

lambda=(3*10^8)/freq;

n=size(dadoselev,2);

%% Calcular caso com nenhum ou um gume

if gumes<2

    %% Calcular caso sem gumes

    if gumes==0

        gfresnel=zeros(1,n);

        dist=txrx(1,n,alturat,alturar,dadoselev);

        for index=1:1:(n-1)

            d1=txrx(1,1+index,alturat,0,dadoselev);

            d2=txrx(1+index,n,0,alturar,dadoselev);

            [hf,d1f,d2f]=valorcos(d1,d2,dist);

            gfresnel(1,index)=fresnel(-hf,d1f,d2f,lambda);

        end

        pathlossgio=min(gfresnel);

    %% Calcular caso com um gume

    else

        d1=txrx(1,indexgumes(1),alturat,0,dadoselev);

        d2=txrx(indexgumes(1),n,0,alturar,dadoselev);

        d3=txrx(1,n,alturat,alturar,dadoselev);

        [hf,d1f,d2f]=valorcos(d1,d2,d3);

        pathlossgio=fresnel(hf,d1f,d2f,lambda);

    end

%% Calcular caso com múltiplos gumes

else

    %% Adicionar alturas das antenas

    dadoselev(3,1)=dadoselev(3,1)+alturat;

    dadoselev(3,end)=dadoselev(3,end)+alturar;

    %% Calcular distância acumulada

    wgs84=wgs84Ellipsoid("m");

    distancia=zeros(1,n);

    for i=2:1:n

        distancia(i)=distancia(i-1)+distance(dadoselev(1,i-1),dadoselev(2,i-1),dadoselev(1,i),dadoselev(2,i),wgs84);

    end

    %% Preparar perfil

    perfil=[dadoselev(3,:)' distancia' (1:n)'];

    ptx=perfil(1,:);

    prx=perfil(end,:);

    %% Calcular perda pelo método recursivo de Giovaneli

    pathlossgio=recursaogiovaneli(ptx,prx,indexgumes,perfil,dadoselev,lambda);

end

end