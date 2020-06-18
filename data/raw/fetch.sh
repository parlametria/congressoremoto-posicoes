#!/bin/bash
set -euo pipefail

targets="votacoesVotos-2019.csv votacoes-2020.csv"
for f in $targets; do
	URL=https://dadosabertos.camara.leg.br/arquivos/votacoesVotos/csv/$f
	echo "Baixando $URL"
	curl $URL --output $f 
done

targets="votacoesOrientacoes-2020.csv votacoesOrientacoes-2019.csv"
for f in $targets; do
	URL=https://dadosabertos.camara.leg.br/arquivos/votacoesOrientacoes/csv/$f
	echo "Baixando $URL"
	curl $URL --output $f 
done

targets="votacoesVotos-2020.csv votacoesVotos-2019.csv"
for f in $targets; do
	URL=https://dadosabertos.camara.leg.br/arquivos/votacoesVotos/$f
	echo "Baixando $URL"
	curl $URL --output $f 
done

curl -O https://dadosabertos.camara.leg.br/arquivos/votacoesObjetos/csv/votacoesObjetos-2020.csv
curl -O https://dadosabertos.camara.leg.br/arquivos/votacoesObjetos/csv/votacoesObjetos-2019.csv

targets=`seq 1990 2020`
for f in $targets; do
        curl -O https://dadosabertos.camara.leg.br/arquivos/proposicoesTemas/csv/proposicoesTemas-$f.csv
done

targets=`seq 1990 2020`
for f in $targets; do
        curl -O https://dadosabertos.camara.leg.br/arquivos/votacoesProposicoes/csv/votacoesProposicoes-$f.csv
done
