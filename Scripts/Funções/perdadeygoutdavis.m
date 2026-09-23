function pathlossdeygoutdavis=perdadeygoutdavis(indexgumes,dadoselev,freq,gumes,alturar,alturat)

lambda=(3*10^8)/freq;

n=size(dadoselev,2);

%% Sem gumes

if gumes==0

    pathlossdeygoutdavis=0;

    return

end

%% Um unico gume

if gumes==1

    pathlossdeygoutdavis=perdadeygout(indexgumes,dadoselev,freq,gumes,alturar,alturat);

    return

end

%% Construir distancia acumulada do perfil

wgs84=wgs84Ellipsoid("m");

distancia=zeros(n,1);

for i=2:1:n

    distancia(i)=distancia(i-1)+distance(dadoselev(1,i-1),dadoselev(2,i-1),dadoselev(1,i),dadoselev(2,i),wgs84);

end

%% Perfil

perfil=zeros(n,2);

perfil(:,1)=dadoselev(3,:)';

perfil(:,2)=distancia;

%% Alturas absolutas das antenas

h1=perfil(1,1)+alturat;

h2=perfil(end,1)+alturar;

ptx=[h1 perfil(1,2)];

prx=[h2 perfil(end,2)];

%% Calcular v de cada gume isoladamente no percurso completo

valoresv=zeros(1,length(indexgumes));

for i=1:1:length(indexgumes)

    p=perfil(indexgumes(i),:);

    valoresv(i)=calculavdavis(ptx,p,prx,lambda);

end

%% Encontrar o gume principal

[~,principal]=max(valoresv);

indexprincipal=indexgumes(principal);

pprincipal=perfil(indexprincipal,:);

%% Perda do gume principal isolado

L2=perdavdavis(valoresv(principal));

%% Inicializar secundarios e correcoes

L1=0;
L3=0;

Llinhaesq=0;
Llinhadir=0;

C1=0;
C2=0;

indexesq=[];
indexdir=[];

%% Gume secundario esquerdo

if principal>1

    valoresesq=-inf(1,principal-1);

    for i=1:1:(principal-1)

        indice=indexgumes(i);

        p=perfil(indice,:);

        v=calculavdavis(ptx,p,pprincipal,lambda);

        if v>0

            valoresesq(i)=v;

        end

    end

    if all(isinf(valoresesq))==false

        [vesq,posicao]=max(valoresesq);

        indexesq=indexgumes(posicao);

        %% Perda do secundario na geometria de Deygout

        Llinhaesq=perdavdavis(vesq);

        %% Perda do mesmo gume isoladamente no percurso completo

        L1=perdavdavis(valoresv(posicao));

        %% Distancias da geometria de Causebrook e Davis

        d1=distancia(indexesq)-distancia(1);

        d2=distancia(indexprincipal)-distancia(indexesq);

        d34=distancia(end)-distancia(indexprincipal);

        %% Cosseno do parametro geometrico

        cosalpha1=sqrt((d1*d34)/((d1+d2)*(d2+d34)));

        %% Correcao esquerda

        C1=(6-L2+L1)*cosalpha1;

        if C1<0

            C1=0;

        end

    end

end

%% Gume secundario direito

if principal<length(indexgumes)

    quantidade=length(indexgumes)-principal;

    valoresdir=-inf(1,quantidade);

    for i=(principal+1):1:length(indexgumes)

        indice=indexgumes(i);

        p=perfil(indice,:);

        v=calculavdavis(pprincipal,p,prx,lambda);

        if v>0

            valoresdir(i-principal)=v;

        end

    end

    if all(isinf(valoresdir))==false

        [vdir,posicaoaux]=max(valoresdir);

        posicao=posicaoaux+principal;

        indexdir=indexgumes(posicao);

        %% Perda do secundario na geometria de Deygout

        Llinhadir=perdavdavis(vdir);

        %% Perda do mesmo gume isoladamente no percurso completo

        L3=perdavdavis(valoresv(posicao));

        %% Distancias da geometria de Causebrook e Davis

        d12=distancia(indexprincipal)-distancia(1);

        d3=distancia(indexdir)-distancia(indexprincipal);

        d4=distancia(end)-distancia(indexdir);

        %% Cosseno do parametro geometrico

        cosalpha2=sqrt((d12*d4)/((d12+d3)*(d3+d4)));

        %% Correcao direita

        C2=(6-L2+L3)*cosalpha2;

        if C2<0

            C2=0;

        end

    end

end

%% Perda sem correcao considerando os tres gumes dominantes

Ldeygout=L2+Llinhaesq+Llinhadir;

%% Aplicar Causebrook e Davis

Lcorrigida=Ldeygout-C1-C2;

%% Manter mesma convencao de sinal das outras funcoes

pathlossdeygoutdavis=-Lcorrigida;

end


function v=calculavdavis(p0,p1,p2,lambda)

%% Reta de visada

a1=p0(1)-p2(1);

b1=p2(2)-p0(2);

c1=p0(2)*p2(1)-p2(2)*p0(1);

%% Perpendicular passando pelo gume

a2=b1;

b2=-a1;

c2=a1*p1(1)-b1*p1(2);

%% Intersecao

q=([a1 b1;a2 b2])\[-c1;-c2];

q=q';

q=fliplr(q);

%% Altura do gume em relacao a linha de visada

h=(a1*p1(2)+b1*p1(1)+c1)/sqrt(a1^2+b1^2);

%% Distancias projetadas

d1=norm(q-p0);

d2=norm(p2-q);

%% Parametro v

v=h*sqrt((2/lambda)*(1/d1+1/d2));

end


function perda=perdavdavis(v)

EE0=((0.5-fresnelc(v))-1i*(0.5-fresnels(v)))*(1+1i)/2;

perda=-20*log10(abs(EE0));

end