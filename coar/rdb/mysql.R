
require(RMySQL)

Sys.setlocale("LC_ALL","C") 

db.host <- "127.0.0.1"
db.port <- 1505
db.name <- "coar"
db.user <- "root"
db.pass <- ""

execute.select <- function(query) {
        db <- dbConnect(MySQL(), user=db.user, host=db.host, port = db.port, dbname = db.name)
        rs <- dbSendQuery(db, query)
        dt <- dbFetch(rs, n = -1)
        dbClearResult(rs)
        dbDisconnect(db)
        return(dt)
}

