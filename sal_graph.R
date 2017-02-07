# install.packages('RSQLite')
library(RSQLite)

con <- dbConnect(drv=SQLite(),
                 dbname="data/survey.db")

query <- dbSendQuery(con,
                     "SELECT *
                      FROM Survey Join Visited
                      ON Survey.taken = Visited.id")

readings <- dbFetch(query)

# install.packages('dplyr')
library(dplyr)

sal <- readings %>%
  select(dated, site, quant, reading) %>%
  filter(quant=="sal")

# Missing data can't be graphed
sal <- na.omit(sal)

# Fix salinity that were recorded as concentrations
# by mistake
sal <- sal %>%
  filter(reading > 1) %>%
  mutate(cor_reading=reading/100) %>%
  union(
    sal %>%
      filter(reading <= 1 ) %>%
      mutate(cor_reading=reading)
  )

# Change data type of dates to be graphable
sal$dated <- as.Date(sal$dated)

library(ggplot2)

ggplot(data=sal,
       aes(x=dated, y=cor_reading, by=site, color=site)) +
       geom_line() +
       geom_point()

ggsave("outputs/sal_graph.jpg", device="jpg")
