get_index(i, n) = ((i-1) % n) + 1


struct HillMatrix <: AbstractArray{Int, 2}
    terrain::BitMatrix
end

Base.size(H::HillMatrix) = size(H.terrain)
Base.IndexStyle(::Type{<:HillMatrix}) = IndexCartesian()

function Base.getindex(H::HillMatrix, i, j) 
    # i = get_index(i, size(H.terrain, 1))
    j = get_index(j, size(H.terrain, 2))
    H.terrain[i,j]
end

function Base.show(io::IO, ::MIME"text/plain", H::HillMatrix)
    println(io, "Rough terrain ahead!")
    for r in eachrow(H)
        println(io, join([i == 1 ? '#' : '.' for i in r]))
    end
end



h = HillMatrix(BitArray([1 0 0; 0 1 1]))
h