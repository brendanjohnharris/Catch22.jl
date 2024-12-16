using Catch22
using Random
using BenchmarkTools

n = 2000
N = 1000

feature = PD_PeriodicityWang_th0_01
function compute(dataset)::Vector{Float64}
    map(feature, dataset)
end

t = @benchmark compute(dataset) setup=(dataset = [randn(n) for _ in 1:N])
println("Single-threaded method time: $(median(t.times)/10^9) seconds") # * 1.08 seconds
