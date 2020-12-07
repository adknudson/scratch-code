using IterTools
using BenchmarkTools

s = open("day1_input.txt") do file
    Array([parse(Int, l) for l in readlines(file)])
end


#=
Rather than finding all pairs (using `subsets`), I exploit the fact that the
sum is 2020 and find the pairs where the last digits add to 10. From there I
can find all the pairs within the complements and then search for the solution.
=#



function ten_complement(x, n)
    if n == 0
        (x[x .% 10 .== 0],)
    elseif n == 5
        (x[x .% 10 .== 5],)
    else
        (x[x .% 10 .== n], x[x .% 10 .== (10-n)])
    end
end


sums_to(a, b) = (a + b) == 2020


function expense_report(s)
    for lsd in 0:5
        pairs = ten_complement(s, lsd)
        if length(pairs) == 1
            for i in subsets(pairs..., Val{2}())
                sum(i) == 2020 && return(i)
            end
        else
            for i in product(pairs...)
                sum(i) == 2020 && return(i)
            end
        end
    end
end

pair = expense_report(s)
sum(pair)
prod(pair)

@benchmark expense_report($s)
