
<!-- README.md is generated from README.Rmd. Please edit that file -->

# apportita <a href='https://paithiov909.github.io/apportita'><img src='man/figures/logo.png' align="right" height="139" /></a>

<!-- badges: start -->

[![R-CMD-check](https://github.com/paithiov909/apportita/workflows/R-CMD-check/badge.svg)](https://github.com/paithiov909/apportita/actions)
<!-- badges: end -->

Apportita is a partial R port from
[plasticityai/magnitude](https://github.com/plasticityai/magnitude),
which is a fast, simple utility library for handling vector embeddings.

Apportita would cover only partial features of the original Magnitude
library. The main goal of this package is to enable access to user’s
local magnitude data store. In other words, apportita would not support
streaming access to remote sqlite files.

The package mainly targets the range where the
[magnitude-light](https://github.com/davebulaval/magnitude-light)
library does, thus some functionalities would not be implemented.

## Usage

### Construct a Magnitude connection

``` r
library(apportita)

## apportita includes a sample magnitude file
## trained with `movie_review` dataset from 'text2vec' package.
conn <- apportita::magnitude(system.file("magnitude/w2v_en_sample.magnitude", package = "apportita"))

dim(conn) ## check the dimension of Magnitude table
#> [1] 12711    20
```

Remember to close the connection after querying to the Magnitude table.

``` r
close(conn)
```

### Querying

``` r
apportita::query(conn, c("i", "watch", "a", "movie"))
#> # A tibble: 4 × 21
#>   key   dim_0   dim_1  dim_2   dim_3   dim_4  dim_5   dim_6 dim_7  dim_8  dim_9
#>   <chr> <dbl>   <dbl>  <dbl>   <dbl>   <dbl>  <dbl>   <dbl> <dbl>  <dbl>  <dbl>
#> 1 a     0.450 -0.183   0.197 -0.0840 -0.117  -0.134 -0.0380 0.200 0.232  -0.248
#> 2 i     0.453 -0.102   0.152  0.0377 -0.0414 -0.121 -0.181  0.115 0.0691 -0.316
#> 3 movie 0.277  0.0376 -0.144 -0.391  -0.135  -0.111  0.100  0.242 0.295  -0.147
#> 4 watch 0.327  0.172  -0.266 -0.0383 -0.190  -0.233 -0.343  0.206 0.127  -0.173
#> # … with 10 more variables: dim_10 <dbl>, dim_11 <dbl>, dim_12 <dbl>,
#> #   dim_13 <dbl>, dim_14 <dbl>, dim_15 <dbl>, dim_16 <dbl>, dim_17 <dbl>,
#> #   dim_18 <dbl>, dim_19 <dbl>

apportita::doesnt_match(conn, "book", c("i", "love", "movie"), n = 3)
#> # A tibble: 3 × 2
#>   keys  distance
#>   <chr>    <dbl>
#> 1 i        0.948
#> 2 love     0.746
#> 3 movie    0.609

apportita::most_similar(conn, "book", c("i", "love", "movie"), n = 3)
#> # A tibble: 3 × 2
#>   keys  similarity
#>   <chr>      <dbl>
#> 1 movie      0.815
#> 2 love       0.722
#> 3 i          0.551
```

### Calculate distance/similarity from words to words

Apportita supports methods provided in the
[proxyC](https://github.com/koheiw/proxyC) package for calculating
distances and similarities.

``` r
apportita::calc_dist(conn, "book", c("i", "love", "movie"))
#> 1 x 3 sparse Matrix of class "dgTMatrix"
#>              i      love     movie
#> book 0.9480003 0.7461417 0.6085849

apportita::calc_simil(conn, "book", c("i", "love", "movie"))
#> 1 x 3 sparse Matrix of class "dgTMatrix"
#>              i      love     movie
#> book 0.5506478 0.7216363 0.8148123
```

Experimentally, `apportita::calc_wrd` also supports computing the Word
Rotator’s Distance, which is a textual similarity measure based on
optimal transport, presented in <https://arxiv.org/abs/2004.15003>.

``` r
apportita::calc_wrd(conn, c("i", "love", "movie"), c("the", "movie", "shows", "blue", "sky"))
#> [1] 0.3716493
```

### Slicing samples

``` r
apportita::slice_n(conn, n = 2, offset = 5)
#> # A tibble: 2 × 21
#>   key     dim_0  dim_1  dim_2   dim_3  dim_4  dim_5  dim_6   dim_7 dim_8  dim_9
#>   <chr>   <dbl>  <dbl>  <dbl>   <dbl>  <dbl>  <dbl>  <dbl>   <dbl> <dbl>  <dbl>
#> 1 marsh -0.0276  0.257 0.223  -0.172  0.0647 -0.158 0.0134  0.156  0.203 -0.311
#> 2 jonny -0.0681 -0.156 0.0627  0.0813 0.379  -0.209 0.116  -0.0220 0.251 -0.224
#> # … with 10 more variables: dim_10 <dbl>, dim_11 <dbl>, dim_12 <dbl>,
#> #   dim_13 <dbl>, dim_14 <dbl>, dim_15 <dbl>, dim_16 <dbl>, dim_17 <dbl>,
#> #   dim_18 <dbl>, dim_19 <dbl>

apportita::slice_index(conn, index = c(20, 100, 600))
#> # A tibble: 3 × 21
#>   key     dim_0  dim_1    dim_2   dim_3  dim_4  dim_5  dim_6  dim_7 dim_8  dim_9
#>   <chr>   <dbl>  <dbl>    <dbl>   <dbl>  <dbl>  <dbl>  <dbl>  <dbl> <dbl>  <dbl>
#> 1 yawni… -0.185  0.354  0.120    0.0251 -0.269 0.278  0.130   0.345 0.277 0.0802
#> 2 dane   -0.245 -0.329  0.353    0.382  -0.288 0.0833 0.0476 -0.254 0.186 0.385 
#> 3 drenc…  0.186 -0.121 -0.00184 -0.343  -0.268 0.235  0.0297  0.333 0.286 0.259 
#> # … with 10 more variables: dim_10 <dbl>, dim_11 <dbl>, dim_12 <dbl>,
#> #   dim_13 <dbl>, dim_14 <dbl>, dim_15 <dbl>, dim_16 <dbl>, dim_17 <dbl>,
#> #   dim_18 <dbl>, dim_19 <dbl>

apportita::slice_frac(conn, frac = .01)
#> # A tibble: 127 × 21
#>    key    dim_0   dim_1   dim_2   dim_3   dim_4   dim_5    dim_6   dim_7   dim_8
#>    <chr>  <dbl>   <dbl>   <dbl>   <dbl>   <dbl>   <dbl>    <dbl>   <dbl>   <dbl>
#>  1 rewa… -0.249 -0.153   0.255  -0.104  -0.332  -0.143  -0.175    0.0281  0.324 
#>  2 uber   0.449 -0.0329 -0.196  -0.232  -0.113  -0.139  -0.0416   0.265   0.177 
#>  3 atte…  0.133 -0.134  -0.244  -0.140   0.243   0.223   0.176    0.231   0.311 
#>  4 late… -0.396  0.426  -0.386  -0.0213 -0.0372 -0.204   0.0451   0.0377 -0.170 
#>  5 sein…  0.231  0.0852 -0.114  -0.335   0.0491 -0.117  -0.00987  0.227   0.295 
#>  6 mani… -0.355  0.204   0.267   0.307  -0.105  -0.129   0.0565  -0.181   0.360 
#>  7 coun…  0.335  0.186  -0.259  -0.292   0.287  -0.0746  0.372   -0.236  -0.135 
#>  8 sits  -0.151  0.242   0.357   0.131  -0.296   0.351   0.233    0.0952 -0.0265
#>  9 comp… -0.191  0.0344  0.321  -0.134  -0.334   0.265   0.383    0.0901 -0.234 
#> 10 neig… -0.148  0.293   0.0111 -0.198   0.204   0.0945  0.0269   0.385  -0.0447
#> # … with 117 more rows, and 11 more variables: dim_9 <dbl>, dim_10 <dbl>,
#> #   dim_11 <dbl>, dim_12 <dbl>, dim_13 <dbl>, dim_14 <dbl>, dim_15 <dbl>,
#> #   dim_16 <dbl>, dim_17 <dbl>, dim_18 <dbl>, dim_19 <dbl>
```

## License

MIT license.

Icons made by [Freepik](https://www.freepik.com) from
[www.flaticon.com](https://www.flaticon.com/).
