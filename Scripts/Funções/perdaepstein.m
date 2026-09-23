function pathlossepstein=perdaepstein(indexgumes,dadoselev,freq,gumes,alturar,alturat)

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

        pathlossepstein=min(gfresnel);

    %% Calcular caso com um gume

    else

        d1=txrx(1,indexgumes(1),alturat,0,dadoselev);

        d2=txrx(indexgumes(1),n,0,alturar,dadoselev);

        d3=txrx(1,n,alturat,alturar,dadoselev);

        [hf,d1f,d2f]=valorcos(d1,d2,d3);

        pathlossepstein=fresnel(hf,d1f,d2f,lambda);

    end

%% Calcular caso com múltiplos gumes

else

    dadoselev(3,1)=dadoselev(3,1)+alturat;

    dadoselev(3,end)=dadoselev(3,end)+alturar;

    pathlossaux=0;

    for y=1:1:gumes

        %% Definir ponto à esquerda do gume

        if y==1

            indexesqaux=1;

        else

            indexesqaux=indexgumes(y-1);

        end

        %% Definir ponto à direita do gume

        if y==gumes

            indexdiraux=n;

        else

            indexdiraux=indexgumes(y+1);

        end

        %% Calcular distâncias da geometria

        d1a=txrx(indexesqaux,indexgumes(y),0,0,dadoselev);

        d2a=txrx(indexgumes(y),indexdiraux,0,0,dadoselev);

        d3a=txrx(indexesqaux,indexdiraux,0,0,dadoselev);

        %% Calcular altura do gume

        [hfa,d1fa,d2fa]=valorcos(d1a,d2a,d3a);

        %% Preparar índices do trecho

        pontos=indexdiraux-indexesqaux+1;

        indexrelativo=indexgumes(y)-indexesqaux+1;

        %% Corrigir sinal da altura

        hfa=checarh(dadoselev(3,indexesqaux),dadoselev(3,indexdiraux),pontos,dadoselev(3,indexgumes(y)),indexrelativo,hfa);

        %% Calcular perda do gume

        pathlossaux=pathlossaux+fresnel(hfa,d1fa,d2fa,lambda);

    end

    %% Calcular perda total

    pathlossepstein=pathlossaux;

end

end