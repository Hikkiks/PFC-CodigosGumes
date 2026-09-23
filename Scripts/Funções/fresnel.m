function gfres=fresnel(h,d1,d2,lambda)

%% Calcular parâmetro de Fresnel

vfres=h*sqrt((2*(d1+d2))/(lambda*d1*d2));

%% Calcular perda por difração

if vfres<=-0.806

    gfres=0;

elseif vfres<=0

    gfres=20*log10(0.5-(0.62*vfres));

elseif vfres<=1

    gfres=20*log10(0.5*exp(-0.95*vfres));

elseif vfres<=2.4

    gfres=20*log10(0.4-sqrt(0.1184-((0.38-(0.1*vfres))^2)));

else

    gfres=20*log10(0.225/vfres);

end

end