function pathlossdeygout=perdadeygout(indexgumes,dadoselev,freq,gumes,alturar,alturat)

%% Informações iniciais

lambda=(3*10^8)/freq;

n=size(dadoselev,2);

%% Verificar existência de gumes

if gumes==0

    pathlossdeygout=0;

    return

end

%% Calcular distância acumulada

wgs84=wgs84Ellipsoid("m");

distancia=zeros(n,1);

for i=2:1:n

    distancia(i)=distancia(i-1)+distance(dadoselev(1,i-1),dadoselev(2,i-1),dadoselev(1,i),dadoselev(2,i),wgs84);

end

%% Preparar perfil

perfil=zeros(n,2);

perfil(:,1)=dadoselev(3,:)';

perfil(:,2)=distancia;

%% Calcular alturas absolutas das antenas

h1=perfil(1,1)+alturat;

h2=perfil(end,1)+alturar;

%% Definir pontos do transmissor e receptor

ptx=[h1 perfil(1,2)];

prx=[h2 perfil(end,2)];

%% Calcular perdas pelo método recursivo de Deygout

perdas=recursaodeygout(ptx,prx,indexgumes,perfil,lambda,1,length(indexgumes),[]);

%% Calcular perda total

pathlossdeygout=sum(perdas);

end


function perdas=recursaodeygout(ptx,prx,gumes,perfil,lambda,ini,fim,perdas)

%% Selecionar gumes do trecho atual

gumes=gumes(ini:fim);

ini=1;

fim=length(gumes);

%% Calcular trecho com mais de um gume

if length(gumes)>1

    valoresv=zeros(1,fim-ini+1);

    valoresh=zeros(1,fim-ini+1);

    valoresd1=zeros(1,fim-ini+1);

    valoresd2=zeros(1,fim-ini+1);

    %% Calcular parâmetros de cada gume

    for n=1:1:length(gumes)

        p=perfil(gumes(n),:);

        [valoresv(n),valoresh(n),valoresd1(n),valoresd2(n)]=calculav(ptx,p,prx,lambda);

    end

    %% Identificar gume principal

    [~,principal]=max(valoresv);

    %% Calcular perda do gume principal

    perda=fresnel(valoresh(principal),valoresd1(principal),valoresd2(principal),lambda);

    perdas=[perdas perda];

    %% Calcular lado esquerdo

    perdas=recursaodeygout(ptx,perfil(gumes(principal),:),gumes,perfil,lambda,ini,principal-1,perdas);

    %% Calcular lado direito

    perdas=recursaodeygout(perfil(gumes(principal),:),prx,gumes,perfil,lambda,principal+1,fim,perdas);

%% Calcular trecho com um único gume

elseif length(gumes)==1

    p=perfil(gumes,:);

    [~,h,d1,d2]=calculav(ptx,p,prx,lambda);

    perda=fresnel(h,d1,d2,lambda);

    perdas=[perdas perda];

end

end


function [v,h,d1,d2]=calculav(p0,p1,p2,lambda)

%% Construir linha de visada entre p0 e p2

a1=p0(1)-p2(1);

b1=p2(2)-p0(2);

c1=p0(2)*p2(1)-p2(2)*p0(1);

%% Construir reta perpendicular passando pelo gume

a2=b1;

b2=-a1;

c2=a1*p1(1)-b1*p1(2);

%% Calcular interseção entre as retas

q=([a1 b1;a2 b2])\[-c1;-c2];

q=q';

q=fliplr(q);

%% Calcular altura perpendicular do gume

h=(a1*p1(2)+b1*p1(1)+c1)/sqrt(a1^2+b1^2);

%% Calcular distâncias projetadas

d1=norm(q-p0);

d2=norm(p2-q);

%% Calcular parâmetro de Fresnel-Kirchhoff

v=h*sqrt((2/lambda)*(1/d1+1/d2));

end