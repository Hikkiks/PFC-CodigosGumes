function hfa=checarh(ponto1,ponto2,pontos,alturagume,indexrelativo,hf)

%% Construir a linha de referência

retacorte=linspace(ponto1,ponto2,pontos);

%% Verificar o sinal da altura

if retacorte(indexrelativo)>alturagume

    hfa=-hf;

else

    hfa=hf;

end

end