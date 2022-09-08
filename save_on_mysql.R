library(DBI)
library(RMySQL)
library(readr)
library(safer)
library(glue)
codifier="Ax200"
'%ni%'=Negate('%in%')

#Connect to test db
con=dbConnect(
  RMySQL::MySQL(),
  host = "database-1.ckd1e3sk7dwp.us-east-1.rds.amazonaws.com",
  user = "admin",
  password =decrypt_string("hUtjYeT9C5cSg9LAEuXhreKc1x/m+A0E8A==",codifier),
  dbname="ab"
)

multimedia <- read_csv("multimedia.csv")
#Read only the first 4 million of occurrences




list=list.files("/Users/pablorodriguez/Downloads/biodiversity-data/")

#Write on db
temp_m=data.frame()
for(i in 1:6){
df1=read_csv(paste0("/Users/pablorodriguez/Downloads/biodiversity-data/",list[i]))
df1=df1[,-1]
dbWriteTable(con,"chunked_occurence",df1,row.names = FALSE,append=T)
#Find the multimedia ids on dataset_occurence

#parameter=which(multimedia$CoreId %in% df1$id)
#temp=multimedia[parameter,]
#temp_m=rbind(temp_m,temp)
}

#Save the multimedia
dbWriteTable(con,"chunked_multimedia",temp_m,row.names = FALSE,append=T)




dbDisconnect(con)


