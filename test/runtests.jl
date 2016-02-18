using PlanOut
using Base.Test

tests = ["core_ops", "random_ops"]

for t in tests
    fp = joinpath(dirname(@__FILE__), "test_$t.jl")
    println("$fp ...")
    include(fp)
end
