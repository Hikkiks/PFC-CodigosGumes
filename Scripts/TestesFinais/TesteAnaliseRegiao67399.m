clear
clc
close all

%% Definir caminhos

pastateste=fileparts(mfilename('fullpath'));

pasta12=fullfile(pastateste,'ResultadosVarredura12Casos');

arquivodados=fullfile(pasta12,'ResumoVarredura12CasosSemFresnel.csv');

if exist(arquivodados,'file')~=2
    error('O arquivo ResumoVarredura12CasosSemFresnel.csv não foi encontrado.')
end

%% Carregar dados

dados=readtable(arquivodados);

fprintf('\n')
fprintf('============================================================\n')
fprintf('CHECAGEM DA REGIÃO DA CONFIGURAÇÃO 67399\n')
fprintf('============================================================\n')
fprintf('Arquivo utilizado:\n')
fprintf('%s\n',arquivodados)
fprintf('\n')
fprintf('Configurações encontradas: %d\n',height(dados))

%% Localizar colunas

nomes=string(dados.Properties.VariableNames);

nomeconfig=localizacoluna(nomes,["Config" "Configuracao" "NumeroSerie"]);

nomeh=localizacoluna(nomes,["Limiteh" "h"]);

nomev=localizacoluna(nomes,["Limitev" "v"]);

nomeangulo=localizacoluna(nomes,["LimiteAnguloGraus" "LimiteAngulo" "Angulo"]);

nomedistancia=localizacoluna(nomes,["LimiteDistancia" "Distancia"]);

nomemae=localizacoluna(nomes,["MAEMedido" "MAE" "MAECampo" "MAEGiovaneli"]);

nomermse=localizacoluna(nomes,["RMSEMedido" "RMSE" "RMSECampo" "RMSEGiovaneli"]);

nomeerro=localizacoluna(nomes,["ErroMedioMedido" "ErroMedio" "MediaErroMedido" "MediaErroGiovaneli"]);

nomegumes=localizacoluna(nomes,["TotalGumes" "GumesFinais" "GumesTotais"]);

if nomeconfig==""
    error('A coluna de configuração não foi encontrada.')
end

if nomeh==""
    error('A coluna de h não foi encontrada.')
end

if nomev==""
    error('A coluna de v não foi encontrada.')
end

if nomeangulo==""
    error('A coluna de ângulo não foi encontrada.')
end

if nomedistancia==""
    error('A coluna de distância não foi encontrada.')
end

if nomemae==""

    fprintf('\n')
    fprintf('Colunas disponíveis:\n')

    disp(nomes')

    error('A coluna de MAE não foi encontrada.')

end

%% Mostrar colunas utilizadas

fprintf('\n')
fprintf('Colunas utilizadas:\n')
fprintf('Configuração: %s\n',nomeconfig)
fprintf('h:            %s\n',nomeh)
fprintf('v:            %s\n',nomev)
fprintf('Ângulo:       %s\n',nomeangulo)
fprintf('Distância:    %s\n',nomedistancia)
fprintf('MAE:          %s\n',nomemae)

if nomermse~=""
    fprintf('RMSE:         %s\n',nomermse)
end

if nomeerro~=""
    fprintf('Erro médio:   %s\n',nomeerro)
end

if nomegumes~=""
    fprintf('Gumes:        %s\n',nomegumes)
end

%% Analisar configuração 67399

config67399=dados(dados.(char(nomeconfig))==67399,:);

if isempty(config67399)==true
    error('A configuração 67399 não foi encontrada no arquivo.')
end

h67399=config67399.(char(nomeh))(1);

v67399=config67399.(char(nomev))(1);

angulo67399=config67399.(char(nomeangulo))(1);

distancia67399=config67399.(char(nomedistancia))(1);

mae67399=config67399.(char(nomemae))(1);

fprintf('\n')
fprintf('============================================================\n')
fprintf('CONFIGURAÇÃO 67399\n')
fprintf('============================================================\n')
fprintf('h:          %.4f m\n',h67399)
fprintf('v:          %.4f\n',v67399)
fprintf('Ângulo:     %.4f graus\n',angulo67399)

if isinf(distancia67399)==true

    fprintf('Distância:  Inf\n')

else

    fprintf('Distância:  %.2f m\n',distancia67399)

end

fprintf('MAE:        %.4f dB\n',mae67399)

if nomermse~=""
    fprintf('RMSE:       %.4f dB\n',config67399.(char(nomermse))(1))
end

if nomeerro~=""
    fprintf('Erro médio: %+.4f dB\n',config67399.(char(nomeerro))(1))
end

if nomegumes~=""
    fprintf('Gumes:      %.0f\n',config67399.(char(nomegumes))(1))
end

%% Localizar mesma parametrização sem limite de distância

tolerancia=10^-12;

mascaramesma=abs(dados.(char(nomeh))-h67399)<tolerancia;

mascaramesma=mascaramesma & abs(dados.(char(nomev))-v67399)<tolerancia;

mascaramesma=mascaramesma & abs(dados.(char(nomeangulo))-angulo67399)<tolerancia;

mascaramesma=mascaramesma & isinf(dados.(char(nomedistancia)));

mesmaparametrizacao=dados(mascaramesma,:);

fprintf('\n')
fprintf('============================================================\n')
fprintf('MESMOS h, v E ÂNGULO COM DISTÂNCIA SEM LIMITE\n')
fprintf('============================================================\n')

if isempty(mesmaparametrizacao)==true

    fprintf('Nenhuma configuração correspondente foi encontrada.\n')

else

    fprintf('Configuração: %d\n',mesmaparametrizacao.(char(nomeconfig))(1))
    fprintf('h:            %.4f m\n',mesmaparametrizacao.(char(nomeh))(1))
    fprintf('v:            %.4f\n',mesmaparametrizacao.(char(nomev))(1))
    fprintf('Ângulo:       %.4f graus\n',mesmaparametrizacao.(char(nomeangulo))(1))
    fprintf('Distância:    Inf\n')
    fprintf('MAE:          %.4f dB\n',mesmaparametrizacao.(char(nomemae))(1))

    if nomermse~=""
        fprintf('RMSE:         %.4f dB\n',mesmaparametrizacao.(char(nomermse))(1))
    end

    if nomeerro~=""
        fprintf('Erro médio:   %+.4f dB\n',mesmaparametrizacao.(char(nomeerro))(1))
    end

    if nomegumes~=""
        fprintf('Gumes:        %.0f\n',mesmaparametrizacao.(char(nomegumes))(1))
    end

    diferencamae=mesmaparametrizacao.(char(nomemae))(1)-mae67399;

    fprintf('\n')
    fprintf('Diferença de MAE em relação a 67399: %+.4f dB\n',diferencamae)

end

%% Definir região ao redor da configuração 67399

hmin=0.20;

hmax=0.30;

vmin=0.075;

vmax=0.10;

angulomin=0.50;

angulomax=1.00;

mascararegiao=isinf(dados.(char(nomedistancia)));

mascararegiao=mascararegiao & dados.(char(nomeh))>=hmin;

mascararegiao=mascararegiao & dados.(char(nomeh))<=hmax;

mascararegiao=mascararegiao & dados.(char(nomev))>=vmin;

mascararegiao=mascararegiao & dados.(char(nomev))<=vmax;

mascararegiao=mascararegiao & dados.(char(nomeangulo))>=angulomin;

mascararegiao=mascararegiao & dados.(char(nomeangulo))<=angulomax;

regiao=dados(mascararegiao,:);

regiao=sortrows(regiao,char(nomemae),'ascend');

%% Mostrar estatísticas da região

fprintf('\n')
fprintf('============================================================\n')
fprintf('REGIÃO AO REDOR DA 67399 COM DISTÂNCIA = Inf\n')
fprintf('============================================================\n')
fprintf('h:      %.3f a %.3f m\n',hmin,hmax)
fprintf('v:      %.3f a %.3f\n',vmin,vmax)
fprintf('Ângulo: %.3f a %.3f graus\n',angulomin,angulomax)
fprintf('\n')
fprintf('Configurações encontradas: %d\n',height(regiao))

if isempty(regiao)==false

    valoresmae=regiao.(char(nomemae));

    fprintf('\n')
    fprintf('Menor MAE:    %.4f dB\n',min(valoresmae))
    fprintf('Q25 do MAE:   %.4f dB\n',prctile(valoresmae,25))
    fprintf('Mediana MAE:  %.4f dB\n',median(valoresmae))
    fprintf('Média MAE:    %.4f dB\n',mean(valoresmae))
    fprintf('Q75 do MAE:   %.4f dB\n',prctile(valoresmae,75))
    fprintf('Maior MAE:    %.4f dB\n',max(valoresmae))

    fprintf('\n')
    fprintf('Diferença entre melhor MAE da região e 67399: %+.4f dB\n',min(valoresmae)-mae67399)
    fprintf('Diferença entre mediana da região e 67399:    %+.4f dB\n',median(valoresmae)-mae67399)

end

%% Avaliar cobertura de bom desempenho

if isempty(regiao)==false

    limite025=mae67399+0.25;

    limite050=mae67399+0.50;

    limite100=mae67399+1.00;

    quantidade025=sum(regiao.(char(nomemae))<=limite025);

    quantidade050=sum(regiao.(char(nomemae))<=limite050);

    quantidade100=sum(regiao.(char(nomemae))<=limite100);

    fprintf('\n')
    fprintf('============================================================\n')
    fprintf('COBERTURA DE BOM DESEMPENHO NA REGIÃO\n')
    fprintf('============================================================\n')
    fprintf('MAE até 0.25 dB acima da 67399: %d de %d\n',quantidade025,height(regiao))
    fprintf('MAE até 0.50 dB acima da 67399: %d de %d\n',quantidade050,height(regiao))
    fprintf('MAE até 1.00 dB acima da 67399: %d de %d\n',quantidade100,height(regiao))

    fprintf('\n')
    fprintf('Percentual até +0.25 dB: %.2f %%\n',100*quantidade025/height(regiao))
    fprintf('Percentual até +0.50 dB: %.2f %%\n',100*quantidade050/height(regiao))
    fprintf('Percentual até +1.00 dB: %.2f %%\n',100*quantidade100/height(regiao))

end

%% Mostrar melhores configurações da região

quantidademostrar=min(30,height(regiao));

fprintf('\n')
fprintf('============================================================\n')
fprintf('%d MELHORES CONFIGURAÇÕES DA REGIÃO\n',quantidademostrar)
fprintf('============================================================\n')

if quantidademostrar>0

    variaveis=[nomeconfig nomeh nomev nomeangulo nomedistancia nomemae];

    if nomermse~=""
        variaveis=[variaveis nomermse];
    end

    if nomeerro~=""
        variaveis=[variaveis nomeerro];
    end

    if nomegumes~=""
        variaveis=[variaveis nomegumes];
    end

    disp(regiao(1:quantidademostrar,cellstr(variaveis)))

end

%% Salvar região analisada

arquivosaida=fullfile(pasta12,'Regiao67399SemLimiteDistancia.csv');

writetable(regiao,arquivosaida);

fprintf('\n')
fprintf('============================================================\n')
fprintf('RESULTADO SALVO\n')
fprintf('============================================================\n')
fprintf('%s\n',arquivosaida)
fprintf('============================================================\n')

%% Localizar coluna pelo nome

function nome=localizacoluna(nomes,candidatos)

nome="";

for i=1:length(candidatos)

    indice=find(strcmpi(nomes,candidatos(i)),1);

    if isempty(indice)==false

        nome=nomes(indice);

        return

    end

end

end