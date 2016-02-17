function run_config(config, init=Dict())
  e = Interpreter(config, "test_salt", init)
  get_params(e)
end

function run_config_single(config)
  x_config = Dict("op" => "set", "var" => "x", "value" => config)
  getindex(run_config(x_config), "x")
end

expected_val = "x_val"
c = Dict("op" => "set", "value" => expected_val, "var" => "x")
d = run_config(c)
@test getindex(d.data, "x") == expected_val

expected_x_val = "x_val"
expected_y_val = "y_val"
c = Dict("op" => "seq", "seq" =>
      [Dict("op" => "set", "value" => expected_x_val, "var" => "x"),
       Dict("op" => "set", "value" => expected_y_val, "var" => "y")
     ])
d = run_config(c)
@test getindex(d.data, "x") == expected_x_val
@test getindex(d.data, "y") == expected_y_val

arr = [4, 5, "a"]
d = run_config_single(Dict("op" => "array", "values" => arr))
@test d == arr

x = run_config_single(Dict("op" => "coalesce", "values" => [Nullable()]))
@test isequal(x, Nullable())

x = run_config_single(Dict("op" => "coalesce", "values" => [Nullable(), 42, Nullable()]))
@test x == 42

x = run_config_single(Dict("op" => "or", "values" => [0, 0, 0]))
@test x == false

x = run_config_single(Dict("op" => "or", "values" => [0, 0, 1]))
@test x == true

x = run_config_single(Dict("op" => "and", "values" => [1, 1, 0]))
@test x == false

x = run_config_single(Dict("op" => "and", "values" => [1, 1, 1]))
@test x == true

map_val = Dict("a" => 2, "b" => "c", "d" => false)
map_op = run_config_single(Dict("op" => "map", "a" => 2, "b" => "c", "d" => false))
@test map_op == map_val

empty_map = Dict()
map_op2 = run_config_single(Dict("op" => "map"))
@test empty_map == map_op2

arr = [33, 7, 18, 21, -3]

sum_test = run_config_single(Dict("op" => "sum", "values" => arr))
@test sum_test == 76

product_test = run_config_single(Dict("op" => "product", "values" => arr))
@test product_test == -261954

min_test = run_config_single(Dict("op" => "min", "values" => arr))
@test min_test == -3

max_test = run_config_single(Dict("op" => "max", "values" => arr))
@test max_test == 33

core_dict = Dict("op" => "equals", "left" => 1, "right" => 2)
eq = run_config_single(core_dict)
@test eq == false

eq = run_config_single(Dict("op" => "equals", "left" => 2, "right" => 2))
@test eq == true

core_dict["op"] = ">"
gt = run_config_single(core_dict)
@test gt == false

core_dict["op"] = ">="
gte = run_config_single(core_dict)
@test gte == false

core_dict["op"] = "<"
lt = run_config_single(core_dict)
@test lt == true

core_dict["op"] = "<="
lte = run_config_single(core_dict)
@test lte == true

mod = run_config_single(Dict("op" => "%", "left" => 11, "right" => 3))
@test mod == (11 % 3)

div = run_config_single(Dict("op" => "/", "left" => 3, "right" => 4))
@test div == 0.75

round = run_config_single(Dict("op" => "round"))
