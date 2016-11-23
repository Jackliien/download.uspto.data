
#' download.uspto.data
#'
#' The function download.uspto.data downloads bibliographic or full text patent data from the USPTO database.
#' Bibliographic data contains front page information from each patent that was issued by the uspto from 1976 until present. Full text data contains the full text of each patent grant issued weekly from 1976 to present.
#' The function creates directories in your home directory which correspond to the data types and file types. Before downloading, the function will check whether the required data is allready in the folder, if this is not the case,
#' the data will be downloaded and stored in the corresponding folder.
#'
#' @param data.type Specify the data type you want to download. For bibliographic the argument is "bibl". For full text data the argument is "full".
#' @param file.type Specify the type of file you want to download. The arguments for bibliographic data are "ipgb", "pgb", and "pba". The arguments for Full text data are "pftaps", "pg", and "ipg".
#' @param sample Specify the years from which you want to download the data. Note that you need to use "parentheses".
#' @export
#' @details When entering the sample, parentheses need to included; in example "2016". When the sample consists of multiple years specify the argument like this: "2015|2016|2017".
#'
#' The function makes use of a configuration file with a yaml extention. This configuration file needs to be stored in the home directory and needs to have this specific name: "intera.config.yml".
#' The configuration file contains user specific paths to specific directories where the data are stored. The configuration file consists of keys and values. Each line of the configuration file contains "key: value". The key represents an object in R (which is the name of a directory), the value is the path to this directory.



download.uspto.data <- function(data.type = NA, file.type = NA, sample = NA) {

  packages <- c("RCurl"
                , "XML"
                , "pbapply"
                , "markdown"
                , "yaml"
                , "magrittr")

  package.check <- lapply(packages, FUN = function(x) {
    if (!require(x, character.only = TRUE)) {
      install.packages(x
                       , repos = 'http://cloud.r-project.org'  # This prevents from repository prompt
                       , dependencies = TRUE)
      library(x, character.only = TRUE)}
  })



  ## Load configuration file
  config.file.path <- path.expand(file.path("~", "intera.config.yml", fsep ="\\"))
  config <- yaml.load_file("intera.config.yml")


  ## Create directories
  dir.create(config$maindir)                     # When the directories  are missing,
  dir.create(config$subdir.bibl)
  dir.create(config$subdir.full)
  dir.create(config$bibl.ipgb)
  dir.create(config$bibl.pgb)
  dir.create(config$bibl.pba)
  dir.create(config$full.pftaps)
  dir.create(config$full.pg)
  dir.create(config$full.ipg)

  ## Specifications
  uspto.index.html <- getURL("https://bulkdata.uspto.gov/")

  data.type.parser.list <- list(
    bibl = "(?<=<a href=\")https://bulkdata.uspto.gov/data2/patent/grant/redbook/bibliographic/.*?(?=\">)"
    , full = "(?<=<a href=\")https://bulkdata.uspto.gov/data2/patent/grant/redbook/fulltext/.*?(?=\">)"
    , biblzip = "(?<=<tr><td align=\"left\" width=\"20%\"><a href=\").*?(?=\">)"
    , fullzip = "(?<=<tr><td align=\"left\" width=\"(20%|22%)\"><a href=\").*?(?=\">)")


  file.type.parser.list <- list(
    bibl.ipgb = "(ipgb)(.*)(?=_w)"
    , bibl.pgb  = "(/pgb)(.*)(?=_w)"
    , bibl.pba  = "(pba)(.*)(?=_w)"
    , bibl.dat = "???"
    , full.pftaps = "(pftaps)(.*)(?=.zip)"
    , full.pg = "(/pg)(.*)(?=.zip)"
    , full.ipg = "(ipg)(.*)(?=.zip)")


  ## Select type of data

  if(data.type == "bibl") data.type.parser <- data.type.parser.list$bibl
  if(data.type == "full") data.type.parser <- data.type.parser.list$full

  ## Download list of htmls with paths to zip files
  files.lists.html <- gregexpr(data.type.parser
                               , uspto.index.html
                               , perl = TRUE) %>%
    regmatches(uspto.index.html, .) %>%
    getElement(1) %>%
    paste0("/") %>%
    pbsapply(getURL)

  ## Get a list of urls to the zipfiles

  if(data.type == "bibl") parser.zipnames <- data.type.parser.list$biblzip
  if(data.type == "full") parser.zipnames <- data.type.parser.list$fullzip

  zip.names.list <- gregexpr(parser.zipnames
                             , files.lists.html
                             , perl = T) %>%
    regmatches(files.lists.html, .)

  zip.url.list <- pbsapply(names(zip.names.list)
                           , function(x) {
                             paste0(x, zip.names.list[[x]])
                           }) %>% unlist()

  ## the list contains some bugs that need to be removed.
  ## For bibl we filter like this:

  zips.url.ipgb.list <- grep("ipgb\\d+_wk\\d+[.]zip$"  #ipgb files
                             , zip.url.list
                             , value = TRUE)

  zips.url.pgb.list <- grep("/pgb"   #pgb files
                            , zip.url.list
                            , value = TRUE)

  #2001 is double in the database and therefore double in this list
  duplicated(zips.url.pgb.list)
  zips.url.pgb.list <- zips.url.pgb.list[1:209]

  zips.url.pba.list <- grep("pba"   #pba files
                            , zip.url.list
                            , value = TRUE)

  parser.one.zip <- "1995|1994|1993|1992|1991|1990|1989|1988|1987|1986|1987|1986|1985|1984|1983|1982|1981|1980|1979|1978|1977|1976"
  one.zip.per.year <- grep(parser.one.zip  # Creates a list of urls which contain one zip (dat files).
                           , zip.url.list
                           , value = TRUE)

  if(data.type == "bibl") zips.url.cleaned.list <- c(zips.url.ipgb.list, zips.url.pgb.list, zips.url.pba.list, one.zip.per.year)

  ## For full text we filter like this:

  zips.url.pftaps.list <- grep("pftaps"  #pftaps files
                               , zip.url.list
                               , value = TRUE)

  zips.url.pg.list <- grep("/pg"   #pg files
                           , zip.url.list
                           , value = TRUE)

  duplicated(zips.url.pg.list)
  zips.url.pg.list <- zips.url.pg.list[1:209]

  zips.url.ipg.list <- grep("ipg"   #ipg files
                            , zip.url.list
                            , value = TRUE)

  if(data.type == "full") zips.url.cleaned.list <- c(zips.url.pftaps.list, zips.url.pg.list, zips.url.ipg.list)

  ## These objects are just for the RMarkdown script
  biblio.zips.url.cleaned.list <- c(zips.url.ipgb.list, zips.url.pgb.list, zips.url.pba.list, one.zip.per.year)
  fulltext.zips.url.cleaned.list <- c(zips.url.pftaps.list, zips.url.pg.list, zips.url.ipg.list)

  ## Sampling the years that you are interested in


  zips.url.cleaned.list <- grep(sample, zips.url.cleaned.list, perl=TRUE, value=TRUE)

  ## Extracting the zipnames from the urls to check whether they already exist in the directory.

  if(file.type == "ipgb") parser <- file.type.parser.list$bibl.ipgb
  if(file.type == "pgb") parser <- file.type.parser.list$bibl.pgb
  if(file.type == "pba") parser <- file.type.parser.list$bibl.pba
  if(file.type == "pftaps") parser <- file.type.parser.list$full.pftaps
  if(file.type == "pg") parser <- file.type.parser.list$full.pg
  if(file.type == "ipg") parser <- file.type.parser.list$full.ipg
  ##TODO: add dat files


  names.list <- gregexpr(parser
                         , zips.url.cleaned.list
                         , perl = TRUE) %>%
    regmatches(zips.url.cleaned.list
               , .) # This gives a list of all the filenames in your sample.



  if(file.type == "ipgb") {subDir <- config$bibl.ipgb
  files.list <- paste0(names.list
                       , ".xml")
  setwd(config$bibl.ipgb)}
  if(file.type == "pgb")  {subDir <- config$bibl.pgb
  files.list <-  paste0(names.list
                        , ".xml")  %>% substr(., 2, 16)
  setwd(config$bibl.pgb)}
  if(file.type == "pba")  {subDir <- config$bibl.pba
  files.list <- paste0(names.list
                       , ".txt")
  setwd(config$bibl.pba)}
  if(file.type == "pftaps") { subDir <- config$full.pftaps
  files.list <- paste0(names.list
                       , ".txt")
  setwd(config$full.pftaps)}
  if(file.type == "pg")   {subDir <- config$full.pg
  files.list <- paste0(names.list
                       , ".xml")    %>% substr(., 2, 16)
  setwd(config$full.pg)}
  if(file.type == "ipg")  {subDir <- config$full.ipg
  files.list <- paste0(names.list
                       , ".xml")
  setwd(config$full.ipg)}


  existence.check <- file.exists(files.list)    # Check whether the files are already in the folder.
  index <- which(existence.check == FALSE)      # A list containing the index numbers of the urls that need to be downloaded.
  zips.sample <- zips.url.cleaned.list[index]   # The selection of the urls that need to be downloaded.



  for (i in zips.sample) {
    tf <- tempfile()                                                    # Create a temporary file
    download.file(i, tf, mode = "wb")                                   # Download the zip into the temporary file
    unzip(tf, exdir = subDir)                                           # Unzip the content of the temporary file and
    file.remove(tf)                                                     # save the content in the sub directory.
                                                                        # Select the files in the subDir that are .html and .txt (These need to be deleted since we're only interested in xml files)
    if(file.type == "ipgb") {id <- grep(".html|.txt", dir(config$bibl.ipgb))
                             todelete <- dir(config$bibl.ipgb, full.names = TRUE)[id]}
    if(file.type == "pgb")  {id <- grep(".txt", dir(config$bibl.pgb))
                             todelete <- dir(config$bibl.pgb, full.names = TRUE)[id]}
    if(file.type == "pg")   {id <- grep(".sgm", dir(config$full.pg))
                             todelete <- dir(config$full.pg, full.names = TRUE)[id]}
    else id <- NA
                         # Delete all the files in the subdir that are not .xml
    unlink(todelete)
    setwd("~/")
}
}
