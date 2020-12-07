using CircularArrays
using Underscores
using BenchmarkTools


parse_terrain(str) = @_ readlines(str) .|>
    collect .|> 
    (_ .== '#') |>
    hcat(__...) |> 
    permutedims |>
    CircularArray


function slide(H; right::Int, down::Int)
    i, j = 1, 1
    h, w = size(H)
    s = 0
    for _ in 1:down:h-1
        j = j + right
        i = i + down
        s += H[i, j]
    end
    s
end


h = parse_terrain("day3_input.txt")
slide(h; right=3, down=1)

test_slopes = [(1, 1), (3, 1), (5, 1), (7, 1), (1, 2)]
prod([slide(h; right=r, down=d) for (r, d) in test_slopes])

@benchmark slide($h; right=3, down=1)
@benchmark prod([slide(h; right=r, down=d) for (r, d) in test_slopes])