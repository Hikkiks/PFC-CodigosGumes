function [pontos] = traca_caminho(h1,h2,ini,fim,perfil,lambda,pontos,zona_fresnel)

perfil2 = [perfil(ini:fim,:) (ini:fim)'];
% ini é o indice do ponto de observacao no perfil
% fim é o indice do ponto de recepcao no perfil

h = perfil2(1,1); % altitude do ponto de observacao
% se o ponto de observacao for o ponto do transmissor, adiciona a altura da
% torre de transmissao
if ini==1
    h = h1;
end

D = perfil2(end,2) - perfil2(1,2); % distancia horizontal entre os pontos de observacao e recepcao
m = (h2 - h)/D; % coeficiente da reta de visada
visada = @(x) m*(x-perfil2(1,2)) + h; % reta de visada

% verifica se há obstrucao na visada
diferencas = perfil2(:,1) - visada(perfil2(:,2));
regiao_teste = perfil2(diferencas>=0,:);
if(~isempty(regiao_teste))
    if(regiao_teste(1,3)==ini)
        regiao_teste = regiao_teste(2:end,:);
    end
end

if (~isempty(regiao_teste)) % nao tem visada direta
    tangentes = zeros(1,size(regiao_teste,1));
    for i=1:size(regiao_teste,1)
        p = regiao_teste(i,:);
        deltaH = p(:,1) - h;
        lado = p(:,2) - perfil2(1,2);
        tangentes(i) = deltaH/lado;
    end
    % descobre a obstrucao do horizonte de observacao
    [~,i_max] = max(tangentes);
    % nesse ponto eu sei pra qual ponto o sinal vai para ser difratado, ou
    % seja, a primeira obstrucao a frente
    pto = regiao_teste(i_max,3);
    
    % verifica por obstrucoes na zona de fresnel entre esses pontos
    if(zona_fresnel)
        p_fresnel = verifica_fresnel(perfil(ini:pto,:),h,perfil(pto,1),lambda);
        if(~isempty(p_fresnel))
            p_fresnel = ini + p_fresnel - 1;
            pontos = [pontos; p_fresnel; pto];
        else
            pontos = [pontos; pto];
        end
    else
        pontos = [pontos; pto];
    end
    ini = pto;
    pontos = traca_caminho(h1,h2,ini,size(perfil,1),perfil,lambda,pontos,zona_fresnel);   
else % se tem visada direta, procurar apenas por obstrucao na zona de fresnel
    if(zona_fresnel)
        p_fresnel = verifica_fresnel(perfil2(:,1:2),h,h2,lambda);
        if(~isempty(p_fresnel))
            p_fresnel = ini + p_fresnel - 1;
            pontos = [pontos; p_fresnel];
        end
    end
end
end