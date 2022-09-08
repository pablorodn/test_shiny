
# Read SQL query or database table into a DataFrame
# parameters
# server: the merqueo server  to consult ('prod', 'shiny', 'dwh').
# query: str SQL query to be executed or a table name.

get_query <- function(query){
  #' @description Read SQL query or database table into a DataFrame
  #' @param query: str SQL query to be executed or a table name.
  
  request <- GET("http://54.159.47.24:8000/echo",
                 query = list(n=query),
                 encode = "json")
  data <- content(request, as = 'text', encoding = 'UTF-8')
  result <- as.data.frame(fromJSON(data))
  return(result)
}
