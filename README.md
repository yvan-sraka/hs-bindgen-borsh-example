# Example / Experiments with passing Rust datatypes to Haskell using hs-bindgen
- Example of passing a Rust struct to Haskell using hs-bindgen by first serializing it using borsh and deserializing the borsh in Haskell. 

# References:
- https://engineering.iog.io/2023-01-26-hs-bindgen-introduction/ - library I'm using
- https://github.com/well-typed/borsh
- https://well-typed.com/blog/2023/03/purgatory/ - Not using the lib mentioned - but using their idea of serializing / deserializing data (rather than managing pointers).
