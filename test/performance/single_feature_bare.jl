using catch22_jll
using Random
using Test
using BenchmarkTools
using Libdl

n = 2000
N = 1000

catch22_jll.__init__()
lib = dlopen(libcatch22)
libf = dlsym(lib, :PD_PeriodicityWang_th0_01)

function compute_feature(x)::Float64
    ccall(libf, Cdouble, (Ptr{Cdouble}, Csize_t), x, length(x))
end

function compute(dataset)::Vector{Float64}
    map(compute_feature, dataset)
end

t = @benchmark compute(dataset) setup=(dataset = [randn(n) for _ in 1:N])
println("Single-threaded method time: $(median(t.times)/10^9) seconds") # * 1.06 seconds
