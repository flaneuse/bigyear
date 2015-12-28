# Import bird species of North America list -------------------------------
# Source: Cornerll's Bird's of North America Online
# http://bna.birds.cornell.edu/bna/species

library(rvest)
library(dplyr)
library(data.table)
library(stringr)


# Load in the data --------------------------------------------------------
# As of 28 December 2015, should have 748 birds in N. Amer.
bna = read_html('http://bna.birds.cornell.edu/bna/species')

sciNames = bna %>% 
  html_nodes(".sci-name") %>% 
  html_text()

sciNames = data.frame(sciName = sciNames)

commonNames = bna %>% 
  html_nodes("#region-content a span") %>% 
  html_text()

commonNames = data.frame(commonName = commonNames)

links = bna %>% 
  html_nodes("#region-content .float-left a") %>% 
  html_attr("href") 

# Filter the links to the alpha bar.
# Not the classiest, and may lead to mismatching of birds to links.
links = data.frame(link = links) %>% 
  filter(link %like% "/bna/species")

ids = data.frame(id = 1:nrow(links))

# Merge together full bird dataset ----------------------------------------
birdDB = bind_cols(commonNames, sciNames, links, ids) %>% 
  rowwise() %>% 
  mutate(bnaID = as.numeric(paste0(str_extract_all(link, '[0-9]', simplify = TRUE), collapse = "")),
         link = paste0('http://bna.birds.cornell.edu', link)) # Add in unique ID, drawn from the BNA IDs