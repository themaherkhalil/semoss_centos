# Install the package manager
if (!require("pacman")) install.packages("pacman")

# Function to recursively install all packages and their dependencies
recursively_install <- function(packages) {
	completed <- c()
	recursively_install_sub <- function(packages, tree) {
		for (package in packages) {
			tree_sub <- paste0(tree, " -> ", package)
			if (!is.element(package, completed) & !require(package, character.only=TRUE)) {
				dependencies <- pacman::p_depends(package, character.only=TRUE)$Imports
				recursively_install_sub(dependencies,  tree_sub)
				pacman::p_install(package, character.only=TRUE)
				completed <<- c(completed, package)
				cat("\n>>>>>>>>>>>> Completed installation of package:", tree_sub, "\n")
			} else {
				cat("\n>>>>>>>>>>>> Already installed:", tree_sub, "\n")
			}
		}
	}
	recursively_install_sub(packages, "")
}

# List of packages to install
packages <- c("antiword",
			  "arules",
	      	  	  "Amelia",
	                  "bindrcpp",
	      		  "Boruta",
	                  "crayon",
			  "cellranger",
			  "cluster",
			  "codetools",
			  "compiler",
			  "curl",
			  "data.table",
	      		  "deSolve",
			  "devtools",
			  "digest",
			  "doParallel",
			  "dplyr",
	      		  "e1071",
			  "FactoMineR",
			  "foreach",
			  "formatR",
			  "futile.logger",
			  "futile.options",
			  "fuzzyjoin",
	     		  "fst",
		      	  "glue",
			  "grid",
			  "HDoutliers",
			  "httr",
			  "igraph",
			  "iterators",
			  "jsonlite",
			  "lambda.r",
			  "lattice",
	      		  "lexRankr",
	      		  "lpSolve",
	      		  "lubridate",
			  "lsa",
			  "LSAfun",
			  "Matrix",
	                  "magrittr",
			  "memoise",
	      		  "missRanger",
			  "mlapi",
			  "NLP",
	      		  "openNLP",
			  "parallel",
			  "partykit",
	      		  "pdftools",
	                  "pivottabler",
	                  "pkgconfig",
	                  "plogr",
			  "plyr",
			  "purrr",
	                  "qs",
	      		  "ranger",
			  "randomForest",
	      		  "ranger",
	      		  "R6",
			  "RcppParallel",
			  "RcppProgress",
			  "RCurl",
			  "readxl",
	      		  "rlang",
	      		  "readtext",
			  "reshape2",
			  "rJava",
	      		  "rvest",
			  "RJDBC",
			  "Rlof",
			  "RSclient",
	                  "sentimentr",
			  "settings",
	      		  "skimr",
			  "SnowballC",
	                  "snakecase",
			  "splitstackshape",
			  "stats",
			  "stringdist",
			  "stringi",
			  "stringr",
			  "text2vec",
	      		  "textmineR",
	      		  "textrank",
	      		  "textreadr",
			  "textreuse",
	      		  "tibble",
			  "tidyr",
			  "tidyselect",
	      		  "tools",
			  "tm",
	      		  "tokenizers",
	      		  "udpipe",
	                  "urltools",
			  "validate",
			  "VGAM",
			  "WikidataR",
			  "WikipediR",
			  "withr",
			  "XML",
	      		  "xml2",
			  "yaml",
	     		  "sqldf",
	     		  "naniar")

# Install all packages and their dependencies	
recursively_install(packages)

# Install AnomalyDetection from GitHub
#pacman::p_install_gh(c("twitter/AnomalyDetection"))

# Write the install status to disk 
#all.packages <- c(packages, "AnomalyDetection")
#write.table(data.frame(sapply(all.packages, function(x) require(x, character.only=TRUE))), 
#			file = "/opt/status/R.csv", 
#			quote = FALSE, 
#			sep = ",", 
#			row.names = TRUE, 
#			col.names = FALSE)
