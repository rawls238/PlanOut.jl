module PlanOut
import Base: setindex!, getindex, start, next, done, length, copy, delete!, sum, prod, minimum, maximum,
            >=, <, <=, >, %, /, length
export
  Assignment,
  AbstractPlanOutOp,
  AbstractPlanOutOpSimple,
  AbstractPlanOutOpBinary,
  AbstractPlanOutOpUnary,
  AbstractPlanOutOpCommutative,
  literal, get, set, array, coalesce, seq, cond, and, or, equals, lessthan, greaterthan, lessthanorequalto, greaterthanorequalto, min, max, mod, div, len, round, not, negative,
  getArgMixed, getArgInt, getArgString, getArgFloat, getArgNumeric, getArgList, getArgMap, getArgIndexish,
  evaluate, Interpreter, get_params

include("assignment.jl")
include("interpreter.jl")
include("ops/base.jl")
include("ops/core.jl")
end
