source("Global.R")

## ~~~~ read data - using read.csv ad fread results in format that jsonlite::fromJSON can't parse properly
# tr <- read.csv("data/train.csv") %>%
#   as.data.table()

train <- tr #[1:5000, ]


## ~~~~ Preprocess - JSON columns, drop columns with only one level, fix NAs
json_columns <- c("device",
                  "geoNetwork",
                  "totals",
                  "trafficSource")


train <- replaceJSONColumns(train, json_columns)
keepOnlyColumnsWithMoreThanOneLevel_(train)
fixEncodingForNAs_(train)
fixColumnFormattings_(train)

## To figure out...:
train[, .N, by = trafficSource.adwordsClickInfo.isVideoAd ]
train[, .N, by = trafficSource.isTrueDirect]
train %>% head() %>% View()
