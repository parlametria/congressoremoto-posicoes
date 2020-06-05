read_votacoes <- function(){
    read_csv(
        here::here("data/votacoes.csv.gz"),
        col_types = cols(
            .default = col_character(),
            data = col_date(format = ""),
            dataHoraRegistro = col_datetime(format = ""),
            aprovacao = col_logical(),
            votosSim = col_double(),
            votosNao = col_double(),
            votosOutros = col_double(),
            ultimaAberturaVotacao_dataHoraRegistro = col_datetime(format = ""),
            ultimaApresentacaoProposicao_dataHoraRegistro = col_datetime(format = ""),
            ultimaApresentacaoProposicao_idProposicao = col_double(),
            nominal = col_logical(),
            tem_orientacao = col_logical(),
            tem_orientacao_gov = col_logical()
        )
    )
}
