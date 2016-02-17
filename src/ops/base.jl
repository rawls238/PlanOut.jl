abstract AbstractPlanOutOp

assertIndexishValue(value::Associative) = value
assertIndexishValue(value::AbstractArray) = value

getArgs(op::AbstractPlanOutOp) = op.args
getArg(op::AbstractPlanOutOp, name::AbstractString) = getindex(op.args, name)
setArg!(op::AbstractPlanOutOp, name::AbstractString, value) = setindex!(op.args, value, name)
getArgMixed(op::AbstractPlanOutOp, name::AbstractString) = getArg(op, name)
getArgInt(op::AbstractPlanOutOp, name::AbstractString) = getArgMixed(op, name)::Int
getArgString(op::AbstractPlanOutOp, name::AbstractString) = getArgMixed(op, name)::AbstractString
getArgFloat(op::AbstractPlanOutOp, name::AbstractString) = getArgMixed(op, name)::AbstractFloat
getArgNumeric(op::AbstractPlanOutOp, name::AbstractString) = getArgMixed(op, name)::Number
getArgList(op::AbstractPlanOutOp, name::AbstractString) = getArgMixed(op, name)::AbstractArray
getArgMap(op::AbstractPlanOutOp, name::AbstractString) = getArgMixed(op, name)::Associative
getArgIndexish(op::AbstractPlanOutOp, name::AbstractString) = assertIndexishValue(getArgMixed(op, name))

abstract AbstractPlanOutOpSimple <: AbstractPlanOutOp

function execute(op::AbstractPlanOutOpSimple, i::Interpreter)
  args = getArgs(op)
  for (k, v) in args
    setArg!(op, k, evaluate(i, v))
  end
  simpleExecute(op, i)
end

abstract AbstractPlanOutOpBinary <: AbstractPlanOutOpSimple
simpleExecute(op::AbstractPlanOutOpBinary, i::Interpreter) = execute(op, i, getArgMixed(op, "left"), getArgMixed(op, "right"))

abstract AbstractPlanOutOpUnary <: AbstractPlanOutOpSimple
simpleExecute(op::AbstractPlanOutOpUnary, i::Interpreter) = execute(op, i, getArgMixed(op, "value"))

abstract AbstractPlanOutOpCommutative <: AbstractPlanOutOpSimple
simpleExecute(op::AbstractPlanOutOpCommutative, i::Interpreter) = execute(op, i, getArgList(op, "values"))

type StopPlanOutException <: Exception
  in_experiment::Bool
end
