using BenchmarkTools


function flattenall(A::AbstractArray)
    while any(x -> typeof(x) <: AbstractArray, A)
        A = collect(Base.Iterators.flatten(A))
    end

    return A
end

deepunique(A::AbstractArray) = unique(flattenall(A))

function count_yes(datafile::String)
    data = Vector{Int}()
    
    open(datafile) do io
        while ! eof(io)
            buffer = Vector{Vector{Char}}()
            line = readline(io)
            
            while ! isempty(line)
                push!(buffer, collect(line))
                line = readline(io)
            end
            
            push!(data, length(deepunique(buffer)))
        end
    end
    
    return sum(data)
end

@benchmark count_yes("day6_input.txt")


function count_unanimous(datafile::String)
    data = Vector{Int}()

    open(datafile) do io
        while ! eof(io)
            buffer = Vector{Vector{Char}}()
            line = readline(io)

            while ! isempty(line)
                push!(buffer, collect(line))
                line = readline(io)
            end

            push!(data, length([i for i in deepunique(buffer) if all(x -> i ∈ x, buffer)]))
        end
    end

    return sum(data)
end

@benchmark (count_unanimous("day6_input.txt"))