# download.uspto.data
This repository contains the Rpackage "download.uspto.data" which provides a function called "download.uspto.data" to download patent data from the USPTO bulk data storage system (https://bulkdata.uspto.gov/). 

The function "download.uspto.data" enables you to efficiently download biliographic and/or full text data from the USPTO data base. The function allows you to choose which type of data you want to download (bibliographic or full text), from which years you want to download data, and which types of files you would like to download.  

## function description: 

The function download.uspto.data downloads bibliographic or full text patent data from the USPTO database. Bibliographic data contains front page information from each patent that was issued by the uspto from 1976 until present. Full text data contains the full text of each patent grant issued weekly from 1976 to present. The function creates directories in your home directory which correspond to the data types and file types. Before downloading, the function will check whether the required data is already in the folder, if this is not the case, the data will be downloaded and stored in the corresponding folder.

## Instructions to install the package: 

- Download the package from this github repository. 
- Install the package devtools -> install.packages("devtools")
- load the package devtools -> library("devtools")
- The directory which contains the package download.uspto.data is set as working directory -> setwd("pathtopackagedir")
- Install the package download.uspto.data  -> install("download.uspto.data")
- load the package download.uspto.data -> library("download.uspto.data")

The package can also be installed directly from this github repository: 

- library(devtools)
- install_github("Jackliien/download.uspto.data")

To get more information about the function, how to use it and some extra help -> help("download.uspto.data")

## Below follows a description of the two parts of the database:

Bibliographic data
1976 to 1995 contains dat files
1996 to 2000 is of the file type pba and contains text files
2001 to 2004 is of the file type pgb and contains xml files and text files
2005 to present is of the file type ipgb and contains xml files, text files, and an html link

Full text data 
1976 to 2001 is of the file type pftaps and contains text files
2001 to 2004 is of the file type pg and contains sgm files and xml files
2005 to 2016 is of the file type ipg and contains xml files
