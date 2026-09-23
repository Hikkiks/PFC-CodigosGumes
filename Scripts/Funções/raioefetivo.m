function dadoselev=raioefetivo(dadoselev)

%% Informações iniciais

n=size(dadoselev,2);

wgs84=wgs84Ellipsoid("m");

%% Calcular distância acumulada

distancia=zeros(1,n);

for i=2:1:n

    distancia(i)=distancia(i-1)+distance(dadoselev(1,i-1),dadoselev(2,i-1),dadoselev(1,i),dadoselev(2,i),wgs84);

end

dtotal=distancia(end);

%% Definir fator do raio efetivo

if dtotal>17*10^3

    k=2/3;

else

    k=4/3;

end

%% Definir raio da Terra

ro=6371*10^3;

%% Corrigir elevações do perfil

for i=2:1:n

    hcorrecao=(distancia(i)^2)/(2*k*ro);

    dadoselev(3,i)=dadoselev(3,i)-hcorrecao;

end

end