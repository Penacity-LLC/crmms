## Install dssrip
```R
devtools::install_github("eheisman/DSS-Rip",args="--no-multiarch")
```

## NetCDF Usage
```R
library('convertdss')

dss_file = 'my_dss.dss'
nc_file = 'my_nc.nc'

dss = opendss(dss_file)

    # get all the dss paths, its more efficient to do this once at the 
    # beginning and pass it to each function
paths = getAllPaths(dss)
    # break apart the paths, this may take a minute for large files
    # if more than one path part uniquely define a variable, 
    # its important to specify that here
parts = separate_path_parts(paths,variable_parts=c('B','C'))

    # read out one variable to get the time range
v = read_dss_variable(parts$id_var[1],dss,parts)

    # initilize the netcdf file, make sure to use datetime 
    # range that covers the entire model period
nc = dss_to_ncdf_init(dss, v$data$datetime, nc_file=nc_file)
dss_to_netcdf(dss,nc,parts=parts)
close.nc(nc)
```


## SQLIte Usage
```R
library('convertdss')

dss_file = 'my_dss.dss'
db_file = 'my_db.db'

dss = opendss(dss_file)

    # get all the dss paths, its more efficient to do this once at the 
    # beginning and pass it to each function
paths = getAllPaths(dss)
    # break apart the paths, this may take a minute for large files
    # if more than one path part uniquely define a variable, 
    # its important to specify that here
parts = separate_path_parts(paths,variable_parts=c('B','C'))

    # initilize the netcdf file, make sure to use datetime 
    # range that covers the entire model period
db = dss_to_sqlite_init(dss, db_file=db_file)
dss_to_sqlite(dss,db,parts=parts)
dbDisconnect(db)
```