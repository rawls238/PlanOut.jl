
## todo: have this extend the Associative type...have no patience to deal with the types currently

type Assignment
    salt::AbstractString
    overrides::Dict
    data::Dict
end

Assignment(salt::AbstractString) = Assignment(salt, Dict{AbstractString, Any}())
Assignment(salt::AbstractString, overrides::Dict) = Assignment(salt, copy(overrides), copy(overrides))

function setindex!(a::Assignment, name, value)
    setindex!(a.data, value, name)
end

function setsalt!(a::Assignment, val)
    a.salt = val
end

function getindex(a::Assignment, name)
    getindex(a.data, name)
end

function delete!(a::Assignment, name)
    delete!(a.data, name)
end

evaluate(a::Assignment, value) = value
start(a::Assignment) = start(a.data)
next(a::Assignment, i) = next(a.data, i)
done(a::Assignment, i) = done(a.data, i)

length(a::Assignment) = length(a.data)
