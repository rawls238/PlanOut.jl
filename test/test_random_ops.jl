z = 3.29

function Counter(l)
  ret = Dict()
  for i in l
    if haskey(ret, i)
      ret[i] += 1
    else
      ret[i] = 1
    end
  end
  ret
end

function valueMassToDensity(value_mass)
  values = [i[1] for i in collect(value_mass)]
  ns = [i[2] for i in collect(value_mass)]
  ns_sum = float(sum(ns))
  Dict(zip(values, [i / ns_sum for i in ns]))
end

function distributionTester(func, assignment_key, dict, value_mass, N=1000)
  xs = []
  for i in 1:N
    a = Assignment(string(assignment_key))
    dict["unit"] = i
    setindex!(a, func(dict), "x")
    push!(xs, getindex(a, "x"))
  end

  value_density = valueMassToDensity(value_mass)
  assertProbs(xs, value_density, float(N))
end

function assertProbs(xs, value_density, N)
  hist = Counter(xs)
  for el in keys(hist)
    assertProp(hist[el] / N, value_density[el], N)
  end
end

function assertProp(observed_p, expected_p, N)
  @test abs(observed_p - expected_p) <= (z * sqrt(expected_p * (1 - expected_p) / N))
end

i = 20
a = Assignment("assign_salt_a")

setindex!(a, randominteger(Dict("min" => 0, "max" => 100000, "unit" => i)), "x")
setindex!(a, randominteger(Dict("min" => 0, "max" => 100000, "unit" => i)), "y")
@test getindex(a, "x") != getindex(a, "y")

setindex!(a, randominteger(Dict("min" => 0, "max" => 100000, "unit" => i, "salt" => "x")), "z")
@test getindex(a, "x") == getindex(a, "z")

b = Assignment("assign_salt_b")
setindex!(b, randominteger(Dict("min" => 0, "max" => 100000, "unit" => i)), "x")
@test getindex(a, "x") != getindex(b, "x")

setindex!(a, randominteger(Dict("min" => 0, "max" => 100000, "unit" => i, "full_salt" => "fs")), "f")
setindex!(b, randominteger(Dict("min" => 0, "max" => 100000, "unit" => i, "full_salt" => "fs")), "f")
@test getindex(a, "f") == getindex(b, "f")

distributionTester(bernoullitrial, 0.0, Dict("p" => 0.0), ((0, 1), (1, 0)))
distributionTester(bernoullitrial, 0.1, Dict("p" => 0.1), ((0, 0.9), (1, 0.1)))
distributionTester(bernoullitrial, 1.0, Dict("p" => 1.0), ((0, 0), (1, 1)))


distributionTester(uniformchoice, join(["a"], ","), Dict{AbstractString, Any}("choices" => ["a"]), [("a", 1)])
distributionTester(uniformchoice, join(["a", "b"], ","), Dict{AbstractString, Any}("choices" => ["a", "b"]), (("a", 1), ("b", 1)))
distributionTester(uniformchoice, join([1, 2, 3, 4], ","), Dict{AbstractString, Any}("choices" => [1, 2, 3, 4]), ((1, 1), (2, 1), (3, 1), (4, 1)))

choices=["a"]
weights=[1]
distributionTester(weightedchoice, join(weights, ","), Dict("choices" => choices, "weights" => weights), [("a", 1)])
choices=["a", "b"]
weights=[1, 2]
distributionTester(weightedchoice, join(weights, ","), Dict("choices" => choices, "weights" => weights), (("a", 1), ("b", 2)))
d = ((("a", 0), ("b", 2), ("c", 0)))
choices=["a", "b", "c"]
weights=[0, 2, 0]
distributionTester(weightedchoice, join(weights, ","), Dict("choices" => choices, "weights" => weights), d)

choices=["a", "b", "c", "a"]
weights = [1, 2, 0, 2]
distributionTester(weightedchoice, join(weights, ","), Dict("choices" => choices, "weights" => weights), ((("a", 3), ("b", 2), ("c", 0))))

a = Assignment("hey")
b = sample(Dict("choices"=>["a", "b", "c"], "unit"=>"2", "draws" => 2))
setindex!(a, b, "x")
@test length(getindex(a, "x")) == 2
