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
  for i ∈ getArgList(op, "cond")
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
  for clause ∈ getArgList(op, "values")
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
  for clause ∈ getArgList(op, "values")
    if Bool(evaluate(i, clause))
      return true
    end
  end
  return false
end
