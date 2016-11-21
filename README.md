# download.uspto.data
This repository contains the Rpackage "download.uspto.data" which provides a function called "download.uspto.data" to download patent data from the USPTO bulk data storage system.

The function "download.uspto.data" enables you to efficiently download biliographic and/or full text data from the USPTO data base. The function allows you to choose which type of data you want to download (bibliographic or full text), from which years you want to download data, and which types of files you would like to download. 

Here follows the function description: 

The function download.uspto.data downloads bibliographic or full text patent data from the USPTO database. Bibliographic data contains front page information from each patent that was issued by the uspto from 1976 until present. Full text data contains the full text of each patent grant issued weekly from 1976 to present. The function creates directories in your home directory which correspond to the data types and file types. Before downloading, the function will check whether the required data is already in the folder, if this is not the case, the data will be downloaded and stored in the corresponding folder.

Here follow instructions which are needed to install the package: 

- Download the package from this github repository. 
- Install the package devtools -> install.packages("devtools")
- load the package devtools -> library("devtools")
- The directory which contains the package download.uspto.data is set as working directory -> setwd("pathtopackagedir")
- Install the package download.uspto.data  -> install("download.uspto.data")
- load the package download.uspto.data -> library("download.uspto.data")

To get more information about the function, how to use it and some extra help -> help("download.uspto.data")


