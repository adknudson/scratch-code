import Automa
import Automa.RegExp: @re_str
const re = Automa.RegExp


if !isfile("29765-8.txt")
    run(`unzip ./webster.zip`)
end

open("29765-8.txt") do f
    line = 0
    while !eof(f)
        s = readline(f)
        line += 1
    end
end