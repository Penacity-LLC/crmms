# convertdss

# Prerequisites 
1. **R** - [http://cran.r-project.org/]()
2. **Rtools** - [http://cran.r-project.org/bin/windows/Rtools/]() may not be necessary for you but good to have
3. **RStudio** - [https://www.rstudio.com/ide/download/]()
    - In the Rstudio options (Tools > Global Options), set the version of R to be 32-bit
   	- Open RStudio and install some necessary R packages (from within R): 
        `install.packages(c('devtools','lubridate','data.table','ggplot2'))`
    - dss-rip R package: 
        `devtools::install_github("dss-rip","eheisman",args="--no-multiarch")`
    - dplyr R package: 
        `devtools::install_github('dplyr')`
4. **DSSVue** - From HEC - [http://www.hec.usace.army.mil/software/hec-dssvue/downloads.aspx]()

_While DSS is 32 and 64 bit compatible, the interface to the DSS Java libraries in R only works with 32-bit R/DSS at this time. If you have issues, ensure you are using 32 bit R._

# Installation
## 
```R
devtools::install_github("usbr/convertdss",args="--no-multiarch")
```

## Install dssrip
```R
devtools::install_github("eheisman/DSS-Rip",args="--no-multiarch")
```

# Usage
## NetCDF Usage
```R
library('convertdss')

dss_file = system.file('sample.dss',package='convertdss')
nc_file = 'output.nc'

dss = opendss(dss_file)

    # get all the dss paths, its more efficient to do this once at the 
    # beginning and pass it to each function
paths = getAllPaths(dss)
    # break apart the paths, this may take a minute for large files
    # if more than one path part uniquely define a variable, 
    # its important to specify that here
parts = separate_path_parts(paths,variable_parts=LETTERS[1:3])

    # read out one variable to get the time range
v = read_dss_variable(parts$id_var[1],dss,parts)

    # initilize the netcdf file, make sure to use datetime 
    # range that covers the entire model period
dss_to_ncdf_init(dss, v$data$datetime, nc_file=nc_file, overwrite=TRUE)
dss_to_netcdf(dss,nc_file,parts=parts)
# no need to close the nc connection
dss$close()
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
dss$close()
```
