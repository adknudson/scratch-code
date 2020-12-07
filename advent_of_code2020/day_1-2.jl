using IterTools
using BenchmarkTools

s = open("day1_input.txt") do file
    Array([parse(Int, l) for l in readlines(file)])
end

function expense_report(x)
    for i in subsets(x, Val{3}())
        sum(i) == 2020 && return(i)
    end
end

triplet = expense_report(s)
sum(triplet)
prod(triplet)

@benchmark expense_report(s)
