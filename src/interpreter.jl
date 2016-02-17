type Interpreter
    serialization
    inputs::Dict
    env::Assignment
    salt::AbstractString
    in_experiment::Bool
    evaluated::Bool
end

default_salt = "global_salt"
Interpreter(serialization) = Interpreter(serialization, Dict(), Assignment(default_salt), default_salt, false, false)
Interpreter(serialization, inputs::Dict) = Interpreter(serialization, inputs, Assignment(default_salt), default_salt, false, false)
Interpreter(serialization, salt::AbstractString) = Interpreter(serialization, Dict(), Assignment(salt), salt, false, false)
Interpreter(serialization, salt::AbstractString, inputs::Dict) = Interpreter(serialization, inputs, Assignment(salt), salt, false, false)

function str_to_op(s::AbstractString)
  if s == AbstractString("<")
    return AbstractString("lessthan")
  elseif s == AbstractString(">")
    return AbstractString("greaterthan")
  elseif s == AbstractString(">=")
    return AbstractString("greaterthanorequalto")
  elseif s == AbstractString("<=")
    return AbstractString("lessthanorequalto")
  elseif s == AbstractString("%")
    return AbstractString("mod")
  elseif s == AbstractString("/")
    return AbstractString("div")
  elseif s == AbstractString("length")
    return AbstractString("len")
  end
  return s
end

function get_params(i::Interpreter)
  if !i.evaluated
    evaluate(i, i.serialization)
    i.evaluated = true
  end
  return i.env
end

function evaluate(i::Interpreter, planout_code::Any)
  return planout_code
end

function evaluate(i::Interpreter, planout_code::AbstractArray)
  return [evaluate(i, j) for j in planout_code]
end

function evaluate(i::Interpreter, planout_code::Associative)
  if haskey(planout_code, "op")
    op = str_to_op(getindex(planout_code, "op"))
    fxn_call = "PlanOut.$op($planout_code)"
    return execute(eval(parse(fxn_call)), i)
  else
    return planout_code
  end
end
