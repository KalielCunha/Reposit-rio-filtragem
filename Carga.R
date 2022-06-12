#Rotina para leitura e processamento de dados do anuÃ¡rio da Antaq

#Carregando e instalando pacotes
packages<-c('ggplot2','readxl','dplyr','readr', 'data.table','esquisse')
package.check <- lapply(packages, FUN = function(x) {
  if (!require(x, character.only = TRUE)) {
    install.packages(x, dependencies = TRUE)
    library(x, character.only = TRUE)
  }
})


#listando todas as tabelas auxiliares
{
  files<-list.files('input_data/brutos',
                    pattern = "Carga.txt",full.names = T,
                    recursive = T)
  atracacaofiles<-list.files('input_data/brutos',
                             pattern = "Atracacao.txt",full.names = T,
                             recursive = T)
  
  
  
  mercadoriamodificada <- read_delim("mercadoriamodificada.csv", 
                                     "\t", escape_double = FALSE, trim_ws = TRUE)

  
  iddestino<- read_delim("input_data/brutos/Instalacao_Destino.txt", 
                         ";", escape_double = FALSE, trim_ws = TRUE)
  iddestino<- iddestino%>%transmute(iddestino=Destino,
                                    pais_destino=`PaÃ­s Destino`)
  idorigem<-read_delim("input_data/brutos/Instalacao_Origem.txt", 
                       ";", escape_double = FALSE, trim_ws = TRUE)
  idorigem<- idorigem%>%transmute(idorigem= Origem,
                                  pais_origem= `PaÃ­s Origem`)
}
#Fazendo um loop para abrir todos os arquivos referentes aos anos para carga e atracacao
i=1
m<-list()
n<- list()
for(i in 1:length(files)){
  df<-read.table(files[i],sep=';',header=T,dec=',')
  df<-df%>%transmute(idcarga=Ã¯..IDCarga,
                     idatracacao=IDAtracacao,
                     idorigem=Origem,
                     iddestino=Destino,
                     cdmercadoria=CDMercadoria,
                     Acondicionamento = Carga.Geral.Acondicionamento,
                     ConteinerEstado=ConteinerEstado,
                     TipoNavegacao=Tipo.NavegaÃ.Ã.o,
                     NaturezaCarga=Natureza.da.Carga,
                     Sentido=Sentido,
                     peso=VLPesoCargaBruta,
                    )
  
  m[[i]] <- df
}

for(i in 1:length(atracacaofiles)){
  at<-read.table(atracacaofiles[i], header=T , dec=',',
                 sep = ";", fill= T)
  at<-at%>%transmute(idatracacao=Ã¯..IDAtracacao,
                     ano=Ano,
                     mes=Mes,
                     ComplexoPortuario=Complexo.PortuÃ.rio
  )
  n[[i]]<- at
} 
{
  ##transformando as listas em dataframes
  m <- do.call(rbind, m)
  n <- do.call(rbind, n)
}

{
  ##Surge a tabela principal "p" com junÃ§Ã£o de "m" e "n"
  p<-m
  p <- left_join(p , n, by= c("idatracacao"="idatracacao"))
  p <- left_join(p, mercadoriamodificada, by=c("cdmercadoria"="cdmercadoria"))
  p <- left_join(p, idorigem, by=c("idorigem"="idorigem"))
  p <- left_join(p, iddestino, by=c("iddestino"="iddestino"))
  p<- p%>%transmute(ano,
                    mes,
                    pais_destino,
                    pais_origem,
                    ComplexoPortuario,
                    nome_completo,
                    nomencl_simpl_mercadoria,
                    NaturezaCarga,
                    Acondicionamento,
                    ConteinerEstado,
                    TipoNavegacao,
                    Sentido,
                    peso)
  ##leftjoin e filtragem das colunas, formando um modelo estÃ¡vel de coluna
}
View(p)
save(p, file="tabelaP.rda")
