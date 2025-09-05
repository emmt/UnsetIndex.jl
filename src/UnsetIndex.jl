module UnsetIndex

export unset, unsetindex!

using Base: @propagate_inbounds, isbitsunion

# Singleton type for `unset` constant.
struct Unset end

"""
    A[i] = unset
    setindex!(A, unset, i) -> A

Delete non-bit object stored at index `i` of array `A`. This amounts to calling
[`unsetindex!(A, i)`](@ref unsetindex!) which to see.

It is also possible to unset entries using dot notation. For example:

    @. A = unset       # unset all entries of A
    A[:] .= unset      # unset all entries of A
    A[3:2:15] .= unset # unset every other entry of A between the 3rd and the 15th

"""
const unset = Unset()

Base.show(io::IO, ::Unset) = print(io, "#undef")

"""
    unsetindex!(A, i) -> A

Delete entry at index `i` of array `A` if it has a non-bit type; otherwise, the entry is
left unchanged. In any case, bound checking is performed unless `@inbounds` is active.

Deleted entries are undefined as can be checked by `isassigned(A, i)` and print as `#undef`
in the REPL.

This is useful to effectively delete objects stored in arrays without changing anything else
in the array, unlike `deleteat!(A,i)` or `popat!(A,i)` which reduce the size of `A` and
shift its elements.

!!! warning
    `A` must be of type `Array` or `Memory`.

"""
function unsetindex! end

let arraytypes = [:Array]
    @static if isdefined(Base, :Memory)
        push!(arraytypes, :Memory)
    end
    for type in arraytypes
        @eval begin
            @propagate_inbounds Base.setindex!(A::$type, ::Unset, i::Int) = unsetindex!(A, i)
            @propagate_inbounds Base.setindex!(A::$type{Any}, ::Unset, i::Int) = unsetindex!(A, i)
        end
        @static if isdefined(Base, :_unsetindex!)
            @eval @propagate_inbounds unsetindex!(A::$type, i::Int) = Base._unsetindex!(A, i)
        else
            @eval @inline function unsetindex!(A::$type{T}, i::Int) where {T}
                @boundscheck checkbounds(A, i)
                isbitstype(T) || isbitsunion(T) || ccall(:jl_arrayunset, Cvoid, (Any, UInt), A, i - 1)
                return A
            end
        end
    end
end

# Abstract array API for `unset` to behave like a `Number`.
Base.ndims(::Type{Unset}) = 0
Base.eltype(::Type{Unset}) = Unset
Base.length(::Unset) = 1
Base.size(::Unset) = ()
Base.axes(::Unset) = ()
Base.getindex(x::Unset) = x
Base.isempty(x::Unset) = false
Base.iterate(x::Unset) = (x, nothing)
Base.iterate(x::Unset, ::Any) = nothing
Base.IteratorEltype(::Type{Unset}) = Base.HasEltype()
Base.IteratorSize(::Type{Unset}) = Base.HasLength() # FIXME not Base.HasShape{0}() for dot notation to work

end # module
