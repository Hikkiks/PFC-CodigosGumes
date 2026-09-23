function v = calcula_v(p0, p1, p2, lambda)

% essa funcao calcula o numero v de uma difracao em que o raio sai de p0,
% difrata em p1 e chega em p2

% calculo da reta de visada entre p0 e p2 (a1x + b1y + c1 = 0)

a1 = p0(1) - p2(1);
b1 = p2(2) - p0(2);
c1 = p0(2)*p2(1) - p2(2)*p0(1);

% calculo da reta perpendicular à reta de visada que passa por p1 (a2x +
% b2y + c2 = 0)

a2 = b1;
b2 = -a1;
c2 = a1*p1(1) - b1*p1(2);

% calculo do ponto de instersecção entre as retas

q = ([a1 b1;a2 b2])\[-c1;-c2];
q = q';
q = fliplr(q);

% calculo de h (distancia de p1 a reta de visada)

h = (a1*p1(2) + b1*p1(1) + c1)/sqrt(a1^2 + b1^2);

% calculo de d1 e d2 (distancias sobre a reta de visada)

d1 = norm(q-p0);
d2 = norm(p2-q);

% calcula v

v = h*sqrt((2/lambda)*(1/d1 + 1/d2));

end