abstract AbstractPlanOutOp

assertIndexishValue(value::Associative) = value
assertIndexishValue(value::AbstractArray) = value

getArgs(op::AbstractPlanOutOp) = op.args
hasArg(op::AbstractPlanOutOp, name) = haskey(op.args, name)
getArg(op::AbstractPlanOutOp, name::AbstractString) = getindex(op.args, name)
setArg!(op::AbstractPlanOutOp, value, name::AbstractString) = setindex!(op.args, value, name)
getArgMixed(op::AbstractPlanOutOp, name::AbstractString) = getArg(op, name)
getArgInt(op::AbstractPlanOutOp, name::AbstractString) = getArgMixed(op, name)::Int
getArgString(op::AbstractPlanOutOp, name::AbstractString) = getArgMixed(op, name)::AbstractString
getArgNumeric(op::AbstractPlanOutOp, name::AbstractString) = getArgMixed(op, name)::Number
getArgList(op::AbstractPlanOutOp, name::AbstractString) = getArgMixed(op, name)::AbstractArray
getArgMap(op::AbstractPlanOutOp, name::AbstractString) = getArgMixed(op, name)::Associative
getArgIndexish(op::AbstractPlanOutOp, name::AbstractString) = assertIndexishValue(getArgMixed(op, name))

abstract AbstractPlanOutOpSimple <: AbstractPlanOutOp

function execute(op::AbstractPlanOutOpSimple, i::AbstractPlanOutMapper)
  args = getArgs(op)
  for (k, v) in args
    setArg!(op, evaluate(i, v), k)
  end
  simpleExecute(op, i)
end

abstract AbstractPlanOutOpBinary <: AbstractPlanOutOpSimple
simpleExecute(op::AbstractPlanOutOpBinary, i::AbstractPlanOutMapper) = execute(op, i, getArgMixed(op, "left"), getArgMixed(op, "right"))

abstract AbstractPlanOutOpUnary <: AbstractPlanOutOpSimple
simpleExecute(op::AbstractPlanOutOpUnary, i::AbstractPlanOutMapper) = execute(op, i, getArgMixed(op, "value"))

abstract AbstractPlanOutOpCommutative <: AbstractPlanOutOpSimple
simpleExecute(op::AbstractPlanOutOpCommutative, i::AbstractPlanOutMapper) = execute(op, i, getArgList(op, "values"))

abstract AbstractPlanOutOpRandom <: AbstractPlanOutOpSimple
simpleExecute(op::AbstractPlanOutOpRandom, i::AbstractPlanOutMapper) = randExecute(op, i)
getValue(a::Assignment, value, name) = value
function getValue(a::Assignment, value::AbstractPlanOutOpRandom, name)
  if !hasArg(value, "salt")
    setArg!(value, name, "salt")
  end
  execute(value, a)
end

type StopPlanOutException <: Exception
  in_experiment::Bool
end
