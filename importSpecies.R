# Import bird species of North America list -------------------------------
# Source: Cornerll's Bird's of North America Online
# http://bna.birds.cornell.edu/bna/species

library(rvest)


# Load in the data --------------------------------------------------------
x = read_html('http://bna.birds.cornell.edu/bna/species')
# Add in unique ID, drawn from the BNA IDs
