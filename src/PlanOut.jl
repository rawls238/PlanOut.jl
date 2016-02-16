module PlanOut
import Base: setindex!, getindex, start, next, done, length, copy, delete!

export
  Assignment,
  AbstractPlanOutOp,
  AbstractPlanOutSimpleOp,
  AbstractPlanOutBinaryOp,
  AbstractPlanOutUnaryOp,
  literal, get, set, array, coalesce,
  getArgMixed, getArgInt, getArgString, getArgFloat, getArgNumeric, getArgList, getArgMap, getArgIndexish,
  evaluate, Interpreter, get_params

include("assignment.jl")
include("interpreter.jl")
include("ops/base.jl")
include("ops/core.jl")
end
