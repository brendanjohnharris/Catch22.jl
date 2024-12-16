using Catch22
using Random
using Test
using BenchmarkTools
using Libdl

n = 10000
N = 1000

fs = Catch22.features

function compute(dataset)
    Threads.@threads for d in dataset
        [f(d) for f in fs]
    end
end

t = @benchmark compute(dataset) setup=(dataset = [randn(n) for _ in 1:N]) seconds=30
println("Single-threaded method time: $(median(t.times)/10^9) seconds") # * 8.75 seconds
println("Multi-threaded method memory: $(median(t.memory)|>Base.format_bytes)") # * 1.29 MiB
# ? No z score applied here, so far lower mem usage
