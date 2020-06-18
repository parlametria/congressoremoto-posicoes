library(tidyverse)
library(here)
library(lubridate)


cols_votacoes = cols(
  .default = col_character(),
  data = col_date(format = ""),
  dataHoraRegistro = col_datetime(format = ""),
  aprovacao = col_logical(),
  votosSim = col_integer(),
  votosNao = col_integer(),
  votosOutros = col_integer(),
  ultimaAberturaVotacao_dataHoraRegistro = col_datetime(format = ""),
  ultimaApresentacaoProposicao_dataHoraRegistro = col_datetime(format = "")
)

cols_votos = cols(.default = col_character(),
                  dataHoraVoto = col_datetime(format = ""))

cols_orientacao = cols(.default = col_character())

cols_temas = cols(
  .default = col_character(),
  ano = col_double(),
  relevancia = col_double()
)

cols_objetos = cols(
  .default = col_character(),
  data = col_date(format = ""),
  proposicao_ano = col_double()
)

cols_proposicoes = cols(
  .default = col_character(),
  data = col_date(format = ""),
  proposicao_ano = col_double()
)


read_bind_raws = function(f, columns) {
  read_raw = function(f, columns) {
    read_csv2(here::here("data/raw/", f), col_types = columns)
  }
  f %>%
    map(read_raw, columns) %>%
    reduce(bind_rows)
}


#### LER OS ARQUIVOS

votacoes = c("votacoes-2020.csv", "votacoes-2019.csv") %>%
  read_bind_raws(cols_votacoes)

votos = c("votacoesVotos-2020.csv", "votacoesVotos-2019.csv") %>%
  read_bind_raws(columns = cols_votos) %>%
  select(-deputado_urlFoto,-deputado_idLegislatura)

orientacoes = c("votacoesOrientacoes-2020.csv",
                "votacoesOrientacoes-2019.csv") %>%
  read_bind_raws(columns = cols_orientacao)

temas = paste0("proposicoesTemas-", 1990:2020, ".csv") %>%
  read_bind_raws(cols_temas)

objetos = c("votacoesObjetos-2019.csv", "votacoesObjetos-2020.csv") %>%
  read_bind_raws(cols_objetos)

afetadas = paste0("votacoesProposicoes-", 1990:2020, ".csv") %>%
  read_bind_raws(cols_proposicoes)

#### LIMPAR E CRUZAR

votacoes = votacoes %>%
  mutate(nominal = votosSim + votosNao > 100)

orientacoes = orientacoes %>%
  mutate(siglaBancada = if_else(siglaBancada %in% c("GOV.", "Governo"), "Governo", siglaBancada))

LIDER_GOVERNO = 179587 # Major Vitor Hugo
votos_lider = votos %>%
  filter(deputado_id == LIDER_GOVERNO) %>%
  select(idVotacao, uriVotacao, orientacao = voto) %>%
  mutate(
    prioridade_orientacao = 9,
    siglaBancada = "Governo",
    fonte_orientacao = "Líder"
  )

orientacoes = orientacoes %>%
  mutate(fonte_orientacao = "Bancada",
         prioridade_orientacao = 10) %>%
  bind_rows(votos_lider) %>%
  group_by(idVotacao, siglaBancada) %>%
  top_n(1, prioridade_orientacao) %>%
  select(-siglaOrgao,-uriBancada,-descricao) %>%
  ungroup()

votacoes_orientadas = votacoes %>%
  left_join(orientacoes, by = c("id" = "idVotacao")) %>%
  group_by(id,
           uri) %>%
  summarise(tem_orientacao = any(!is.na(siglaBancada)), 
            tem_orientacao_gov = any(siglaBancada == "Governo", na.rm = T))

votacoes = votacoes %>% 
  left_join(votacoes_orientadas)


### SALVAR 

votos %>% 
  readr::write_csv(here::here("data", "votos.csv"))

votacoes %>% 
  readr::write_csv(here::here("data", "votacoes.csv"))

orientacoes %>% 
  readr::write_csv(here::here("data", "orientacoes.csv"))

temas %>% 
  readr::write_csv(here::here("data", "temas.csv"))

objetos %>% 
  readr::write_csv(here::here("data", "objetos.csv"))

afetadas %>% 
  readr::write_csv(here::here("data", "proposicoes-afetadas.csv"))

