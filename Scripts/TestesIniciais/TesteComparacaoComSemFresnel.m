clear
clc
close all

%% Definir caminhos

pastateste=fileparts(mfilename('fullpath'));

pastascripts=fileparts(pastateste);

addpath(fullfile(pastascripts,'Funções'))

pastaconclusao=fullfile(pastascripts,'DadosSalvos','DadosConclusao');

%% Definir parâmetros gerais

alturar=1.5;

%% Definir parâmetros da Emissora 1

freq1=557.142857*10^6;

alturat1=76.2;

gumeslorenco1=[3 3 4 3 3 2];

%% Definir parâmetros da Emissora 2

freq2=581.142857*10^6;

alturat2=113;

gumeslorenco2=[2 2 3 3 3 1];

%% Preparar resultados

semfresnel1=zeros(1,6);

comfresnel1=zeros(1,6);

semfresnel2=zeros(1,6);

comfresnel2=zeros(1,6);

%% Testar Emissora 1

for i=1:6

    nomearquivo=['DadosConclusaoE1P' num2str(i) '.mat'];

    caminhoarquivo=fullfile(pastaconclusao,nomearquivo);

    load(caminhoarquivo,'dadoselev');

    %% Aplicar correção do raio efetivo

    dadoselev=raioefetivo(dadoselev);

    %% Identificar gumes sem Fresnel

    [~,gumes]=indexgumess(dadoselev,alturat1,alturar,freq1,false);

    semfresnel1(i)=gumes;

    %% Identificar gumes com Fresnel

    [~,gumes]=indexgumess(dadoselev,alturat1,alturar,freq1,true);

    comfresnel1(i)=gumes;

end

%% Testar Emissora 2

for i=1:6

    nomearquivo=['DadosConclusaoE2P' num2str(i) '.mat'];

    caminhoarquivo=fullfile(pastaconclusao,nomearquivo);

    load(caminhoarquivo,'dadoselev');

    %% Aplicar correção do raio efetivo

    dadoselev=raioefetivo(dadoselev);

    %% Identificar gumes sem Fresnel

    [~,gumes]=indexgumess(dadoselev,alturat2,alturar,freq2,false);

    semfresnel2(i)=gumes;

    %% Identificar gumes com Fresnel

    [~,gumes]=indexgumess(dadoselev,alturat2,alturar,freq2,true);

    comfresnel2(i)=gumes;

end

%% Mostrar resultados da Emissora 1

fprintf('\n')
fprintf('=============================================================\n')
fprintf('                         EMISSORA 1\n')
fprintf('=============================================================\n')
fprintf('Ponto | Sem Fresnel | Com Fresnel | Lorenço | Fresnel adiciona\n')
fprintf('-------------------------------------------------------------\n')

for i=1:6

    diferenca=comfresnel1(i)-semfresnel1(i);

    fprintf('%5d | %11d | %11d | %7d | %15d\n',i,semfresnel1(i),comfresnel1(i),gumeslorenco1(i),diferenca)

end

fprintf('=============================================================\n')

%% Mostrar resultados da Emissora 2

fprintf('\n')
fprintf('=============================================================\n')
fprintf('                         EMISSORA 2\n')
fprintf('=============================================================\n')
fprintf('Ponto | Sem Fresnel | Com Fresnel | Lorenço | Fresnel adiciona\n')
fprintf('-------------------------------------------------------------\n')

for i=1:6

    diferenca=comfresnel2(i)-semfresnel2(i);

    fprintf('%5d | %11d | %11d | %7d | %15d\n',i,semfresnel2(i),comfresnel2(i),gumeslorenco2(i),diferenca)

end

fprintf('=============================================================\n')

%% Comparar coincidências com Lorenço

acertossem1=sum(semfresnel1==gumeslorenco1);

acertoscom1=sum(comfresnel1==gumeslorenco1);

acertossem2=sum(semfresnel2==gumeslorenco2);

acertoscom2=sum(comfresnel2==gumeslorenco2);

fprintf('\n')
fprintf('RESUMO\n')
fprintf('-------------------------------------------------------------\n')
fprintf('Emissora 1 - Sem Fresnel: %d de 6 iguais ao Lorenço\n',acertossem1)
fprintf('Emissora 1 - Com Fresnel: %d de 6 iguais ao Lorenço\n',acertoscom1)
fprintf('\n')
fprintf('Emissora 2 - Sem Fresnel: %d de 6 iguais ao Lorenço\n',acertossem2)
fprintf('Emissora 2 - Com Fresnel: %d de 6 iguais ao Lorenço\n',acertoscom2)
fprintf('\n')
fprintf('Total - Sem Fresnel: %d de 12 iguais ao Lorenço\n',acertossem1+acertossem2)
fprintf('Total - Com Fresnel: %d de 12 iguais ao Lorenço\n',acertoscom1+acertoscom2)

%% Mostrar gumes acrescentados pelo Fresnel

adicionados1=comfresnel1-semfresnel1;

adicionados2=comfresnel2-semfresnel2;

fprintf('\n')
fprintf('Gumes adicionais causados pelo Fresnel\n')
fprintf('-------------------------------------------------------------\n')
fprintf('Emissora 1: ')

fprintf('%d ',adicionados1)

fprintf('\n')

fprintf('Emissora 2: ')

fprintf('%d ',adicionados2)

fprintf('\n')

fprintf('Total de gumes adicionais: %d\n',sum(adicionados1)+sum(adicionados2))