mutable struct Passport
    byr::Union{String, Missing}
    iyr::Union{String, Missing}
    eyr::Union{String, Missing}
    hgt::Union{String, Missing}
    hcl::Union{String, Missing}
    ecl::Union{String, Missing}
    pid::Union{String, Missing}
    cid::Union{String, Missing}
    
    # initialising passport
    function Passport()
        byr, iyr, eyr, hgt, hcl, ecl, pid, cid =
            missing, missing, missing, missing, missing, missing, missing, missing
        new(byr, iyr, eyr, hgt, hcl, ecl, pid, cid)
    end
end

function parse_data(datafile::String)
    passports = Vector{Passport}()
    input = readlines(datafile)
    
    line_counter = 1
    passport = Passport()
    for line in input
        if isempty(line)
            push!(passports, passport)
            line_counter += 1
            passport = Passport()
            continue
        end
    
        split_line = split(line, r"[ :]")
        for i in 1:length(split_line)
            if isodd(i)
                setfield!(passport, Symbol(split_line[i]), string(split_line[i + 1]))
            end
        end
        
        if length(input) == line_counter
            push!(passports, passport)
        end
        
        line_counter += 1
    end
    
    return passports
end

parse_data("day4_input.txt")

function validate_passport(p::Passport)
    for f in fieldnames(Passport)
        if f == :cid && ismissing(getfield(p, f))
            continue
        end
        
        if ismissing(getfield(p, f))
            return false
        end
    end
    
    return true
end

function count_valid_ish_passports(passports::Vector{Passport})
    return sum(validate_passport.(passports))
end

println(count_valid_ish_passports(parse_data("day4_input.txt")))

#=
BenchmarkTools.Trial:
  memory estimate:  550.70 KiB
  allocs estimate:  8833
  --------------
  minimum time:     1.704 ms (0.00% GC)
  median time:      1.879 ms (0.00% GC)
  mean time:        2.007 ms (1.69% GC)
  maximum time:     6.195 ms (64.76% GC)
  --------------
  samples:          2490
  evals/sample:     1
=#

mutable struct PassportStrict
    byr::Union{Int, Missing}
    iyr::Union{Int, Missing}
    eyr::Union{Int, Missing}
    hgt::Union{Int, Missing}
    hcl::Union{String, Missing}
    ecl::Union{String, Missing}
    pid::Union{String, Missing}
    cid::Union{String, Missing}
    
    # initialising passport
    function PassportStrict()
        byr, iyr, eyr, hgt, hcl, ecl, pid, cid =
            missing, missing, missing, missing, missing, missing, missing, missing
        new(byr, iyr, eyr, hgt, hcl, ecl, pid, cid)
    end
end

function parse_data_strict(datafile::String)
    passports = Vector{PassportStrict}()
    input = readlines(datafile)
    
    line_counter = 1
    passport = PassportStrict()
    for line in input
        if isempty(line)
            push!(passports, passport)
            line_counter += 1
            passport = PassportStrict()
            continue
        end
        
        split_line = split(line, r"[ :]")
        for i in 1:length(split_line)
            if isodd(i)
                field, value = Symbol(split_line[i]), split_line[i + 1]
                
                # if the fields don't align with the restrictions, we set them to nothing to disqualify them
                if field == :byr
                    try_val = tryparse(Int, value)
                    
                    if ! isnothing(try_val)
                        value = try_val
                    end
                    
                    if ! (1920 ≤ value ≤ 2002)
                        value = nothing
                    end
                elseif field == :iyr
                    try_val = tryparse(Int, value)
                    
                    if ! isnothing(try_val)
                        value = try_val
                    end
                    
                    if ! (2010 ≤ value ≤ 2020)
                        value = nothing
                    end
                elseif field == :eyr
                    try_val = tryparse(Int, value)
                    
                    if ! isnothing(try_val)
                        value = try_val
                    end
                    
                    if ! (2020 ≤ value ≤ 2030)
                        value = nothing
                    end
                elseif field == :hgt
                    try_val = tryparse(Int, value)
                    units = string()
                    
                    if isnothing(try_val) # then the value has a unit of measurement
                        value, units = parse(Int, value[1:end - 2]), string(value[end - 1:end])
                    else
                        value = try_val
                    end
                    
                    if ! isnothing(value)
                        if units == "cm"
                            if ! (150 ≤ value ≤ 193)
                                value = nothing
                            end
                        elseif units == "in"
                            if ! (59 ≤ value ≤ 76)
                                value = nothing
                            end
                        else # then units do not exist
                            value = nothing
                        end
                    end
                elseif field == :hcl
                    value = string(value)
                    
                    if isnothing(match(r"^#[0-9a-f]{6}", value))
                        value = nothing
                    end
                elseif field == :ecl
                    value = string(value)
                    
                    if value ∉ ["amb", "blu", "brn", "gry", "grn", "hzl", "oth"]
                        value = nothing
                    end
                elseif field == :pid
                    value = string(value)
                    
                    if isnothing(match(r"[0-9]{9}", value))
                        value = nothing
                    elseif length(value) ≠ 9
                        value = nothing
                    end
                elseif field == :cid
                    value = string(value)
                end
                
                setfield!(passport, field, value)
            end
        end
        
        if length(input) == line_counter
            push!(passports, passport)
        end
        
        line_counter += 1
    end
    
    return passports
end

println(count_valid_ish_passports(parse_data_strict("data4.txt")))