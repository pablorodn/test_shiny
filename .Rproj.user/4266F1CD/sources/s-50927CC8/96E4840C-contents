library(plumber)
library(safer)
library(DBI)
library(RMySQL)
library(plyr)

codifier="Ax200"
'%ni%'=Negate('%in%')

get_query = function(query){
  mydb = {try_default(dbConnect(
    RMySQL::MySQL(),
    host = "database-1.ckd1e3sk7dwp.us-east-1.rds.amazonaws.com",
    user = "admin",
    password =decrypt_string("hUtjYeT9C5cSg9LAEuXhreKc1x/m+A0E8A==",codifier),
    dbname="ab"),1,quiet = T)}
  tryCatch(
    expr = {
      if (toupper(Sys.info()[1][[1]]) != 'WINDOWS' ){
        dbGetQuery(mydb,"set names utf8")
      }
      query <- dbGetQuery(mydb,query)
    },
    finally = {
      try(dbDisconnect(mydb),silent = T)
    }
  )
  
  return(query)
}



#* Echo back the input
#* @param n The message to echo
#* @get /echo
function(n) {
  query=get_query(n)
  return(query)
}




