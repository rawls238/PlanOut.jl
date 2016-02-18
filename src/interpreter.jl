type Interpreter <: AbstractPlanOutMapper
    serialization::Dict
    inputs::Dict
    env::Assignment
    salt::AbstractString
    in_experiment::Bool
    evaluated::Bool
end

default_salt = "global_salt"
Interpreter(serialization::Dict) = Interpreter(serialization, Dict(), Assignment(default_salt), default_salt, false, false)
Interpreter(serialization::Dict, inputs::Dict) = Interpreter(serialization, inputs, Assignment(default_salt), default_salt, false, false)
Interpreter(serialization::Dict, salt::AbstractString) = Interpreter(serialization, Dict(), Assignment(salt), salt, false, false)
Interpreter(serialization::Dict, salt::AbstractString, inputs::Dict) = Interpreter(serialization, inputs, Assignment(salt), salt, false, false)

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
  elseif s == AbstractString("return")
    return AbstractString("ret")
  end
  return s
end

setindex!(i::Interpreter, value, key) = setindex!(i.env, value, key)
getindex(i::Interpreter, key) = getindex!(i.env, key)
delete!(i::Interpreter, key) = delete!(i.env, key)

function get_params(i::Interpreter)
  if !i.evaluated
    try
      evaluate(i, i.serialization)
    catch e
      if isa(e, StopPlanOutException)
        i.in_experiment = e.in_experiment
      end
    end
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
