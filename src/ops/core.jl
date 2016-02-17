type Literal <: AbstractPlanOutOp
  args::Dict{AbstractString, Any}
end

literal(args::Dict) = Literal(args)
execute(op::Literal, i::AbstractPlanOutMapper) = getArgMixed(op, "value")

type Set <: AbstractPlanOutOp
  args::Dict{AbstractString, Any}
end
set(args::Dict) = Set(args)

function execute(op::Set, i::AbstractPlanOutMapper)
  var = getArgString(op, "var")
  val = getArgMixed(op, "value")
  if var == "experiment_salt"
    setsalt!(i, value)
  end
  setindex!(i, evaluate(i, val), var)
end

type Get <: AbstractPlanOutOp
  args::Dict{AbstractString, Any}
end
get(args::Dict) = Get(args)
execute(op::Get, i::AbstractPlanOutMapper) = getindex(i, getArgString("var"))

type Seq <: AbstractPlanOutOp
  args::Dict{AbstractString, Any}
end
seq(args::Dict) = Seq(args)
execute(op::Seq, i::AbstractPlanOutMapper) = [evaluate(i, el) for el in getArgList(op, "seq")]

type Array <: AbstractPlanOutOp
  args::Dict{AbstractString, Any}
end
array(args::Dict) = Array(args)
execute(op::Array, i::AbstractPlanOutMapper) = [evaluate(i, el) for el in getArgList(op, "values")]

type Coalesce <: AbstractPlanOutOp
  args::Dict{AbstractString, Any}
end
coalesce(args::Dict) = Coalesce(args)

nullable_cond(val::Nullable) = isnull(val) ? false : get(val)
nullable_cond(val::Any) = val
function execute(op::Coalesce, i::AbstractPlanOutMapper)
  for j in getArgList(op, "values")
    eval_x = nullable_cond(evaluate(i, j))
    if eval_x != false
      return eval_x
    end
  end
  return Nullable()
end

type Cond <: AbstractPlanOutOp
  args::Dict{AbstractString, Any}
end
cond(args::Dict) = Cond(args)

function execute(op::Cond, i::AbstractPlanOutMapper)
  for i in getArgList(op, "cond")
    if_clause = getindex(i, "if")
    if evaluate(i, if_clause)
      then_clause = getindex(i, "then")
      return evaluate(i, then_clause)
    end
  end
end

type And <: AbstractPlanOutOp
  args::Dict{AbstractString, Any}
end
and(args::Dict) = And(args)

function execute(op::And, i::AbstractPlanOutMapper)
  for clause in getArgList(op, "values")
    if !Bool(evaluate(i, clause))
      return false
    end
  end
  return true
end

type Or <: AbstractPlanOutOp
  args::Dict{AbstractString, Any}
end
or(args::Dict) = Or(args)

function execute(op::Or, i::AbstractPlanOutMapper)
  for clause in getArgList(op, "values")
    if Bool(evaluate(i, clause))
      return true
    end
  end
  return false
end

type Map <: AbstractPlanOutOpSimple
  args::Dict{AbstractString, Any}
end
map(args::Dict) = Map(args)

function simpleExecute(op::Map, i::AbstractPlanOutMapper)
  c = copy(op.args)
  delete!(c, "op")
  delete!(c, "salt")
end

type Product <: AbstractPlanOutOpCommutative
  args::Dict{AbstractString, Any}
end
product(args::Dict) = Product(args)

execute(op::Product, i::AbstractPlanOutMapper, values::AbstractArray) = prod(values)

type Sum <: AbstractPlanOutOpCommutative
  args::Dict{AbstractString, Any}
end
sum(args::Dict) = Sum(args)

execute(op::Sum, i::AbstractPlanOutMapper, values::AbstractArray) = sum(values)

type Min <: AbstractPlanOutOpCommutative
  args::Dict{AbstractString, Any}
end
min(args::Dict) = Min(args)

execute(op::Min, i::AbstractPlanOutMapper, values::AbstractArray) = minimum(values)

type Max <: AbstractPlanOutOpCommutative
  args::Dict{AbstractString, Any}
end
max(args::Dict) = Max(args)

execute(op::Max, i::AbstractPlanOutMapper, values::AbstractArray) = maximum(values)

type Equals <: AbstractPlanOutOpBinary
  args::Dict{AbstractString, Any}
end
equals(args::Dict) = Equals(args)

execute(op::Equals, i::AbstractPlanOutMapper, left, right) = left == right

type GreaterThan <: AbstractPlanOutOpBinary
  args::Dict{AbstractString, Any}
end
greaterthan(args::Dict) = GreaterThan(args)

execute(op::GreaterThan, i::AbstractPlanOutMapper, left, right) = left > right

type LessThan <: AbstractPlanOutOpBinary
  args::Dict{AbstractString, Any}
end
lessthan(args::Dict) = LessThan(args)

execute(op::LessThan, i::AbstractPlanOutMapper, left, right) = left < right

type LessThanOrEqualTo <: AbstractPlanOutOpBinary
  args::Dict{AbstractString, Any}
end
lessthanorequalto(args::Dict) = LessThanOrEqualTo(args)

execute(op::LessThanOrEqualTo, i::AbstractPlanOutMapper, left, right) = left <= right

type GreaterThanOrEqualTo <: AbstractPlanOutOpBinary
  args::Dict{AbstractString, Any}
end
greaterthanorequalto(args::Dict) = GreaterThanOrEqualTo(args)

execute(op::GreaterThanOrEqualTo, i::AbstractPlanOutMapper, left, right) = left >= right

type Mod <: AbstractPlanOutOpBinary
  args::Dict{AbstractString, Any}
end
mod(args::Dict) = Mod(args)

execute(op::Mod, i::AbstractPlanOutMapper, left, right) = left % right

type Divide <: AbstractPlanOutOpBinary
  args::Dict{AbstractString, Any}
end
div(args::Dict) = Divide(args)

execute(op::Divide, i::AbstractPlanOutMapper, left, right) = float(left) / float(right)

type Round <: AbstractPlanOutOpUnary
  args::Dict{AbstractString, Any}
end
round(args::Dict) = Round(args)

execute(op::Round, i::AbstractPlanOutMapper, value::Number) = round(value)

type Not <: AbstractPlanOutOpUnary
  args::Dict{AbstractString, Any}
end
not(args::Dict) = Not(args)

execute(op::Not, i::AbstractPlanOutMapper, value) = !Bool(value)

type Negative <: AbstractPlanOutOpUnary
  args::Dict{AbstractString, Any}
end
negative(args::Dict) = Negative(args)

execute(op::Negative, i::AbstractPlanOutMapper, value::Number) = 0 - value

type Length <: AbstractPlanOutOpUnary
  args::Dict{AbstractString, Any}
end
len(args::Dict) = Length(args)

execute(op::Length, i::AbstractPlanOutMapper, value) = Base.length(value)

type Index <: AbstractPlanOutOpSimple
  args::Dict{AbstractString, Any}
end
index(args::Dict) = Index(args)

modifyIndex(a::Any) = a
modifyIndex(a::Number) = a + 1 # because other languages start with index = 0
function simpleExecute(op::Index, i::AbstractPlanOutMapper)
  base = getArgIndexish(op, "base")
  index = modifyIndex(getArgMixed(op, "index"))
  Base.get(base, index, Nullable())
end

type Return <: AbstractPlanOutOp
  args::Dict{AbstractString, Any}
end
ret(args::Dict) = Return(args)
function execute(op::Return, i::AbstractPlanOutMapper)
  value = evaluate(i, getArgMixed(op, "value"))
  in_experiment = value > 0
  throw(StopPlanOutException(in_experiment))
end
