# apportita <a href='https://paithiov909.github.io/apportita'><img src='man/figures/logo.png' align="right" height="139" /></a>

> [WIP] Utilities for Handling 'magnitude' Word Embeddings

Apportita is a partial R port from [plasticityai/magnitude](https://github.com/plasticityai/magnitude), which is a fast, simple utility library for handling vector embeddings.

## Roadmap

Apportita would cover only partial features of the original Magnitude library. The main goal of this package is to enable access to user's local magnitude data store.
In other words, apportita would not support streaming access to remote sqlite files.

The package mainly targets the range where the [magnitude-light](https://github.com/davebulaval/magnitude-light) library does, thus some functionality would not be implemented.

- [x] Querying out-of-vocabulary keys 
- [ ] `most_similar` querying (`_db_query_similarity`)
- [ ] `closer_than` querying
- [x] Original slicing queries (`slice_frac`, `slice_index`)

## License

MIT license. Icons made by [Freepik](https://www.freepik.com) from
[www.flaticon.com](https://www.flaticon.com/).
