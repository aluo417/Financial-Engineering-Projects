library(xts)
library(zoo)
library(magrittr)
library(data.table)
library(tidyr)
library(lubridate)

dset_data <- fread("./data/monthlydata.csv")
colnames(dset_data) %<>% tolower

test <- dset_data
test[, date := as.Date(as.character(date), format = "%Y%m%d") ]
test[, adjprc := abs(prc)]
test[, mkc := adjprc * shrout]
test[, ret := as.numeric(ret)]
test[, test[,is.na(ret)]] = 0
test[, year := year(date)]
mdata <- test[, 
     .(prod(na.omit(ret) + 1)-1, tail(na.omit(mkc), n=1), tail(unique(ticker), n=1)),
     by = .(year, permno, cusip)]
colnames(mdata) <- c('year', 'perm', 'cusip', 'rate of return', 'marketcap', 'ticker')

save(mdata, file="./annualData.RData")

