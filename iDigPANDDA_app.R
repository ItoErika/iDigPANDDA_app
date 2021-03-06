# Custom functions are camelCase. Arrays, parameters, and arguments are PascalCase
# Dependency functions are not embedded in master functions
# []-notation is used wherever possible, and $-notation is avoided.

######################################### Load Required Libraries ###########################################
# Check if libraries are installed. Install if necessary. Load
if (require("RCurl",warn.conflicts=FALSE)==FALSE) {
    install.packages("RCurl",repos="http://cran.cnr.berkeley.edu/");
    library("RCurl");
    }
    
if (require("RJSONIO",warn.conflicts=FALSE)==FALSE) {
    install.packages("RJSONIO",repos="http://cran.cnr.berkeley.edu/");
    library("RJSONIO");
    }

if (require("stringdist",warn.conflicts=FALSE)==FALSE) {
    install.packages("stringdist",repos="http://cran.cnr.berkeley.edu/");
    library("stringdist");
    }

if (require("doParallel",warn.conflicts=FALSE)==FALSE) {
    install.packages("doParallel",repos="http://cran.cnr.berkeley.edu/");
    library("doParallel");
    }

if (require("plyr",warn.conflicts=FALSE)==FALSE) {
    install.packages("plyr",repos="http://cran.cnr.berkeley.edu/");
    library("plyr");
    }

# Start a cluster for multicore, 4 by default or higher if passed as command line argument
CommandArgument<-commandArgs(TRUE)
if (length(CommandArgument)==0) {
    Cluster<-makeCluster(3)
    } else {
    Cluster<-makeCluster(as.numeric(CommandArgument[1]))
    }

# Establish the postgresql connection
# Download the config file
Credentials<-as.matrix(read.table("Credentials.yml",row.names=1))

# Connet to PostgreSQL
Driver <- dbDriver("PostgreSQL") # Establish database driver
Connection <- dbConnect(Driver, dbname = Credentials["database:",], host = Credentials["host:",], port = Credentials["port:",], user = Credentials["user:",])

#############################################################################################################
########################################### LOAD INPUT: FUNCTIONS  ##########################################
#############################################################################################################
# No custom input loading functions at this time

########################################### LOAD INPUT: SCRIPTS #############################################
# Load the museum specimen information

# Load DeepDive Data from postgresql
DeepDiveData<-dbGetQuery(Connection,"SELECT docid,words FROM nlp_sentences_352")

# Record the input and output stats
StatsMatrix<-matrix(NA,nrow=2,ncol=2,dimnames=list(c("Initial","Final"),c("GDD_Documents","IDIG_Museums")))
StatsMatrix["Initial","GDD_Documents"]<-length(unique(DeepDiveData[,"docid"]))

# Merge sentences into single document strings
DocumentWords<-tapply(DeepDiveData[,"words"],DeepDiveData[,"docid"],function(x) paste(x,collapse=" "))
# Clean the punctuation
DocumentWords<-parSapply(Cluster,DocumentWords,function(x) gsub("[[:punct:]]", " ",x))

#############################################################################################################
######################################## MATCH SPECIMENS-REFS FUNCTIONS #####################################
#############################################################################################################
# Because of memory constraints we do not use a more elegant split()-family solution - e.g., by() or dlply()

# A function to iteratively look within each document for museum mentions






