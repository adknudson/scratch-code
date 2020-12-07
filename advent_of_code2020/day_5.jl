function binary_search(str, c, lo, hi)
    if str == ""
        return lo
    elseif str[1] == c
        binary_search(str[2:end], c, lo, lo + (hi - lo) ÷ 2)
    else
        binary_search(str[2:end], c, hi - (hi - lo) ÷ 2, hi)
    end
end

function parse_seat(str)
    FB, LR = match(r"([BF]{7})([RL]{3})", str).captures
    row = binary_search(FB, 'F', 0, 127)
    col = binary_search(LR, 'L', 0, 7)   
    row, col, row*8+col
end

# from zulip
# seatid(s) = parse(Int, map(c -> c ∈ ('R', 'B') ? '1' : '0', s), base = 2)
# seatid.(readlines("day5_input.txt"))


# part 1
seats = parse_seat.(readlines("day5_input.txt"))
ids = map(x->x[3], seats)
maximum(ids)

# part 2
all_ids = collect(minimum(ids):maximum(ids))
setdiff(all_ids, ids)
