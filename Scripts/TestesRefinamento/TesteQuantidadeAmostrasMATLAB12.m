clear
clc
close all

%% Definir caminhos

pastateste=fileparts(mfilename('fullpath'));

pastascripts=fileparts(pastateste);

addpath(fullfile(pastascripts,'Funções'))

%% Definir quantidades de amostras

amostrasteste=[64 100 128 256 512];

%% Definir pontos de recepção

latrx=[-18.865 -18.88917 -18.87167 -18.98833 -18.95861 -18.975];

lonrx=[-48.21833 -48.21194 -48.30944 -48.275 -48.32167 -48.37639];

alturar=1.5;

%% Definir Emissora 1

lattx1=-18.885;

lontx1=-48.25833;

freq1=557.142857*10^6;

alturat1=76.2;

gumeslorenco1=[3 3 4 3 3 2];

%% Definir Emissora 2

lattx2=-18.8825;

lontx2=-48.25083;

freq2=581.142857*10^6;

alturat2=113;

gumeslorenco2=[2 2 3 3 3 1];

%% Testar Emissora 1

fprintf('\n')
fprintf('EMISSORA 1\n')
fprintf('\n')

for ponto=1:6

    fprintf('Ponto %d | Lorenço: %d | ',ponto,gumeslorenco1(ponto))

    for j=1:length(amostrasteste)

        amostras=amostrasteste(j);

        %% Gerar perfil pelo MATLAB

        dadoselev=dadoselevmatlab(lattx1,lontx1,latrx(ponto),lonrx(ponto),amostras);

        %% Aplicar correção do raio efetivo

        dadoselev=raioefetivo(dadoselev);

        %% Identificar gumes sem Fresnel

        [~,gumes]=indexgumess(dadoselev,alturat1,alturar,freq1,false);

        fprintf('%d:%d ',amostras,gumes)

    end

    fprintf('\n')

end

%% Testar Emissora 2

fprintf('\n')
fprintf('EMISSORA 2\n')
fprintf('\n')

for ponto=1:6

    fprintf('Ponto %d | Lorenço: %d | ',ponto,gumeslorenco2(ponto))

    for j=1:length(amostrasteste)

        amostras=amostrasteste(j);

        %% Gerar perfil pelo MATLAB

        dadoselev=dadoselevmatlab(lattx2,lontx2,latrx(ponto),lonrx(ponto),amostras);

        %% Aplicar correção do raio efetivo

        dadoselev=raioefetivo(dadoselev);

        %% Identificar gumes sem Fresnel

        [~,gumes]=indexgumess(dadoselev,alturat2,alturar,freq2,false);

        fprintf('%d:%d ',amostras,gumes)

    end

    fprintf('\n')

end