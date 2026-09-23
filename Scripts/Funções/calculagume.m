function perda=calculagume(ptx,p,prx,dadoselev,lambda)

%% Identificar os pontos

indextx=ptx(3);

indexgume=p(3);

indexrx=prx(3);

%% Calcular alturas relativas

alturatx=ptx(1)-dadoselev(3,indextx);

alturarx=prx(1)-dadoselev(3,indexrx);

%% Calcular distâncias

d1=txrx(indextx,indexgume,alturatx,0,dadoselev);

d2=txrx(indexgume,indexrx,0,alturarx,dadoselev);

d3=txrx(indextx,indexrx,alturatx,alturarx,dadoselev);

%% Calcular geometria do gume

[hf,d1f,d2f]=valorcos(d1,d2,d3);

%% Corrigir a altura do gume

pontos=indexrx-indextx+1;

indexrelativo=indexgume-indextx+1;

hf=checarh(ptx(1),prx(1),pontos,p(1),indexrelativo,hf);

%% Calcular perda por difração

perda=fresnel(hf,d1f,d2f,lambda);

end