using Distributed
addprocs(20)
@everywhere begin
  using Pkg
  Pkg.activate(".")
  using SharedArrays
end

A = SharedMatrix{Float64}(10000, 10000)
@time @sync @distributed for i in 1:10000*10000
  @inbounds A[i] = rand()
end

B = Matrix{Float64}(undef, 10000, 10000)
@time for i in 1:10000*10000
  B[i] = rand()
end