# Copyright (c) 2018: Matthew Wilhelm & Matthew Stuber.
# This code is licensed under MIT license (see LICENSE.md for full details)
#############################################################################
# Disciplined.jl
# DAG Representation & Utilities for Optimization
# See https://github.com/PSORLab/EAGO.jl
#############################################################################
# src/functions/nonlinear/g/c.jl
# Defines the AbstractCache and AbstractCacheAttribute types along with
# fallback functions for undefined.
#############################################################################

"""
    AbstractCache

Abstract supertype used for information storage object the directed acyclic graph.
"""
abstract type AbstractCache end

"""
    AbstractCacheAttribute

Abstract supertype used for attributes stored in a cache.
"""
abstract type AbstractCacheAttribute end

"""
    initialize!

Initializes the cache `c` to correspond to directed graph `g`.
"""
function initialize!(c::AbstractCache, g::AbstractDG)
    error("No function initialize!(g,c) defined for g = $(typeof(g)) and c = $(typeof(c)).")
end

"""
    fprop!

Performs a forward walk on the `g::DirectedAcyclicGraph` to calculate the
attribute `t::AbstractCacheAttribute` stored in `c::AbstractCache`. An
optional fourth parameter `i::Int` indicates the node in the graph to evaluate
(evaluating all dependent nodes as necessary).
"""
function fprop!(t::AbstractCacheAttribute, g::AbstractDG, c::AbstractCache)
    error("No function fprop!(t, g, c) defined for t = $(typeof(t)), g = $(typeof(g)) and c = $(typeof(c)).")
end
function fprop!(t::AbstractCacheAttribute, g::AbstractDG, c::AbstractCache, i::Int)
    error("No function fprop!(t, g, c, i) defined for t = $(typeof(t)), g = $(typeof(g)) and c = $(typeof(c)).")
end

"""
    rprop!

Performs a reverse walk on the `g::DirectedAcyclicGraph` to calculate the
attribute `t::AbstractCacheAttribute` stored in `c::AbstractCache`. An
optional fourth parameter `i::Int` indicates the node in the graph to begin the
`reverse` evaluation from.
"""
function rprop!(t::AbstractCacheAttribute, g::AbstractDG, c::AbstractCache)
    error("No function rprop!(t, g, b) defined for t::AbstractCacheAttribute
           = $(typeof(t)), g::AbstractDG = $(typeof(g)) and c::AbstractCache = $(typeof(c)).")
end
function rprop!(t::AbstractCacheAttribute, g::AbstractDG, c::AbstractCache, i::Int)
    error("No function rprop!(t, g, b) defined for t::AbstractCacheAttribute
           = $(typeof(t)), g::AbstractDG = $(typeof(g)) and c::AbstractCache = $(typeof(c)).")
end

"""
    _is_discovered(c, i)

Check if a node was discovered by search.
"""
function _is_undiscovered(t::AbstractCacheAttribute, c::AbstractCache, i::Int)
    error("No function _is_discovered(t, c, i) defined for t::AbstractCacheAttribute = $t and c::AbstractCache = $c.")
end

"""
    _is_locked(t::AbstractCacheAttribute, c::AbstractCache, i::Int)

Defines whether the attribute associated with each node is locked.
A lock node has been discovered.  A discovered not has not necessarily been locked.
"""
function _is_unlocked(t::AbstractCacheAttribute, c::AbstractCache, i::Int)
    error("No function _is_locked(t, c, i) defined for t = $t and c = $c.")
end

"""
    discover!

Specifies that a node has been discovered by a search.
"""
function discover!(t::AbstractCacheAttribute, c::AbstractCache, i::Int)
    error("No function discovered!(t, c, i) defined for t = $t and c = $c.")
end

Base.@kwdef mutable struct VariableValues{T<:Real}
    x::Vector{T}                           = T[]
    lower_variable_bounds::Vector{T}       = T[]
    upper_variable_bounds::Vector{T}       = T[]
    node_to_variable_map::Vector{Int}      = Int[]
    variable_to_node_map::Vector{Int}      = Int[]
    variable_types::Vector{VariableType}   = VariableType[]
end

@inline _val(b::VariableValues{T}, i::Int) where T = @inbounds b.x[i]
@inline _lbd(b::VariableValues{T}, i::Int) where T = @inbounds b.lower_variable_bounds[i]
@inline _ubd(b::VariableValues{T}, i::Int) where T = @inbounds b.upper_variable_bounds[i]
function _get_x!(::Type{BranchVar}, out::Vector{T}, v::VariableValues{T}) where T<:Real
    @inbounds for i = 1:length(v.node_to_variable_map)
        out[i] = v.x[v.node_to_variable_map[i]]
    end
    return nothing
end

forward_uni = [i for i in instances(AtomType)]
setdiff!(forward_uni, [VAR_ATOM; PARAM_ATOM; CONST_ATOM; SELECT_ATOM; SUBEXPR])
f_switch = binary_switch(forward_uni, is_forward = true)
@eval function fprop!(t::T, ex::Expression, g::AbstractDG, c::AbstractCache , k::Int) where T<:AbstractCacheAttribute
    id = _ex_type(g, k)
    $f_switch
    error("fprop! for ex_type = $id not defined.")
    return
end

reverse_uni = [i for i in instances(AtomType)]
setdiff!(reverse_uni, [VAR_ATOM; PARAM_ATOM; CONST_ATOM; SELECT_ATOM; SUBEXPR])
r_switch = binary_switch(reverse_uni, is_forward = false)
@eval function rprop!(t::T, ex::Expression, g::AbstractDG, c::AbstractCache, k::Int) where T<:AbstractCacheAttribute
    id = _ex_type(g, k)
    $r_switch
    error("rprop! for ex_type = $id not defined.")
    return
end
