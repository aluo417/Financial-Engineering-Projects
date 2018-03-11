# Financial-Engineering-Projects
Codes to analyze financial markets: fundamental analysis of listed companies, option pricing techniques, e.t.c.. Written in Python, and R.

## Stock Annual Fundamentals [R]
This project focuses on the collection of annual data for all stocks. The data sets come from [WRDS](https://wrds-web.wharton.upenn.edu/wrds/). Given the monthly data for PERMNO, tickers, cusip, price, shares outstanding and holding period return, we calculate the annualized marketcap and rate of return.

[View It Here](https://cdn.rawgit.com/luoao0417/Financial-Engineering-Projects/39bab55d/annual%20fundamentals%20data/hw3.html)

## Value vs. Growth Studies [R]
This project focuses on the exploration of the relationship between **E/P ratios** and **Earnings Growth**. The data sets are hot-loaded using tidyquant to pull data from online database. Given the P/E ratios, and 3-year average lagged growth of **Net Income**, we truncated the top and bottom quantile as outliers. The correlation turns out to be merely 0.1365359, which is weak evidence to establish a linear relationship between these two stats.

[View It Here](https://cdn.rawgit.com/luoao0417/Financial-Engineering-Projects/ddf9adde/Value%20vs%20Growth/hw6.html)

## Fama-Macbeth Regression [R]
In this project, we are running Fama-Macbeth regression to predict cross-sectional stock returns with independent variables: firm-marketcap, price-normalized accruals, the earnings-price ratio, and 1/price. The data sets originally come from WRDS. The prediction of year T+2 returns is based on the year T variable as a firm could end its fiscal year in May and report results in October. The performance of the prediction is not as poor as I expected. The the Fama-Macbeth regression runs on the panel data with 826 samples accross 20 years produces the coefficients of [0.00000133, -0.563, -3.02, 0.484] for the above variables respectively.

[View It Here](https://cdn.rawgit.com/luoao0417/Financial-Engineering-Projects/7475e538/Fama-Macbeth%20Regression/hw7.html)

## Exotic & Path Dependent Options [Python]
* Fixed Strike Lookback Option
* Collateral Loans

## Binomial Methods for Option Pricing [Python]
* Convergence Rate of Different Binomial Mthods
* Price Options using Real-time Data
* Greeks Estimation using Binomial Method
* Binomial Method for Put Option
* Trinomial Method
* Binomial Method using Halton's Low-discrepancy Sequence
