#' Initilizes a sqlite database to recieve dss data
#' 
#' Uses an open dss file. A time dimension is defined with a corresponding 
#' 
#' It is important that all the times be defined before any data gets written,
#' 
#' 
#' 
#' 
#' 
#' 
#' @param dss a dss file object from \code{\link[dssrip]{opendss}}
#' @param db_file 
#' @param overwrite 
#'                  
#' 
#' @return An SQLite file handle
#' @author Cameron Bracken
#' @export 
dss_to_sqlite_init <- function(dss,db_file='convertdss.db',overwrite=TRUE){
    
    if(overwrite) if(file.exists(db_file)) unlink(db_file)

    # create a SQLite instance and create one connection.
    m = dbDriver("SQLite")
    db = dbConnect(m,db_file)

    # holds variable names (same as table names) 
    res = dbSendQuery(db, "CREATE TABLE variables  (  
        var_name  nvarchar(128) primary key, 
        description  nvarchar(2048)  not null default '',
        notes  nvarchar(2048)  not null default '');")
    dbClearResult(res)

    # holds data flags
    res = dbSendQuery(db, "CREATE TABLE flags  (  
        flag  nvarchar(50) primary key, 
        description  nvarchar(2048)  not null default '');")
    dbClearResult(res)

    # holds variable attributes
    res = dbSendQuery(db, "CREATE TABLE attributes  (  
        var_name  nvarchar(128)  not null, 
        attribute_name  nvarchar(128)  not null, 
        value  nvarchar(2048)  not null default '',
        notes  nvarchar(2048)  not null default '');")
    dbClearResult(res)
    
    # 
    res = dbSendQuery(db, "CREATE TABLE attribute_descriptions  (  
        attribute_name  nvarchar(128) primary key, 
        description  nvarchar(2048)  not null default '');")
    dbClearResult(res)

    return(db)
}

#' Writes a dss variable to an existing sqlite file
#' 
#' Uses the output of read_dss_variable, creating a new table in an _existing_
#' sqlite file
#' 
#' @param v a variable object returned by \code{\link{read_dss_variable}}
#' @param db A RSQLite file handle set up by \code{\link{dss_to_sqlite_init}}
#' 
#' @return TRUE if the write was successful, false otherwise
#' @author Cameron Bracken
#' @export 
dss_var_to_sqlite <- function(v, db){

    md = lapply(v$metadata,as.character)

    var = v$variable
    data = v$data
    data$flag = '' 
    data[,datetime:=format(datetime, '%Y-%m-%d %H:%M:%S UTC')]

    # write the data
    success = dbWriteTable(db, var, data, row.names=FALSE)

    if(success){
        res = dbSendQuery(db, sprintf("INSERT INTO variables (var_name) VALUES('%s');", var))
        dbClearResult(res)

        # add the metadata
        for(m in names(md)){
            res = dbSendQuery(db, 
                sprintf("INSERT INTO attributes VALUES('%s', '%s', '%s', '');", var, m, md[[m]]))
            dbClearResult(res)
        }
    }
    return(success)
}

#' Convert dss to sqlite
#' 
#' This function does the bulk of the work to convert dss data to sqlite,
#' 
#' 
#' 
#' 
#'
#' @param dss a dss file handle, from opendss
#' @param db a sqlite file handle, from dss_to_sqlite_init
#' 
#' @return Outputs a Sqlite file
#' @note NOTE
#' @author Cameron Bracken
#' @seealso \code{\link[dssrip]{opendss}}, \code{\link{dss_to_sqlite_init}}
#' @export 
dss_to_sqlite <- function(dss, db, parts=NULL, variable_parts='B'){

    if(is.null(parts))
        parts = separate_path_parts(getAllPaths(dss),variable_parts)
    dss_variables = unique(parts$id_var)

    lapply(dss_variables, function(var)
        dss_var_to_sqlite(read_dss_variable(var, dss, parts, variable_parts), db))


}