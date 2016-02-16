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
