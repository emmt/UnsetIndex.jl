using UnsetIndex
using Test
using Aqua

@testset "UnsetIndex.jl" begin
    map_isassigned(A::AbstractArray) = map(i -> isassigned(A, i), eachindex(A))
    @test string(unset) == "#undef"
    @testset "T = $T" for T in (String, Any)
        A = T["Hello", "new", "world!"]
        @test map_isassigned(A) == [true, true, true]
        @test (@inferred unsetindex!(A, 1)) === A
        @test map_isassigned(A) == [false, true, true]
        A[end] = unset
        @test map_isassigned(A) == [false, true, false]
        A[2] = unset
        @test map_isassigned(A) == [false, false, false]
        if isdefined(Base, :Memory) # Memory appears in Julia 1.11
            B = Memory{T}(undef, 3)
            B[1] = "This"
            B[2] = "is"
            B[3] = "wonderful!"
            @test map_isassigned(B) == [true, true, true]
            @test (@inferred unsetindex!(B, 1)) === B
            @test map_isassigned(B) == [false, true, true]
            B[end] = unset
            @test map_isassigned(B) == [false, true, false]
            B[2] = unset
            @test map_isassigned(B) == [false, false, false]
        end
    end
end

Aqua.test_all(UnsetIndex)
