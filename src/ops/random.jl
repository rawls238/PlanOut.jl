LONG_SCALE = float(0xFFFFFFFFFFFFFFF)

maybeAppendUnit(unit::Any, appended_unit) = maybeAppendUnit([unit], appended_unit)
function maybeAppendUnit(unit::AbstractArray, appended_unit)
  if length(appended_unit) > 0
    push!(unit, string(appended_unit))
  end
  return unit
end

function getUnit(op::AbstractPlanOutOpRandom, appended_unit="")
  unit = getArgMixed(op, "unit")
  maybeAppendUnit(unit, appended_unit)
end

function getHash(op::AbstractPlanOutOpRandom, i::AbstractPlanOutMapper, appended_unit="")
  if hasArg(op, "full_salt")
    full_salt = getArg(op, "full_salt")
  else
    salt = getArgString(op, "salt")
    experiment_salt = i.salt
    full_salt = "$experiment_salt.$salt"
  end
  unit_str = join(getUnit(op, appended_unit), ".")
  hash_str = "$full_salt.$unit_str"::ASCIIString
  hex = hexdigest("sha1", hash_str)[1:15]
  parse(Int, "0x$hex")
end

function getUniform(op::AbstractPlanOutOpRandom, i::AbstractPlanOutMapper, min_val=0.0, max_val=1.0, appended_unit="")
  zero_to_one = getHash(op, i, appended_unit) / LONG_SCALE
  min_val + (max_val - min_val) * zero_to_one
end

type RandomFloat <: AbstractPlanOutOpRandom
  args::Dict{AbstractString, Any}
end
randomfloat(args::Dict) = RandomFloat(args)

randExecute(op::RandomFloat, i::AbstractPlanOutMapper) = getUniform(op, i, getArgNumeric(op, "min"), getArgNumeric(op, "max"))

type RandomInteger <: AbstractPlanOutOpRandom
  args::Dict{AbstractString, Any}
end
randominteger(args::Dict) = RandomInteger(args)

function randExecute(op::RandomInteger, i::AbstractPlanOutMapper)
  min_val = getArgInt(op, "min")
  max_val = getArgInt(op, "max")

  min_val + getHash(op, i) % (max_val - min_val + 1)
end

type BernoulliTrial <: AbstractPlanOutOpRandom
  args::Dict{AbstractString, Any}
end
bernoullitrial(args::Dict) = BernoulliTrial(args)

function randExecute(op::BernoulliTrial, i::AbstractPlanOutMapper)
  p = getArgNumeric(op, "p")
  rand_val = getUniform(op, i, 0.0, 1.0)
  return Int(rand_val <= p)
end

type BernoulliFilter <: AbstractPlanOutOpRandom
  args::Dict{AbstractString, Any}
end
bernoullifilter(args::Dict) = BernoulliFilter(args)

function randExecute(op::BernoulliFilter, i::AbstractPlanOutMapper)
  p = getArgNumeric(op, "p")
  choices = getArgList(op, "choices")
  ret = []
  for i in choices
    if getUniform(op, i, 0.0, 1.0) <= p
      push!(ret, i)
    end
  end
  return ret
end

type UniformChoice <: AbstractPlanOutOpRandom
  args::Dict{AbstractString, Any}
end
uniformchoice(args::Dict) = UniformChoice(args)

function randExecute(op::UniformChoice, i::AbstractPlanOutMapper)
  choices = getArgList(op, "choices")
  if length(choices) == 0
    return []
  end
  rand_index = (getHash(op, i) % length(choices)) + 1
  return getindex(choices, rand_index)
end

type WeightedChoice <: AbstractPlanOutOpRandom
  args::Dict{AbstractString, Any}
end
weightedchoice(args::Dict) = WeightedChoice(args)

function randExecute(op::WeightedChoice, m::AbstractPlanOutMapper)
  choices = getArgList(op, "choices")
  weights = getArgList(op, "weights")
  if length(choices) == 0
    return []
  end

  cum_weights = Dict(enumerate(weights))
  cum_sum = 0.0
  for (i, j) in cum_weights
    cum_sum += j
    cum_weights[i] = cum_sum
  end
  stop_val = getUniform(op, m, 0.0, cum_sum)
  for (i, j) in cum_weights
    if stop_val <= j
      return choices[i]
    end
  end
end

type Sample <: AbstractPlanOutOpRandom
  args::Dict{AbstractString, Any}
end
sample(args::Dict) = Sample(args)

function randExecute(op::Sample, m::AbstractPlanOutMapper)
  choices = copy(getArgList(op, "choices"))
  if hasArg(op, "draws")
    num_draws = getArgInt(op, "draws")
  else
    num_draws = length(choices)
  end
  for i in reverse(1:length(choices))
    j = (getHash(op, m, i) % (i + 1)) + 1
    tmp = copy(choices[i])
    choices[i] = choices[j]
    choices[j] = tmp
  end
  choices[1:num_draws]
end
