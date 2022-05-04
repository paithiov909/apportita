
<!-- README.md is generated from README.Rmd. Please edit that file -->

# apportita <a href='https://paithiov909.github.io/apportita'><img src='man/figures/logo.png' align="right" height="139" /></a>

> \[WIP\] Utility for Handling ‘magnitude’ Word Embeddings

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
library does, thus some functionality would not be implemented.

-   [x] Querying for out-of-vocabulary keys
-   [x] Original slicing queries (`slice_frac`, `slice_index`)
-   [ ] tests and examples

## License

MIT license. Icons made by [Freepik](https://www.freepik.com) from
[www.flaticon.com](https://www.flaticon.com/).
