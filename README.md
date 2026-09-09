
<!-- README.md is generated from README.Rmd. Please edit that file -->

# uljas

<!-- badges: start -->

[![R-CMD-check](https://github.com/jhuovari/uljas/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/jhuovari/uljas/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

The R client for the Finnish Customs (Tulli) database Uljas. See:
<https://tilastot.tulli.fi/en/uljas-statistical-database/uljas-api>

## Installation

You can install the uljas from
[github](https://github.com/jhuovari/uljas) with:

``` r
# install.packages("pak")
pak::pak("jhuovari/uljas")
```

## Use

### Statistics

Statistics present in the database.

``` r

library(uljas)

stats <- uljas_stats(lang = "en")

knitr::kable(stats)
```

| ifile                                                                   | title                                                                                | utime               |
|:------------------------------------------------------------------------|:-------------------------------------------------------------------------------------|:--------------------|
| /DATABASE/01 ULKOMAANKAUPPATILASTOT/01 CN/ULJAS_CN                      | CN, CC BY 4.0                                                                        | 26.8.2026 14.17.18  |
| /DATABASE/01 ULKOMAANKAUPPATILASTOT/01 CN/ULJAS_CN2                     | CN, CC BY 4.0                                                                        | 26.8.2026 0.34.53   |
| /DATABASE/01 ULKOMAANKAUPPATILASTOT/01 CN/VANHAKK_CN                    | CN / HS, CC BY 4.0                                                                   | 20.12.2023 16.40.19 |
| /DATABASE/01 ULKOMAANKAUPPATILASTOT/02 SITC/ULJAS_SITC                  | SITC rev4, CC BY 4.0                                                                 | 26.8.2026 0.52.18   |
| /DATABASE/01 ULKOMAANKAUPPATILASTOT/02 SITC/ULJAS_SITC2                 | SITC rev4, CC BY 4.0                                                                 | 26.8.2026 1.13.18   |
| /DATABASE/01 ULKOMAANKAUPPATILASTOT/02 SITC/VANHAKK_SITC                | SITC rev3, CC BY 4.0                                                                 | 30.8.2024 10.10.07  |
| /DATABASE/01 ULKOMAANKAUPPATILASTOT/03 CPA/ULJAS_CPA2015                | CPA2015, CC BY 4.0                                                                   | 26.8.2026 1.27.04   |
| /DATABASE/01 ULKOMAANKAUPPATILASTOT/03 CPA/ULJAS_CPA20152               | CPA2015, CC BY 4.0                                                                   | 26.8.2026 1.40.41   |
| /DATABASE/01 ULKOMAANKAUPPATILASTOT/03 CPA/VAAULJAS_CPA2008             | CPA2008, CC BY 4.0                                                                   | 20.12.2023 16.36.42 |
| /DATABASE/01 ULKOMAANKAUPPATILASTOT/03 CPA/VANHAULJAS_CPA2002           | CPA2002, CC BY 4.0                                                                   | 20.12.2023 16.36.42 |
| /DATABASE/01 ULKOMAANKAUPPATILASTOT/04 TOL/ULJAS_TOL                    | NACE 2008, CC BY 4.0                                                                 | 26.8.2026 1.46.50   |
| /DATABASE/01 ULKOMAANKAUPPATILASTOT/04 TOL/ULJAS_TOL2                   | NACE 2008, CC BY 4.0                                                                 | 26.8.2026 1.51.56   |
| /DATABASE/01 ULKOMAANKAUPPATILASTOT/05 BEC/ULJAS_BEC                    | BEC, CC BY 4.0                                                                       | 26.8.2026 2.06.46   |
| /DATABASE/01 ULKOMAANKAUPPATILASTOT/05 BEC/ULJAS_BEC2                   | BEC, CC BY 4.0                                                                       | 26.8.2026 2.07.08   |
| /DATABASE/01 ULKOMAANKAUPPATILASTOT/06 KAUPPATASE/ULJAS_KAUPPATASE      | TRADE BALANCE, CC BY 4.0                                                             | 26.8.2026 1.52.16   |
| /DATABASE/01 ULKOMAANKAUPPATILASTOT/06 KAUPPATASE/ULJAS_KAUPPATASE_VIEW | TRADE BALANCE, CC BY 4.0                                                             | 26.8.2026 1.27.04   |
| /DATABASE/01 ULKOMAANKAUPPATILASTOT/09 INDEKSIT/ULJAS_INDEKSIT          | INDICES OF INTERNATIONAL TRADE IN GOODS, CC BY 4.0                                   | 26.8.2026 8.02.10   |
| /DATABASE/01 ULKOMAANKAUPPATILASTOT/09 INDEKSIT/ULJAS_INDEKSIT2         | INDICES OF INTERNATIONAL TRADE IN GOODS, CC BY 4.0                                   | 23.3.2026 13.32.24  |
| /DATABASE/01 ULKOMAANKAUPPATILASTOT/09 INDEKSIT/VULJAS_INDEKSIT         | INDICES OF INTERNATIONAL TRADE IN GOODS, CC BY 4.0                                   | 23.3.2026 13.31.39  |
| /DATABASE/01 ULKOMAANKAUPPATILASTOT/10 ENNAKKO/ULJAS_ENNAKKO            | PRELIMINARY STATISTICS, CC BY 4.0                                                    | 7.9.2026 14.04.39   |
| /DATABASE/01 ULKOMAANKAUPPATILASTOT/10 ENNAKKO/ULJAS_ENNAKKOINDEKSI     | INDICES OF INTERNATIONAL TRADE IN GOODS, PRELIMINARY STATISTICS, CC BY 4.0           | 7.9.2026 14.36.40   |
| /DATABASE/01 ULKOMAANKAUPPATILASTOT/11 KOKOLUOKKA/ULJAS_KOKOLUOKKA      | TRADE ACCORDING TO ENTERPRISE SIZE, CC BY 4.0                                        | 23.6.2026 13.14.54  |
| /DATABASE/01 ULKOMAANKAUPPATILASTOT/12 MAAKUNTA/ULJAS_MAAKUNTA          | INTERNATIONAL TRADE IN GOODS BY REGION, CC BY 4.0                                    | 15.6.2026 8.33.37   |
| /DATABASE/01 ULKOMAANKAUPPATILASTOT/13 OMISTUS/ULJAS_OMISTUS            | INTERNATIONAL TRADE IN GOODS ACCORDING TO TYPES OF ENTERPRISE PROPRIETORS, CC BY 4.0 | 25.5.2026 15.10.43  |
| /DATABASE/02 LOGISTIIKKATILASTOT/07 KULJETUSMUOTO/ULJAS_KTAPA           | SITC AND MODE OF TRANSPORT IN EXPORTS, CC BY 4.0                                     | 26.8.2026 8.31.53   |
| /DATABASE/02 LOGISTIIKKATILASTOT/07 KULJETUSMUOTO/ULJAS_KTAPA2          | SITC AND MODE OF TRANSPORT, CC BY 4.0                                                | 26.8.2026 2.04.29   |
| /DATABASE/02 LOGISTIIKKATILASTOT/07 KULJETUSMUOTO/ULJAS_ULKOKONTTI      | CONTAINER TRANSPORT OF EXTERNAL TRADE, CC BY 4.0                                     | 26.8.2026 2.06.09   |
| /DATABASE/02 LOGISTIIKKATILASTOT/08_TRANSITO/ULJAS_TRANSITO             | TRANSIT TRANSPORTS, CC BY 4.0                                                        | 21.12.2023 16.31.17 |
| /DATABASE/02 LOGISTIIKKATILASTOT/09 RAJALIIKENNE/ULJAS_RAJALIIKENNE     | BORDER TRAFFIC, CC BY 4.0                                                            | 31.8.2026 14.58.00  |
| /DATABASE/03 VERO- JA KANTOTILASTOT/11 TULLINKANTO/ULJAS_tullinkanto    | State revenue debited by Finnish Customs, CC BY 4.0                                  | 4.8.2026 10.59.57   |

### Dimensions

`uljas_dims` return dimensions that are available for a certain
statistics. Use ifile from `uljas_stats`.

``` r

sitc_dims <- uljas_dims(ifile = "/DATABASE/01 ULKOMAANKAUPPATILASTOT/02 SITC/ULJAS_SITC")

str(sitc_dims)
#> List of 5
#>  $ Classification of Products SITC:'data.frame': 10 obs. of  4 variables:
#>   ..$ label: chr [1:10] "Classification of Products SITC" "Classification of Products SITC5" "Classification of Products SITC4" "Classification of Products SITC3" ...
#>   ..$ elim : chr [1:10] "N" "N" "N" "N" ...
#>   ..$ size : int [1:10] 4585 3191 1053 265 69 11 79 343 1395 54
#>   ..$ show : chr [1:10] "T" "CT" "CT" "CT" ...
#>  $ Time period                    :'data.frame': 3 obs. of  4 variables:
#>   ..$ label: chr [1:3] "Time period" "Quarter" "Year"
#>   ..$ elim : chr [1:3] "N" "N" "N"
#>   ..$ size : int [1:3] 18 512 128
#>   ..$ show : chr [1:3] "T" "T" "T"
#>  $ Country                        :'data.frame': 3 obs. of  4 variables:
#>   ..$ label: chr [1:3] "Country" "Continents and groups" "Countries hierarchy"
#>   ..$ elim : chr [1:3] "N" "N" "N"
#>   ..$ size : int [1:3] 254 27 1709
#>   ..$ show : chr [1:3] "T" "T" "T"
#>  $ Flow                           :'data.frame': 1 obs. of  4 variables:
#>   ..$ label: chr "Flow"
#>   ..$ elim : chr "N"
#>   ..$ size : int 3
#>   ..$ show : chr "T"
#>  $ Indicators                     :'data.frame': 1 obs. of  4 variables:
#>   ..$ label: chr "Indicators"
#>   ..$ elim : chr "N"
#>   ..$ size : int 17
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
#   sitc_class_all <- uljas_class(ifile = "/DATABASE/01 ULKOMAANKAUPPATILASTOT/02 SITC/ULJAS_SITC", class = NULL)

str(sitc_class)
#> List of 1
#>  $ SITC Products:'data.frame':   54 obs. of  2 variables:
#>   ..$ code: chr [1:54] "" "0+1" "2" "212" ...
#>   ..$ text: chr [1:54] "Total" "Food, beverages and tobacco" "Crude materials, inedible, except fuels" "Furskins, raw" ...
```

### Data

`uljas_data` returns the data for class value combinations from a
statistics (specified with ifile parameter).

``` r

sitc_query <- list(`Classification of Products SITC1` = c("0" , "1"), `Time period` = "=ALL", Flow = 1, Country = "AT", Indicators = "V1")
sitc_data <- uljas_data(ifile = "/DATABASE/01 ULKOMAANKAUPPATILASTOT/02 SITC/ULJAS_SITC", classifiers = sitc_query)

head(sitc_data)
#> # A tibble: 6 × 6
#>   Classification of Products SIT…¹ `Time period` Flow  Country Indicators values
#>   <fct>                            <fct>         <fct> <fct>   <fct>       <int>
#> 1 0 (2002--.) Food and live anima… 202606        Impo… AT (20… Value (eu… 3.16e6
#> 2 0 (2002--.) Food and live anima… 202605        Impo… AT (20… Value (eu… 2.99e6
#> 3 0 (2002--.) Food and live anima… 202604        Impo… AT (20… Value (eu… 3.77e6
#> 4 0 (2002--.) Food and live anima… 202603        Impo… AT (20… Value (eu… 3.28e6
#> 5 0 (2002--.) Food and live anima… 202602        Impo… AT (20… Value (eu… 3.38e6
#> 6 0 (2002--.) Food and live anima… 202601        Impo… AT (20… Value (eu… 3.75e6
#> # ℹ abbreviated name: ¹​`Classification of Products SITC1`
```

A classifier value may also be one of the api keywords `"=ALL"`,
`"=FIRST"` and `"=LAST"`, the two latter optionally with a number of
values, e.g. `"=LAST 12"`. The keywords follow the order of the
classification, which for time periods is the newest first, so
`"=FIRST"` is the latest period. The code of a total is an empty string,
so a total can not be asked for on its own, but it is included in
`"=ALL"`.

### Large queries

An individual request is limited to 50 000 cells, i.e. to 50 000
combinations of the classifier values. `uljas_query_size` tells how many
cells a query asks for.

``` r

sitc5_query <- list(`Classification of Products SITC5` = "=ALL", `Time period` = "=ALL",
                    Flow = 1, Country = "AT", Indicators = "V1")

uljas_query_size(ifile = "/DATABASE/01 ULKOMAANKAUPPATILASTOT/02 SITC/ULJAS_SITC", classifiers = sitc5_query)
#> [1] 57438
```

`uljas_data` divides a larger query into several requests and combines
the answers, so the result is the same as that of a single request. Use
`max_cells = Inf` to send the query as it is.

``` r

sitc5_data <- uljas_data(ifile = "/DATABASE/01 ULKOMAANKAUPPATILASTOT/02 SITC/ULJAS_SITC", classifiers = sitc5_query)
#> The query is divided into 2 requests.

nrow(sitc5_data)
#> [1] 57438
```

Note that the classifications and the statistics files of the database
do change. Finnish Customs renewed most of the cubes on 30 March 2026:
the current cubes (for example `ULJAS_SITC`) begin from January 2025 and
the longer time series are in the parallel cubes (for example
`ULJAS_SITC2`). Check the codes with `uljas_class` if a query stops
returning data.
