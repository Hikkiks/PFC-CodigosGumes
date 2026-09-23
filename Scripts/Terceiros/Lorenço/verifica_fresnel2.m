function [ max ] = verifica_fresnel2( perfil, h1, h2, lambda )
max = [];
p0 = [h1 perfil(1,2)];
p2 = [h2 perfil(end,2)];
D = p2(2) - p0(2); 
m = (p2(1) - p0(1))/D; % coeficiente da reta de visada
d = distancia(p0,p2);

% calculo do elipsoide da zona de fresnel 0.6
fresnel = [gera_fresnel(perfil(:,2),lambda,d) perfil(:,2)];
rotacionado = roda(fresnel(:,2),fresnel(:,1),atan(m),p0(2),p0(1));
fresnel(:,1) = rotacionado(:,1) + p0(1);

% com o elipsoide agora tem q calcular se algo ta dentro dele
diferencas = perfil(:,1) - fresnel(:,1);
pontos_fresnel = find(diferencas>=0);
if(~isempty(pontos_fresnel))
    pontos_fresnel = pontos_fresnel(2:end-1);
    max = -999999999;
    for i=1:length(pontos_fresnel)
        ind = pontos_fresnel(i);
        p = perfil(ind,:);
        v = calcula_v(p0,p,p2,lambda);
        if(v > max)
            max = v;
            pto_fresnel = ind;
        end
    end    
end
end

