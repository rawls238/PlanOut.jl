type Literal <: AbstractPlanOutOp
  args::Dict
end

literal(args::Dict) = Literal(args)
execute(op::Literal, i::Interpreter) = getArgMixed(op, "value")

type Set <: AbstractPlanOutOp
  args::Dict
end
set(args::Dict) = Set(args)

function execute(op::Set, i::Interpreter)
  var = getArgString(op, "var")
  val = getArgMixed(op, "value")

  if var == "experiment_salt"
    setsalt!(i.env, value)
  end
  setindex!(i.env, var, evaluate(i, val))
end

type Get <: AbstractPlanOutOp
  args::Dict
end
get(args::Dict) = Get(args)
execute(op::Get, i::Interpreter) = getindex(i.env, getArgString("var"))

type Seq <: AbstractPlanOutOp
  args::Dict
end
seq(args::Dict) = Seq(args)
execute(op::Seq, i::Interpreter) = evaluate(i, getArgList(op, "seq"))

type Array <: AbstractPlanOutOp
  args::Dict
end
array(args::Dict) = Array(args)
execute(op::Array, i::Interpreter) = evaluate(i, getArgList(op, "values"))

type Coalesce <: AbstractPlanOutOp
  args::Dict
end
coalesce(args::Dict) = Coalesce(args)

nullable_cond(val::Nullable) = isnull(val) ? false : get(val)
nullable_cond(val::Any) = val
function execute(op::Coalesce, i::Interpreter)
  for j in getArgList(op, "values")
    eval_x = nullable_cond(evaluate(i, j))
    if eval_x != false
      return eval_x
    end
  end
  return Nullable()
end

type Cond <: AbstractPlanOutOp
  args::Dict
end
cond(args::Dict) = Cond(args)

function execute(op::Cond, i::Interpreter)
  for i in getArgList(op, "cond")
    if_clause = getindex(i, "if")
    if evaluate(i, if_clause)
      then_clause = getindex(i, "then")
      return evaluate(i, then_clause)
    end
  end
end

type And <: AbstractPlanOutOp
  args::Dict
end
and(args::Dict) = And(args)

function execute(op::And, i::Interpreter)
  for clause in getArgList(op, "values")
    if !Bool(evaluate(i, clause))
      return false
    end
  end
  return true
end

type Or <: AbstractPlanOutOp
  args::Dict
end
or(args::Dict) = Or(args)

function execute(op::Or, i::Interpreter)
  for clause in getArgList(op, "values")
    if Bool(evaluate(i, clause))
      return true
    end
  end
  return false
end

type Map <: AbstractPlanOutOpSimple
  args::Dict
end
map(args::Dict) = Map(args)

function simpleExecute(op::Map, i::Interpreter)
  c = copy(op.args)
  delete!(c, "op")
  delete!(c, "salt")
end

type Product <: AbstractPlanOutOpCommutative
  args::Dict
end
product(args::Dict) = Product(args)

execute(op::Product, i::Interpreter, values::AbstractArray) = prod(values)

type Sum <: AbstractPlanOutOpCommutative
  args::Dict
end
sum(args::Dict) = Sum(args)

execute(op::Sum, i::Interpreter, values::AbstractArray) = sum(values)

type Min <: AbstractPlanOutOpCommutative
  args::Dict
end
min(args::Dict) = Min(args)

execute(op::Min, i::Interpreter, values::AbstractArray) = minimum(values)

type Max <: AbstractPlanOutOpCommutative
  args::Dict
end
max(args::Dict) = Max(args)

execute(op::Max, i::Interpreter, values::AbstractArray) = maximum(values)

type Equals <: AbstractPlanOutOpBinary
  args::Dict
end
equals(args::Dict) = Equals(args)

execute(op::Equals, i::Interpreter, left, right) = left == right

type GreaterThan <: AbstractPlanOutOpBinary
  args::Dict
end
greaterthan(args::Dict) = GreaterThan(args)

execute(op::GreaterThan, i::Interpreter, left, right) = left > right

type LessThan <: AbstractPlanOutOpBinary
  args::Dict
end
lessthan(args::Dict) = LessThan(args)

execute(op::LessThan, i::Interpreter, left, right) = left < right

type LessThanOrEqualTo <: AbstractPlanOutOpBinary
  args::Dict
end
lessthanorequalto(args::Dict) = LessThanOrEqualTo(args)

execute(op::LessThanOrEqualTo, i::Interpreter, left, right) = left <= right

type GreaterThanOrEqualTo <: AbstractPlanOutOpBinary
  args::Dict
end
greaterthanorequalto(args::Dict) = GreaterThanOrEqualTo(args)

execute(op::GreaterThanOrEqualTo, i::Interpreter, left, right) = left >= right

type Mod <: AbstractPlanOutOpBinary
  args::Dict
end
mod(args::Dict) = Mod(args)

execute(op::Mod, i::Interpreter, left, right) = left % right

type Divide <: AbstractPlanOutOpBinary
  args::Dict
end
div(args::Dict) = Divide(args)

execute(op::Divide, i::Interpreter, left, right) = float(left) / float(right)

type Round <: AbstractPlanOutOpUnary
  args::Dict
end
round(args::Dict) = Round(args)

execute(op::Round, i::Interpreter, value::Number) = round(value)

type Not <: AbstractPlanOutOpUnary
  args::Dict
end
not(args::Dict) = Not(args)

execute(op::Not, i::Interpreter, value) = !Bool(value)

type Negative <: AbstractPlanOutOpUnary
  args::Dict
end
negative(args::Dict) = Negative(args)

execute(op::Negative, i::Interpreter, value::Number) = 0 - value

type Length <: AbstractPlanOutOpUnary
  args::Dict
end
len(args::Dict) = Length(args)

execute(op::Length, i::Interpreter, value) = Base.length(value)
