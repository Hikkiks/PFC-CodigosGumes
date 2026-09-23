function pontos = encontra_gumes_simples(h1,h2,perfil,lambda,zona_fresnel)

% essa funcao encontra as posicoes dos gumes de faca do perfil
%Pag 97 e 98
perfil(1,1) = h1;
perfil(end,1) = h2;
ponto = 1;
pontos = zeros(size(perfil,1),1);
k = 1;
while(1)
    ref = perfil(ponto,:);
    p_old = ponto;
    perfil_teste = perfil(ponto:end,:);
    tangentes = (perfil_teste(:,1) - ref(1))./(perfil_teste(:,2) - ref(2));
    [~,i_max] = max(tangentes);
    ponto = ponto + i_max -1;
    if(zona_fresnel)
        perfil_fresnel = perfil(p_old:ponto,:);
        p_fresnel = verifica_fresnel(perfil_fresnel,2,size(perfil_fresnel,1)-1,lambda);
        if(~isempty(p_fresnel))
            p_fresnel = p_old+p_fresnel-1;
            pontos(k) = p_fresnel;
            k = k+1;
        end
    end
    if(ponto==size(perfil,1))
        break
    end
    pontos(k) = ponto;
    k = k+1;
end
pontos(pontos==0) = [];
end