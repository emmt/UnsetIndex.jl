using UnsetIndex
using Test
using Aqua

@testset "UnsetIndex.jl" begin
    map_isassigned(A::AbstractArray) = map(i -> isassigned(A, i), eachindex(A))
    @testset "`unset` singleton" begin
        @test string(unset) == "#undef"
        @test ndims(unset) === ndims(typeof(unset)) === 0
        @test eltype(unset) === eltype(typeof(unset)) === typeof(unset)
        @test length(unset) === 1
        @test size(unset) === ()
        @test axes(unset) === ()
        @test unset[] === unset
        @test !isempty(unset)
        @test (unset...,) === (unset,)
        A = @inferred collect(unset)
        @test A isa Array{typeof(unset),1} # FIXME Array{typeof(unset),0}
        @test A[1] === unset               # FIXME A[]
        @test Base.IteratorEltype(unset) === Base.HasEltype()
        @test Base.IteratorSize(unset) === Base.HasLength()
    end
    words = split("This is a wonderful world indeed!")
    arraytypes = (Array,)
    if isdefined(Base, :Memory) # Memory appears in Julia 1.11
        arraytypes = (arraytypes..., Memory)
    end
    @testset "Unset entries of $A{$T}" for A in arraytypes, T in (String, Any)
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
