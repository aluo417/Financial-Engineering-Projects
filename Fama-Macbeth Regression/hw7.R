library(data.table)
library(dplyr)
library(broom)
library(ggplot2)

## Step 1: Raw Data Clean
# read in raw data from wrds
# data from 1973 - 2018
raw_data <- fread('./58059f88545b4ce2.csv')

# check basic characteristics of raw data
str(raw_data)
head(raw_data)
summary(raw_data)
dim(raw_data)

# save if in conveience of faster retrieving
save(raw_data, file = './annual_set.Rdata')

# subset the values we are interested in
annual_set <- subset(raw_data, select = c('gvkey', 'fyear', 'rect', 'xacc', 'dp', 'txp', 'epspi', 'ni', 'csho', 'prcc_f', 'mkvalt'))

# transform into predicting variables
finlset <- annual_set[, .((prcc_f*csho), (mkvalt), (rect-dp-txp-xacc), (epspi/prcc_f), (ni/csho/prcc_f), (prcc_f), (1/prcc_f)),
                     by = list(gvkey, fyear)]
colnames(finlset) <- c('gvkey', 'fyear', 'mktcap1', 'mktcap2', 'netaccrual', 'epratio1', 'epratio2',  'price', 'invprice')

# unionize to maximize the available financial data
finlset <- finlset %>%
  mutate(mktcap = if_else(!is.na(mktcap1) & mktcap1 > 0 , mktcap1, mktcap2),
         epratio = if_else(!is.na(epratio1), epratio1, epratio2)) %>%
  mutate(normaccrual = netaccrual / mktcap)

# create entries for return and forward return
finlset <- finlset %>%
  group_by(gvkey) %>%
  mutate(return = price/lag(price),
         fwd_return = lead(price,2)/lead(price))

# filter out all NA values
finlset <- finlset %>%
  filter(!is.na(return), 
         !is.na(fwd_return), 
         !is.na(mktcap), 
         !is.na(epratio), 
         !is.na(invprice), 
         !is.na(normaccrual), 
         price > 0,
         mktcap > 0,
         is.finite(epratio),
         is.finite(invprice)) %>%
  select(gvkey, fyear, return, fwd_return, mktcap, normaccrual, epratio, invprice)

save(finlset, file = './clean_annual_financials.Rdata')

## Step 2: Making panel data
# as there is always a trade-off between number of samples and length of time interval
# we pick 20 years as time window to collect as many samples as possible
year_samples <- rep(0, 25)
for(year in 1973:1997){
  ss <- finlset %>%
    group_by(gvkey) %>%
    filter(all(seq(year, year+19) %in% fyear))
  year_samples[year-1972] <- length(unique(ss$gvkey))
}

# as a result, we are interested in the 20 consecutive years from 1995 to 2014
start_year <- 1972 + which(year_samples == max(year_samples))
end_year <- start_year + 19

# then make the panel data
panelset <- finlset %>%
  group_by(gvkey) %>%
  filter(all(seq(start_year, end_year) %in% fyear), fyear >= start_year, fyear <= end_year)
# save the panel data
save(panelset, file = './PanelData[1995-2014].Rdata')

## Step 3: Fama-Macbeth Regression
# substep 1: crossectional regression
# run regression of R_T on the variables at t = T-2
models <- panelset %>%
  group_by(fyear) %>%
  do(fit_fyear = lm(fwd_return ~ mktcap + normaccrual + epratio + invprice, data = .))

# get the coefficients by group of fyear in a tidy data_frame
coef_fyear = tidy(models, fit_fyear)

# substep 2: average over time
# str(coef_fyear)
avg_coef <- coef_fyear %>%
  group_by(term) %>%
  summarize(Mean = mean(estimate), Std = sd(estimate))

save(avg_coef, file = 'avg_coef.Rdata')
# subsetp 3: running forecast of return
# and compare it with historical return
predictset <- finlset %>%
  group_by(gvkey) %>%
  mutate(predict_return = avg_coef[['Mean']][1] + 
           avg_coef[['Mean']][2] * lag(epratio,2) + 
           avg_coef[['Mean']][3] * lag(invprice,2) +
           avg_coef[['Mean']][4] * lag(mktcap,2) +
           avg_coef[['Mean']][5] * lag(normaccrual,2)) %>%
  mutate(error_percent = (predict_return/return - 1)*100,
         resid = predict_return - return)

# exclude the errors coming from zero historical return
errors <- predictset %>%
  filter(is.finite(error_percent), !is.na(error_percent)) %>%
  select(gvkey, error_percent, resid)
summary(errors$error_percent)

save(errors, file = 'rel_error.Rdata')

std_error <- sqrt(sum(errors$resid ^2)/(length(errors$resid) - 2))

# truncate the errors coming from almost zero return
qbottom_errors <- quantile(errors$error_percent,0.05)
qtop_errors <- quantile(errors$error_percent, 0.95)
truncated_errors <- errors %>%
  filter(error_percent > qbottom_errors, error_percent < qtop_errors)
summary(errors$error_percent)

truncated_std_error <- sqrt(sum(truncated_errors$resid ^2)/(length(truncated_errors$resid) - 2))

save(truncated_errors, file = 'truncated_rel_error.Rdata')

# plot of histogram to show the distribution of errors
truncated_errors %>%
  ggplot(aes(error_percent)) + geom_histogram(binwidth = 10)

