
<!-- README.md is generated from README.Rmd. Please edit that file -->

# uljas

<!-- badges: start -->

<!-- badges: end -->

The R client for the Finnish Customs (Tulli) database Uljas. See:
<https://tulli.fi/en/statistics/uljas-api>

## Installation

You can install the uljas from
[github](https://github.com/jhuovari/uljas) with:

``` r
# install.packages("devtools")
devtools::install_github("jhuovari/uljas")
```

## Use

### Statistics

Statistics present in the database.

``` r

library(uljas)

stats <- uljas_stats(lang = "en")
#> Warning: JSON string contains (illegal) UTF8 byte-order-mark!

knitr::kable(stats)
```

| ifile                                                                     | title                                               | utime               |
| :------------------------------------------------------------------------ | :-------------------------------------------------- | :------------------ |
| /DATABASE/01 ULKOMAANKAUPPATILASTOT/01 CN/ULJAS\_CN                       | CN, CC BY 4.0                                       | 28.8.2019 7.35.47   |
| /DATABASE/01 ULKOMAANKAUPPATILASTOT/01 CN/VANHAKK\_CN                     | CN / HS, CC BY 4.0                                  | 19.12.2018 12.11.23 |
| /DATABASE/01 ULKOMAANKAUPPATILASTOT/02 SITC/ULJAS\_SITC                   | SITC rev4, CC BY 4.0                                | 28.8.2019 7.36.24   |
| /DATABASE/01 ULKOMAANKAUPPATILASTOT/02 SITC/VANHAKK\_SITC                 | SITC rev3, CC BY 4.0                                | 19.12.2018 12.11.41 |
| /DATABASE/01 ULKOMAANKAUPPATILASTOT/03 CPA/ULJAS\_CPA2008                 | CPA2008, CC BY 4.0                                  | 28.8.2019 7.36.44   |
| /DATABASE/01 ULKOMAANKAUPPATILASTOT/03 CPA/VANHAULJAS\_CPA2002            | CPA2002, CC BY 4.0                                  | 19.12.2018 12.12.05 |
| /DATABASE/01 ULKOMAANKAUPPATILASTOT/04 TOL/ULJAS\_TOL                     | NACE 2008, CC BY 4.0                                | 28.8.2019 7.36.53   |
| /DATABASE/01 ULKOMAANKAUPPATILASTOT/05 BEC/ULJAS\_BEC                     | BEC, CC BY 4.0                                      | 28.8.2019 7.52.18   |
| /DATABASE/01 ULKOMAANKAUPPATILASTOT/06 KAUPPATASE/ULJAS\_KAUPPATASE       | TRADE BALANCE, CC BY 4.0                            | 28.8.2019 7.36.53   |
| /DATABASE/01 ULKOMAANKAUPPATILASTOT/06 KAUPPATASE/ULJAS\_KAUPPATASE\_VIEW | TRADE BALANCE, CC BY 4.0                            | 28.8.2019 7.36.44   |
| /DATABASE/01 ULKOMAANKAUPPATILASTOT/09 INDEKSIT/ULJAS\_INDEKSIT           | INDEXES OF FOREIGN TRADE, CC BY 4.0                 | 28.8.2019 8.01.55   |
| /DATABASE/02 LOGISTIIKKATILASTOT/07 KULJETUSMUOTO/ULJAS\_KTAPA            | SITC AND MODE OF TRANSPORT, CC BY 4.0               | 28.8.2019 7.51.54   |
| /DATABASE/02 LOGISTIIKKATILASTOT/07 KULJETUSMUOTO/ULJAS\_ULKOKONTTI       | CONTAINER TRANSPORT OF EXTERNAL TRADE, CC BY 4.0    | 28.8.2019 7.52.11   |
| /DATABASE/02 LOGISTIIKKATILASTOT/08\_TRANSITO/ULJAS\_TRANSITO             | TRANSIT TRANSPORTS, CC BY 4.0                       | 27.8.2019 12.43.44  |
| /DATABASE/02 LOGISTIIKKATILASTOT/09 RAJALIIKENNE/ULJAS\_RAJALIIKENNE      | BORDER TRAFFIC, CC BY 4.0                           | 13.9.2019 11.57.39  |
| /DATABASE/03 VERO- JA KANTOTILASTOT/11 TULLINKANTO/ULJAS\_tullinkanto     | State revenue debited by Finnish Customs, CC BY 4.0 | 27.8.2019 13.37.34  |

### Dimensions

`uljas_dims` return dimensions that are available for a certain
statistics. Use ifile from `uljas_stats`.

``` r

sitc_dims <- uljas_dims(ifile = "/DATABASE/01 ULKOMAANKAUPPATILASTOT/02 SITC/ULJAS_SITC")
#> Warning: JSON string contains (illegal) UTF8 byte-order-mark!

str(sitc_dims)
#> List of 5
#>  $ Classification of Products SITC:'data.frame': 10 obs. of  4 variables:
#>   ..$ label: chr [1:10] "Classification of Products SITC" "Classification of Products SITC5" "Classification of Products SITC4" "Classification of Products SITC3" ...
#>   ..$ elim : chr [1:10] "N" "N" "N" "N" ...
#>   ..$ size : int [1:10] 4336 2972 1025 264 68 11 78 341 1365 49
#>   ..$ show : chr [1:10] "T" "CT" "CT" "CT" ...
#>  $ TimePeriod                     :'data.frame': 3 obs. of  4 variables:
#>   ..$ label: chr [1:3] "TimePeriod" "Quarter" "Year"
#>   ..$ elim : chr [1:3] "N" "N" "N"
#>   ..$ size : int [1:3] 210 484 121
#>   ..$ show : chr [1:3] "T" "T" "T"
#>  $ Country                        :'data.frame': 25 obs. of  4 variables:
#>   ..$ label: chr [1:25] "Country" "Continent" "Continent - Europe by countries" "Continent - North Africa by countries" ...
#>   ..$ elim : chr [1:25] "N" "N" "N" "N" ...
#>   ..$ size : int [1:25] 252 10 59 10 54 19 35 6 36 15 ...
#>   ..$ show : chr [1:25] "T" "CT" "CT" "CT" ...
#>  $ Flow                           :'data.frame': 1 obs. of  4 variables:
#>   ..$ label: chr "Flow"
#>   ..$ elim : chr "N"
#>   ..$ size : int 3
#>   ..$ show : chr "T"
#>  $ Indicators                     :'data.frame': 1 obs. of  4 variables:
#>   ..$ label: chr "Indicators"
#>   ..$ elim : chr "N"
#>   ..$ size : int 16
#>   ..$ show : chr "T"
```

### Classifications

`uljas_class` returns values in the classification (specified with class
parameter) for statistics (specified with ifile parameter). Also all (in
main classifications) with `class = NULL`.

``` r

sitc_dims$`Classification of Products SITC`$label
#>  [1] "Classification of Products SITC"       
#>  [2] "Classification of Products SITC5"      
#>  [3] "Classification of Products SITC4"      
#>  [4] "Classification of Products SITC3"      
#>  [5] "Classification of Products SITC2"      
#>  [6] "Classification of Products SITC1"      
#>  [7] "Classification of Products SITC1+2"    
#>  [8] "Classification of Products SITC1+2+3"  
#>  [9] "Classification of Products SITC1+2+3+4"
#> [10] "SITC Products"

sitc_class <- uljas_class(ifile = "/DATABASE/01 ULKOMAANKAUPPATILASTOT/02 SITC/ULJAS_SITC", class = "SITC Products")
#> Warning: JSON string contains (illegal) UTF8 byte-order-mark!
#   sitc_class_all <- uljas_class(ifile = "/DATABASE/01 ULKOMAANKAUPPATILASTOT/02 SITC/ULJAS_SITC", class = NULL)

str(sitc_class)
#> List of 1
#>  $ SITC Products:'data.frame':   49 obs. of  2 variables:
#>   ..$ code: chr [1:49] "" "0" "02" "05" ...
#>   ..$ text: chr [1:49] "Total" "Food and live animals" "Dairy products and birds' eggs" "Vegetables and fruit" ...
```

### Data

`uljas_data` returns the data for class value combinations from a
statistics (specified with ifile parameter).

``` r

sitc_query <- list(`SITC Products` = c("0" , "02"), TimePeriod = "=ALL", Flow = 1, Country = "AT", Indicators = "V1")
sitc_data <- uljas_data(ifile = "/DATABASE/01 ULKOMAANKAUPPATILASTOT/02 SITC/ULJAS_SITC", classifiers = sitc_query)
#> Warning: JSON string contains (illegal) UTF8 byte-order-mark!

head(sitc_data)
#> # A tibble: 6 x 5
#>   `SITC Products`      TimePeriod Flow                Country        values
#>   <chr>                <chr>      <chr>               <chr>           <int>
#> 1 0 Food and live ani~ 201906     Imports by countri~ AT (2002--.) ~ 1.93e6
#> 2 0 Food and live ani~ 201905     Imports by countri~ AT (2002--.) ~ 1.70e6
#> 3 0 Food and live ani~ 201904     Imports by countri~ AT (2002--.) ~ 2.10e6
#> 4 0 Food and live ani~ 201903     Imports by countri~ AT (2002--.) ~ 1.51e6
#> 5 0 Food and live ani~ 201902     Imports by countri~ AT (2002--.) ~ 3.95e6
#> 6 0 Food and live ani~ 201901     Imports by countri~ AT (2002--.) ~ 1.85e6
```

An individual request return is limited to 50 000 cells.
