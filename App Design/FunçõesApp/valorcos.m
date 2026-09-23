function [hf,d1f,d2f]=valorcos(a,b,c)

%% Calcular cossenos dos ângulos

vcos1=((c^2)+(a^2)-(b^2))/(2*c*a);

vcos2=((c^2)+(b^2)-(a^2))/(2*c*b);

%% Calcular distâncias projetadas

d2f=abs(b*vcos2);

d1f=abs(a*vcos1);

%% Calcular altura perpendicular

hf=sqrt((a^2)-(d1f^2));

end