### A Pluto.jl notebook ###
# v0.12.16

using Markdown
using InteractiveUtils

# ╔═╡ 25533c0e-3b06-11eb-3392-5dc41ce2cfeb
md"""
# Day 8: Handheld Halting

Your flight to the major airline hub reaches cruising altitude without incident. While you consider checking the in-flight menu for one of those drinks that come with a little umbrella, you are interrupted by the kid sitting next to you.

Their handheld game console won't turn on! They ask if you can take a look.

You narrow the problem down to a strange **infinite loop** in the boot code (your puzzle input) of the device. You should be able to fix it, but first you need to be able to run the code in isolation.

The boot code is represented as a text file with one **instruction** per line of text. Each instruction consists of an **operation** (`acc`, `jmp`, or `nop`) and an **argument** (a signed number like `+4` or `-20`).

- `acc` increases or decreases a single global value called the **accumulator** by the value given in the argument. For example, `acc +7` would increase the accumulator by 7. The accumulator starts at `0`. After an `acc` instruction, the instruction immediately below it is executed next.
- `jmp` **jumps** to a new instruction relative to itself. The next instruction to execute is found using the argument as an **offset** from the `jmp` instruction; for example, `jmp +2` would skip the next instruction, `jmp +1` would continue to the instruction immediately below it, and `jmp -20` would cause the instruction `20` lines above to be executed next.
- `nop` stands for **No OPeration** - it does nothing. The instruction immediately below it is executed next.

For example, consider the following program:

```
nop +0
acc +1
jmp +4
acc +3
jmp -3
acc -99
acc +1
jmp -4
acc +6
```

These instructions are visited in this order:

```
nop +0  | 1
acc +1  | 2, 8(!)
jmp +4  | 3
acc +3  | 6
jmp -3  | 7
acc -99 |
acc +1  | 4
jmp -4  | 5
acc +6  |
```

First, the `nop +0` does nothing. Then, the accumulator is increased from 0 to 1 (`acc +1`) and `jmp +4` sets the next instruction to the other `acc +1` near the bottom. After it increases the accumulator from 1 to 2, `jmp -4` executes, setting the next instruction to the only `acc +3`. It sets the accumulator to 5, and `jmp -3` causes the program to continue back at the first `acc +1`.

This is an **infinite loop**: with this sequence of jumps, the program will run forever. The moment the program tries to run any instruction a second time, you know it will never terminate.

Immediately **before** the program would run an instruction a second time, the value in the accumulator is **`5`**.

Run your copy of the boot code. Immediately before any instruction is executed a second time, **what value is in the accumulator?**
"""

# ╔═╡ cfe0deaa-3b0c-11eb-2ed3-1fb8b05d05e2
parse_input(str) = [(Symbol(a), parse(Int, b)) for (a, b) in split.(readlines(str))]

# ╔═╡ f81637da-3b07-11eb-187e-256189fd05f7
mutable struct Instructions
	input::String
	pos::Int
	acc::Int
	num::Int
	visited::Set{Int}
    code::Array{Tuple{Symbol, Int64}, 1}

    Instructions(str) = begin
        code = parse_input(str)
        new(str, 1, 0, length(code), Set{Int}(), code)
    end

end

# ╔═╡ ff93cf2c-3b07-11eb-3207-c12a8135013d
Base.push!(I::Instructions) = push!(I.visited, I.pos)

# ╔═╡ 03e9c7f2-3b08-11eb-0381-25919343fe30
Base.accumulate!(I::Instructions, v::Int) = I.acc += v

# ╔═╡ 0813b7ca-3b08-11eb-20a8-0bc46c2d1edd
function read_state!(I::Instructions)
    push!(I)
    I.code[I.pos]
end

# ╔═╡ 0c2bf02a-3b08-11eb-1923-257c1cdb6edf
function execute_state!(I::Instructions, state)
    i, v = state
    if i == :nop
        I.pos += 1
    elseif i == :acc
        accumulate!(I, v)
        I.pos += 1
    else
        I.pos += v
    end
end

# ╔═╡ 1090cf16-3b08-11eb-0506-13c875038edc
function run!(I::Instructions)
    while I.pos ∉ I.visited
        state = read_state!(I)
        execute_state!(I, state)
		I.pos == I.num + 1 && return true
	end
	return false
end

# ╔═╡ 14926cc4-3b08-11eb-0f1f-8572570b8d18
begin
	boot_code = Instructions("day8_input.txt")
	run!(boot_code)
end

# ╔═╡ 1ec7aeb8-3b08-11eb-21d0-237b6cbcae6e
md"The accumulator value is: **$(boot_code.acc)**"

# ╔═╡ b4f523da-3b07-11eb-354e-0b478aca87e4
md"""
## Part Two

After some careful analysis, you believe that **exactly one instruction is corrupted**.

Somewhere in the program, **either** a `jmp` is supposed to be a `nop`, or a `nop` is supposed to be a `jmp`. (No `acc` instructions were harmed in the corruption of this boot code.)

The program is supposed to terminate by **attempting to execute an instruction immediately after the last instruction in the file**. By changing exactly one `jmp` or `nop`, you can repair the boot code and make it terminate correctly.

For example, consider the same program from above:

```
nop +0
acc +1
jmp +4
acc +3
jmp -3
acc -99
acc +1
jmp -4
acc +6
```

If you change the first instruction from `nop +0` to `jmp +0`, it would create a single-instruction infinite loop, never leaving that instruction. If you change almost any of the `jmp` instructions, the program will still eventually find another `jmp` instruction and loop forever.

However, if you change the second-to-last instruction (from `jmp -4` to `nop -4`), the program terminates! The instructions are visited in this order:

```
nop +0  | 1
acc +1  | 2
jmp +4  | 3
acc +3  |
jmp -3  |
acc -99 |
acc +1  | 4
nop -4  | 5
acc +6  | 6
```

After the last instruction (`acc +6`), the program terminates by attempting to run the instruction below the last instruction in the file. With this change, after the program terminates, the accumulator contains the value 8 (`acc +1`, `acc +1`, `acc +6`).

Fix the program so that it terminates normally by changing exactly one `jmp` (to `nop`) or `nop` (to `jmp`). **What is the value of the accumulator after the program terminates?**
"""

# ╔═╡ 9346dca8-3b0a-11eb-3e43-0ddcdf9d2e30
function restart!(I::Instructions)
	I.pos = 1;
	I.acc = 0;
	I.visited = Set{Int}();
	I.code = parse_input(I.input);
	return nothing
end

# ╔═╡ c974fc24-3b0a-11eb-0440-a9acb655243a
function debug!(I::Instructions)
	restart!(I)
    for (i, c) in enumerate(I.code)
		if c[1] == :acc
			continue
		elseif c[1] == :jmp
			I.code[i] = (:nop, c[2])
			run!(boot_code) && return (i, c)
			restart!(boot_code)
		else
			I.code[i] = (:jmp, c[2])
			run!(boot_code) && return (i, c)
			restart!(boot_code)
		end
	end	
end

# ╔═╡ 352e7fe2-3b0d-11eb-3dc2-7b7e93a73373
debug!(boot_code)

# ╔═╡ 719a0834-3b0d-11eb-0cc6-4f4c95b2853b
md"The accumulator value is: **$(boot_code.acc)**"

# ╔═╡ Cell order:
# ╟─25533c0e-3b06-11eb-3392-5dc41ce2cfeb
# ╠═cfe0deaa-3b0c-11eb-2ed3-1fb8b05d05e2
# ╠═f81637da-3b07-11eb-187e-256189fd05f7
# ╠═ff93cf2c-3b07-11eb-3207-c12a8135013d
# ╠═03e9c7f2-3b08-11eb-0381-25919343fe30
# ╠═0813b7ca-3b08-11eb-20a8-0bc46c2d1edd
# ╠═0c2bf02a-3b08-11eb-1923-257c1cdb6edf
# ╠═1090cf16-3b08-11eb-0506-13c875038edc
# ╠═14926cc4-3b08-11eb-0f1f-8572570b8d18
# ╟─1ec7aeb8-3b08-11eb-21d0-237b6cbcae6e
# ╟─b4f523da-3b07-11eb-354e-0b478aca87e4
# ╠═9346dca8-3b0a-11eb-3e43-0ddcdf9d2e30
# ╠═c974fc24-3b0a-11eb-0440-a9acb655243a
# ╠═352e7fe2-3b0d-11eb-3dc2-7b7e93a73373
# ╟─719a0834-3b0d-11eb-0cc6-4f4c95b2853b
