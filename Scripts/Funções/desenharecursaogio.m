function desenharecursaogio(ptx,prx,indexgumes,perfil,dadoselev,lambda,correta,principalglobal)

%% Definir parâmetros opcionais

if nargin<7

    correta='b';

    principalglobal=true;

elseif nargin<8

    principalglobal=false;

end

%% Verificar existência de gumes

if isempty(indexgumes)==true

    return

end

%% Desenhar caso com um único gume

if length(indexgumes)==1

    indexprincipal=indexgumes(1);

    pprincipal=perfil(indexprincipal,:);

    desenhatriogio(ptx,pprincipal,prx,correta)

else

    %% Calcular perda de cada gume

    valoresv=zeros(1,length(indexgumes));

    for i=1:1:length(indexgumes)

        p=perfil(indexgumes(i),:);

        valoresv(i)=calculagume(ptx,p,prx,dadoselev,lambda);

    end

    %% Identificar gume principal

    [~,principal]=min(valoresv);

    indexprincipal=indexgumes(principal);

    pprincipal=perfil(indexprincipal,:);

    %% Calcular pontos efetivos

    pefftx=pontoefetivotx(ptx,pprincipal,indexgumes,principal,perfil);

    peffrx=pontoefetivorx(prx,pprincipal,indexgumes,principal,perfil);

    %% Desenhar geometria atual

    desenhatriogio(pefftx,pprincipal,peffrx,correta)

    %% Desenhar recursões

    if principalglobal==true

        desenharecursaogio(ptx,pprincipal,indexgumes(1:principal-1),perfil,dadoselev,lambda,[0 0.6 0],false)

        desenharecursaogio(pprincipal,prx,indexgumes(principal+1:end),perfil,dadoselev,lambda,[0.85 0.65 0],false)

    else

        desenharecursaogio(ptx,pprincipal,indexgumes(1:principal-1),perfil,dadoselev,lambda,correta,false)

        desenharecursaogio(pprincipal,prx,indexgumes(principal+1:end),perfil,dadoselev,lambda,correta,false)

    end

end

end