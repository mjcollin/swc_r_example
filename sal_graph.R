# This script is an example of producing a graph in a 
# reproducible way using R, SQL, and git.

# You may need to uncomment the install lines if you don't
# have packages installed.
# install.packages('RSQLite')
# install.packages('dplyr')
# install.packages('ggplot2')

# Retrieve data from our database
library(RSQLite)

con <- dbConnect(drv=SQLite(),
                 dbname="data/survey.db")

query <- dbSendQuery(con,
                     "SELECT *
                      FROM Survey Join Visited
                      ON Survey.taken = Visited.id")

readings <- dbFetch(query)

# now that the results are in a dataframe, disconnect from the db
dbClearResult(query)
dbDisconnect(con)


# Correct and format our data for graphing
library(dplyr)

sal <- readings %>%
  select(dated, site, quant, reading) %>%
  filter(quant=="sal")

# Missing data can't be graphed
sal <- na.omit(sal)

# Fix salinity that were recorded as concentrations
# by mistake
sal <- sal %>%
  mutate(cor_reading = 
           ifelse(reading > 1, reading/100, reading)
         )

# Change data type of dates to be graphable
sal$dated <- as.Date(sal$dated)


# Make the graph
library(ggplot2)

ggplot(data=sal,
       aes(x=dated, y=cor_reading, by=site, color=site)) +
       geom_line() +
       geom_point()

# write the graph out so it can be used in reports
ggsave("outputs/sal_graph.jpg", device="jpg")



