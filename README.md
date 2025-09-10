# UnsetIndex

[![Build Status](https://github.com/emmt/UnsetIndex.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/emmt/UnsetIndex.jl/actions/workflows/CI.yml?query=branch%3Amain) [![Build Status](https://ci.appveyor.com/api/projects/status/github/emmt/UnsetIndex.jl?svg=true)](https://ci.appveyor.com/project/emmt/UnsetIndex-jl) [![Coverage](https://codecov.io/gh/emmt/UnsetIndex.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/emmt/UnsetIndex.jl)
[![Aqua QA](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)

**UnsetIndex** is a [Julia](https://www.julialang.org) package to effectively delete objects
stored in arrays and without changing anything else in the array unlike `deleteat!(A,i)` or
`popat!(A,i)` which reduce the size of `A` and may shift its elements.

## Usage

**UnsetIndex** exports two symbols, the `unsetindex!` function and the `unset` constant,
whose usage is as follows:

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

## Discussion and alternatives

Means to unset array elements have always existed in Julia (at least since version 0.7) but
were not exposed for usage in other packages. The non-exported `Base._unsetindex!` function
appeared in Julia 1.3 but, as of Julia 1.12, this function is neither documented nor
`public`. Prior to Julia 1.3, the C function `jl_arrayunset` have to be called with `ccall`.
The `unsetindex!` function of **UnsetIndex** is a public and documented equivalent to
`Base._unsetindex!` for any Julia version (since 1.0). The `unset` constant of
**UnsetIndex** implements a portable, simple, and intuitive syntax.

The `@undef!` macro provided by the [`Undefs`](https://github.com/mkitti/Undefs.jl) package
deals with the same issue but differently: `@undef! A[i]` to unset `i`-th element but `i`
must be a scalar index and `A` must be an `Array` (not a `Memory`).

See this [discussion in Julia
Discourse](https://discourse.julialang.org/t/undefs-jl-convenience-and-experiment).
