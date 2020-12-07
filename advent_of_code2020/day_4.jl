using BenchmarkTools

const kv_regex = r"(\S+):(\S+)"
const valid_northpole_keys = (:byr, :iyr, :eyr, :hgt, :hcl, :ecl, :pid)

array_to_dict(A) = Dict(Symbol(m.captures[1]) => m.captures[2] for m in match.(kv_regex, A))
parse_record(S) = SubString.(S, findall(kv_regex, S))
has_all_keys(D, ks) = all(in(keys(D)), ks)

passports = open("day4_input.txt") do io
    records = Vector{String}()
    while !eof(io)
        buffer = Vector{String}()
        r = readline(io)
        while (r != "")
            push!(buffer, r)
            r = readline(io)
        end
        buffer = join(buffer, " ")
        push!(records, buffer)
    end
    split_records = parse_record.(records)
    array_to_dict.(split_records)
end

northpole_passports = filter(x -> has_all_keys(x, valid_northpole_keys), passports)
@benchmark filter(x -> has_all_keys(x, valid_northpole_keys), passports)

#= PART 2
You can continue to ignore the cid field, but each other field has strict rules
about what values are valid for automatic validation:

 - byr (Birth Year)      - four digits; at least 1920 and at most 2002.
 - iyr (Issue Year)      - four digits; at least 2010 and at most 2020.
 - eyr (Expiration Year) - four digits; at least 2020 and at most 2030.
 - hgt (Height)          - a number followed by either cm or in:
   - If cm, the number must be at least 150 and at most 193.
   - If in, the number must be at least 59 and at most 76.
 - hcl (Hair Color)      - a # followed by exactly six characters 0-9 or a-f.
 - ecl (Eye Color)       - exactly one of: amb blu brn gry grn hzl oth.
 - pid (Passport ID)     - a nine-digit number, including leading zeroes.
 - cid (Country ID)      - ignored, missing or not.

Your job is to count the passports where all required fields are both present 
and valid according to the above rules. Here are some example values:
=#

validate_yr(str, lo, hi) = lo ≤ parse(Int, str) ≤ hi
function validate_hgt(str)
    hgt, unit = match(r"(\d+)(\w+)", str).captures
    hgt = parse(Int, hgt)
    unit == "in" ? 59 ≤ hgt ≤ 76 : unit == "cm" ? 150 ≤ hgt ≤ 193 : false
end
validate_hcl(str) = !isnothing(match(r"^#[0-9a-f]{6}$", str))
validate_ecl(str) = any([str == clr for clr in ("amb", "blu", "brn", "gry", "grn", "hzl", "oth")])
validate_pid(str) = !isnothing(match(r"^\d{9}$", str))

function is_valid_northpole_passport(D)
    validate_yr(D[:byr], 1920, 2002) &
    validate_yr(D[:iyr], 2010, 2020) &
    validate_yr(D[:eyr], 2020, 2030) &
    validate_hgt(D[:hgt]) &
    validate_hcl(D[:hcl]) &
    validate_ecl(D[:ecl]) &
    validate_pid(D[:pid])
end


valid_northpole_passports = filter(is_valid_northpole_passport, northpole_passports)
@benchmark filter(is_valid_northpole_passport, northpole_passports)