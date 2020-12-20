using BenchmarkTools

#=
Each line gives the password policy and then the password. The password policy 
indicates the lowest and highest number of times a given letter must appear for
the password to be valid. For example, `1-3 a` means that the password must
contain a at least 1 time and at most 3 times.
=#

function solution(str)
    sol1, sol2 = 0, 0
    for line in readlines(str)
        x, y, (char,), pw = match(r"([0-9]+)-([0-9]+)\s*([a-zA-z]): (.*)", line).captures
        x, y = parse.(Int, (x, y))
        sol1 += x ≤ count(==(char), pw) ≤ y
        sol2 += (pw[x] == char) ⊻ (pw[y] == char)
    end
    sol1, sol2
end

solution("day2_input.txt")

@benchmark solution("day2_input.txt")