module PlanOut
import Nettle: hexdigest
import Base: setindex!, getindex, start, next, done, length, copy, delete!, sum, prod, minimum, maximum,
            >=, <, <=, >, %, /, length, round, get, throw
export
  Assignment,
  AbstractPlanOutOp,
  AbstractPlanOutOpSimple,
  AbstractPlanOutOpBinary,
  AbstractPlanOutOpUnary,
  AbstractPlanOutOpCommutative,
  AbstractPlanOutOpRandom,
  literal, index, get, set, array, coalesce, seq, cond, and, or, equals, lessthan, greaterthan, lessthanorequalto, greaterthanorequalto, min, max, mod, div, len, round, not, negative,
  randominteger, randomfloat, bernoullitrial, bernoullifilter, uniformchoice, weightedchoice, sample,
  getArgMixed, getArgInt, getArgString, getArgNumeric, getArgList, getArgMap, getArgIndexish,
  evaluate, Interpreter, get_params

include("assignment.jl")
include("interpreter.jl")
include("ops/base.jl")
include("ops/core.jl")
include("ops/random.jl")
end
