using LightGraphs, SimpleWeightedGraphs


function parse_contents(str, D)
    m = match(r"(\d) (\w+ \w+) bags{0,1}[,|\.] (.*)", str)
    if isnothing(m)
        a, b = match(r"(\d) (\w+ \w+) bags{0,1}\.", str).captures
        return [(D[b], parse(Int, a))]
    else
        a, b, c = m.captures
        return [(D[b], parse(Int, a)), parse_contents(c, D)...]
    end
end

function make_adj(str, D)
    am = zeros(Int, length(D), length(D))
    for r in readlines(str)
        container, contains = match(r"^(\w+ \w+) bags{0,1} contain (.*)$", r).captures
        if occursin("no other bags.", contains)
            continue
        else
            i, j = D[container], parse_contents(contains, D)
            view(am, i, first.(j)) .= last.(j)
        end
    end
    am
end

function digraph_from_input(str)
    containers = open(str) do io
        S = Set{String}()
        while !eof(io)
            r = readline(io)
            container, contains = match(r"^(\w+ \w+) bags{0,1} contain (.*)$", r).captures
            if container ∉ S
                push!(S, container)
            end
        end
        S
    end
    D = Dict(a => b for (b, a) in enumerate(containers))
    am = make_adj(str, D)
    D, am
end

function dream_within_a_dream(g, root)
    N = neighbors(g, root)
    if isempty(N)
        return 0
    else
        return sum([get_weight(g, root, n) * (1 + dream_within_a_dream(g, n)) for n in N])
    end
end


D, am = digraph_from_input("day7_input.txt")
sg = D["shiny gold"]

# Part 1
g1 = SimpleDiGraph(am)
from_v_to_sg = [has_path(g1, from, sg) for from in vertices(g1)]
sum(from_v_to_sg) - 1

# Part 2
g2 = SimpleWeightedDiGraph(am)
dream_within_a_dream(g2, sg)