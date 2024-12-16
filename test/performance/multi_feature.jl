using Catch22
using Random
using BenchmarkTools

n = 10000
N = 1000

t = @benchmark $catch22(dataset) setup=(dataset = [randn(n) for _ in 1:N]) seconds=30
println("Multi-threaded method time: $(median(t.times)/10^9) seconds") # * 8.23 seconds
println("Multi-threaded method memory: $(median(t.memory)|>Base.format_bytes)") # * 78.8 MiB
