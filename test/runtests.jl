using UnsetIndex
using Test
using Aqua

@testset "UnsetIndex.jl" begin
    map_isassigned(A::AbstractArray) = map(i -> isassigned(A, i), eachindex(A))
    @test string(unset) == "#undef"
    words = split("This is a wonderful world indeed!")
    arraytypes = (Array,)
    if isdefined(Base, :Memory) # Memory appears in Julia 1.11
        arraytypes = (arraytypes..., Memory)
    end
    @testset "$A{$T}" for A in arraytypes, T in (String, Any)
        X = A{T}(undef, length(words))
        copyto!(X, words)
        @test (@inferred unsetindex!(X, 1)) === X
        @test map_isassigned(X) == [false, true, true, true, true, true]
        X[end] = unset
        @test map_isassigned(X) == [false, true, true, true, true, false]
        X[1:2:5] .= unset
        @test map_isassigned(X) == [false, true, false, true, false, false]
        copyto!(X, words)
        X[:] .= unset
        @test map_isassigned(X) == [false, false, false, false, false, false]
        copyto!(X, words)
        @. X = unset
        @test map_isassigned(X) == [false, false, false, false, false, false]
    end
end

Aqua.test_all(UnsetIndex)
