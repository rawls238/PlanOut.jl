abstract AbstractPlanOutOp

assertIndexishValue(value::Associative) = value
assertIndexishValue(value::AbstractArray) = value

getArgMixed(op::AbstractPlanOutOp, name::AbstractString) = getindex(op.args, name)
getArgInt(op::AbstractPlanOutOp, name::AbstractString) = getArgMixed(op, name)::Int
getArgString(op::AbstractPlanOutOp, name::AbstractString) = getArgMixed(op, name)::AbstractString
getArgFloat(op::AbstractPlanOutOp, name::AbstractString) = getArgMixed(op, name)::AbstractFloat
getArgNumeric(op::AbstractPlanOutOp, name::AbstractString) = getArgMixed(op, name)::Number
getArgList(op::AbstractPlanOutOp, name::AbstractString) = getArgMixed(op, name)::AbstractArray
getArgMap(op::AbstractPlanOutOp, name::AbstractString) = getArgMixed(op, name)::Associative
getArgIndexish(op::AbstractPlanOutOp, name::AbstractString) = assertIndexishValue(getArgMixed(op, name))


abstract AbstractPlanOutSimpleOp <: AbstractPlanOutOp
abstract AbstractPlanOutBinaryOp <: AbstractPlanOutSimpleOp
abstract AbstractPlanOutUnaryOp <: AbstractPlanOutSimpleOp
abstract AbstractPlanOutCommutativeOp <: AbstractPlanOutSimpleOp
