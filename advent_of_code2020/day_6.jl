using BenchmarkTools

input = split.(split(join(readlines("day6_input.txt"), "\n"), "\n\n"), r"\s+")
# part 1
sum(length, union(A...) for A in input)
# part 2
sum(length, intersect(A...) for A in input)

solve_p1() = begin
    input = split.(split(join(readlines("day6_input.txt"), "\n"), "\n\n"), r"\s+")
    sum(length, union(A...) for A in input)
end

solve_p2() = begin
    input = split.(split(join(readlines("day6_input.txt"), "\n"), "\n\n"), r"\s+")
    sum(length, intersect(A...) for A in input)
end

@benchmark solve_p1()
@benchmark solve_p2()
