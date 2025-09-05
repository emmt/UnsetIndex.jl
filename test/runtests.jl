using UnsetIndex
using Test

@testset "UnsetIndex.jl" begin
    map_isassigned(A::AbstractArray) = map(i -> isassigned(A, i), eachindex(A))
    @test string(unset) == "#undef"
    let A = ["Hello", "new", "world!"]
        @test map_isassigned(A) == [true, true, true]
        @test (@inferred unsetindex!(A, 1)) === A
        @test map_isassigned(A) == [false, true, true]
        A[end] = unset
        @test map_isassigned(A) == [false, true, false]
        A[2] = unset
        @test map_isassigned(A) == [false, false, false]
    end
    if isdefined(Base, :Memory) # Memory appears in Julia 1.11
        let A = Memory{String}(undef, 3)
            A[1] = "This"
            A[2] = "is"
            A[3] = "wonderful!"
            @test map_isassigned(A) == [true, true, true]
            @test (@inferred unsetindex!(A, 1)) === A
            @test map_isassigned(A) == [false, true, true]
            A[end] = unset
            @test map_isassigned(A) == [false, true, false]
            A[2] = unset
            @test map_isassigned(A) == [false, false, false]
        end
    end
end
