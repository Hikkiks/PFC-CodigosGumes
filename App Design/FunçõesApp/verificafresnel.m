function indicefresnel=verificafresnel(altura,distancia,ponto1,ponto2,lambda)

%% Inicializar resultado

indicefresnel=[];

if ponto2-ponto1<=1

    return

end

%% Definir pontos inicial e final

x1=distancia(ponto1);

x2=distancia(ponto2);

h1=altura(ponto1);

h2=altura(ponto2);

D=x2-x1;

if D<=0

    return

end

%% Calcular inclinação da linha de visada

m=(h2-h1)/D;

theta=atan(m);

%% Calcular distância entre os extremos

d=sqrt(D^2+(h2-h1)^2);

%% Construir 60% da primeira zona de Fresnel

quantidade=ponto2-ponto1+1;

s=linspace(0,d,quantidade);

raiofresnel=0.6*sqrt(lambda*s.*(d-s)./d);

%% Construir linha de visada no sistema local

xlocal=s.*cos(theta);

hlocal=s.*sin(theta);

%% Rotacionar zona de Fresnel

xfresnel=x1+xlocal+raiofresnel.*sin(theta);

hfresnel=h1+hlocal-raiofresnel.*cos(theta);

%% Selecionar pontos internos do perfil

indices=ponto1+1:ponto2-1;

if isempty(indices)==true

    return

end

xperfil=distancia(indices);

%% Interpolar limite da zona de Fresnel

[xfresnelunico,indiceunico]=unique(xfresnel,'stable');

hfresnelunico=hfresnel(indiceunico);

limitefresnel=interp1(xfresnelunico,hfresnelunico,xperfil,'linear');

%% Identificar obstruções

diferencas=altura(indices)-limitefresnel;

pontosfresnel=find(diferencas>=0);

if isempty(pontosfresnel)==true

    return

end

%% Calcular parâmetro v das obstruções

valoresv=zeros(1,length(pontosfresnel));

for i=1:1:length(pontosfresnel)

    indicelocal=pontosfresnel(i);

    indicereal=indices(indicelocal);

    x=distancia(indicereal);

    h=altura(indicereal);

    %% Calcular distâncias até o ponto

    d1=sqrt((x-x1)^2+(h-h1)^2);

    d2=sqrt((x2-x)^2+(h2-h)^2);

    %% Calcular geometria do ponto

    [hf,d1f,d2f]=valorcos(d1,d2,d);

    indexrelativo=indicereal-ponto1+1;

    hf=checarh(h1,h2,quantidade,h,indexrelativo,hf);

    %% Calcular parâmetro v

    valoresv(i)=hf*sqrt((2/lambda)*(1/d1f+1/d2f));

end

%% Selecionar obstrução de maior v

[~,indicemaior]=max(valoresv);

indicefresnel=indices(pontosfresnel(indicemaior));

end