# UnsetIndex

[![Build Status](https://github.com/emmt/UnsetIndex.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/emmt/UnsetIndex.jl/actions/workflows/CI.yml?query=branch%3Amain) [![Build Status](https://ci.appveyor.com/api/projects/status/github/emmt/UnsetIndex.jl?svg=true)](https://ci.appveyor.com/project/emmt/UnsetIndex-jl) [![Coverage](https://codecov.io/gh/emmt/UnsetIndex.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/emmt/UnsetIndex.jl)
[![Aqua QA](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)

`UnsetIndex` is a [Julia](https://www.julialang.org) package to effectively delete objects
stored in arrays and without changing anything else in the array unlike `deleteat!(A,i)` or
`popat!(A,i)` which reduce the size of `A` and shift its elements.

`UnsetIndex` exports two symbols, a function `unsetindex!` and a constant `unset`, whose
usage is as follows:

``` julia
using UnsetIndex
unsetindex!(A, i)
A[i] = unset
setindex!(A, unset, i)
```

The former 3 statements are equivalent and delete the entry at index `i` of array `A` if it
has a non-bit type; otherwise, the entry is left unchanged. In any case, bound checking is
performed unless `@inbounds` is active. The only restriction is that `A` must be of type
`Array` or `Memory`.

For example:

``` julia
julia> A = ["hello", "world!"]
2-element Vector{String}:
 "hello"
 "world!"

julia> A[end] = unset
#undef

julia> A
2-element Vector{String}:
    "hello"
 #undef

julia> map(i -> isassigned(A, i), eachindex(A))
2-element Vector{Bool}:
 1
 0

```

It is also possible to unset entries using dot notation. For example:

``` julia
@. A = unset       # unset all entries of A
A[:] .= unset      # unset all entries of A
A[3:2:15] .= unset # unset every other entry of A between the 3rd and the 15th
```
