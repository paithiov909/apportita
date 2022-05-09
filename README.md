
<!-- README.md is generated from README.Rmd. Please edit that file -->

# apportita <a href='https://paithiov909.github.io/apportita'><img src='man/figures/logo.png' align="right" height="139" /></a>

> Utility for Handling ‘magnitude’ Word Embeddings

<!-- badges: start -->
<!-- badges: end -->

Apportita is a partial R port from
[plasticityai/magnitude](https://github.com/plasticityai/magnitude),
which is a fast, simple utility library for handling vector embeddings.

## Roadmap

Apportita would cover only partial features of the original Magnitude
library. The main goal of this package is to enable access to user’s
local magnitude data store. In other words, apportita would not support
streaming access to remote sqlite files.

The package mainly targets the range where the
[magnitude-light](https://github.com/davebulaval/magnitude-light)
library does, thus some functionalities would not be implemented.

-   [x] Querying for out-of-vocabulary keys
-   [x] Original slicing queries (`slice_frac`, `slice_index`)
-   [ ] tests and examples

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
#>         i      love     movie 
#> 0.9480003 0.7461417 0.6085849

apportita::most_similar(conn, "book", c("i", "love", "movie"), n = 3)
#>     movie      love         i 
#> 0.8148123 0.7216363 0.5506478
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
#>    key     dim_0    dim_1   dim_2   dim_3   dim_4   dim_5    dim_6   dim_7 dim_8
#>    <chr>   <dbl>    <dbl>   <dbl>   <dbl>   <dbl>   <dbl>    <dbl>   <dbl> <dbl>
#>  1 marc    0.472 -0.0843  -0.191  -0.260  -0.155  -0.187  -0.0286   0.279  0.167
#>  2 schell  0.155  0.121   -0.113  -0.300   0.0883 -0.0321  0.0231   0.169  0.288
#>  3 obser…  0.401 -0.307    0.149   0.219  -0.163  -0.114  -0.0374  -0.0848 0.391
#>  4 dylan   0.276 -0.00328 -0.106  -0.340   0.0757 -0.117   0.0369   0.248  0.283
#>  5 reno    0.210  0.103   -0.134  -0.350   0.0602 -0.0873  0.0148   0.228  0.301
#>  6 raised  0.447 -0.0411  -0.186  -0.299  -0.0983 -0.201  -0.0252   0.320  0.192
#>  7 teen    0.424 -0.0567  -0.199  -0.406  -0.166  -0.341  -0.0131   0.343  0.117
#>  8 maslin -0.290  0.147    0.0222 -0.0675 -0.303  -0.189  -0.0544   0.0876 0.165
#>  9 karlo…  0.345 -0.00816 -0.118  -0.288  -0.0224 -0.115  -0.00692  0.225  0.264
#> 10 nowhe…  0.455 -0.0728  -0.0350 -0.209  -0.158  -0.311  -0.201    0.338  0.283
#> # … with 117 more rows, and 11 more variables: dim_9 <dbl>, dim_10 <dbl>,
#> #   dim_11 <dbl>, dim_12 <dbl>, dim_13 <dbl>, dim_14 <dbl>, dim_15 <dbl>,
#> #   dim_16 <dbl>, dim_17 <dbl>, dim_18 <dbl>, dim_19 <dbl>
```

## License

MIT license. Icons made by [Freepik](https://www.freepik.com) from
[www.flaticon.com](https://www.flaticon.com/).
