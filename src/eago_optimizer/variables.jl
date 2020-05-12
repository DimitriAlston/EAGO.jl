# Copyright (c) 2018: Matthew Wilhelm & Matthew Stuber.
# This work is licensed under the Creative Commons Attribution-NonCommercial-
# ShareAlike 4.0 International License. To view a copy of this license, visit
# http://creativecommons.org/licenses/by-nc-sa/4.0/ or send a letter to Creative
# Commons, PO Box 1866, Mountain View, CA 94042, USA.
#############################################################################
# EAGO
# A development environment for robust and global optimization
# See https://github.com/PSORLab/EAGO.jl
#############################################################################
# src/eago_optimizer/variables.jl
# Defines single variable constraints supported by optimizer and how to store.
#############################################################################

##### Add unconstrained variables
function MOI.add_variable(m::Optimizer)
    m._variable_number += 1
    if ~m._user_branch_variables
        push!(m.branch_variable, false)
    end
    push!(m.obbt_variable_values, false)
    push!(m._obbt_working_lower_index, false)
    push!(m._obbt_working_upper_index, false)
    push!(m._lower_indx_diff, false)
    push!(m._upper_indx_diff, false)
    push!(m._old_low_index, false)
    push!(m._old_upp_index, false)
    push!(m._new_low_index, false)
    push!(m._new_upp_index, false)
    push!(m._fixed_variable, false)
    push!(m._variable_info, VariableInfo())
    return VI(m._variable_number)
end
MOI.add_variables(m::Optimizer, n::Int) = [MOI.add_variable(m) for i in 1:n]

##### Supports function and add_constraint for single variable functions
const INEQ_SETS = Union{LT, GT, ET}
MOI.supports_constraint(::Optimizer, ::Type{SV}, ::Type{S}) where {S <: INEQ_SETS} = true

function MOI.add_constraint(m::Optimizer, v::SV, zo::ZO)
    vi = v.variable
    check_inbounds!(m, vi)
    has_upper_bound(m, vi) && error("Upper bound on variable $vi already exists.")
    has_lower_bound(m, vi) && error("Lower bound on variable $vi already exists.")
    is_fixed(m, vi) && error("Variable $vi is fixed. Cannot also set upper bound.")
    m._variable_info[vi.value].lower_bound = 0.0
    m._variable_info[vi.value].upper_bound = 1.0
    m._variable_info[vi.value].has_lower_bound = true
    m._variable_info[vi.value].has_upper_bound = true
    m._variable_info[vi.value].is_integer = true
    return CI{SV, MOI.ZO}(vi.value)
end

function MOI.add_constraint(m::Optimizer, v::SV, lt::LT)
    vi = v.variable
    check_inbounds!(m, vi)
    if isnan(lt.upper)
        error("Invalid upper bound value $(lt.upper).")
    end
    if has_upper_bound(m, vi)
        error("Upper bound on variable $vi already exists.")
    end
    if is_fixed(m, vi)
        error("Variable $vi is fixed. Cannot also set upper bound.")
    end
    m._variable_info[vi.value].upper_bound = lt.upper
    m._variable_info[vi.value].has_upper_bound = true
    return CI{SV, LT}(vi.value)
end

function MOI.add_constraint(m::Optimizer, v::SV, gt::GT)
    vi = v.variable
    check_inbounds!(m, vi)
    if isnan(gt.lower)
        error("Invalid lower bound value $(gt.lower).")
    end
    if has_lower_bound(m, vi)
        error("Lower bound on variable $vi already exists.")
    end
    if is_fixed(m, vi)
        error("Variable $vi is fixed. Cannot also set lower bound.")
    end
    m._variable_info[vi.value].lower_bound = gt.lower
    m._variable_info[vi.value].has_lower_bound = true
    return CI{SV, GT}(vi.value)
end

function MOI.add_constraint(m::Optimizer, v::SV, eq::ET)
    vi = v.variable
    check_inbounds!(m, vi)
    if isnan(eq.value)
        error("Invalid fixed value $(gt.lower).")
    end
    if has_lower_bound(m, vi)
        error("Variable $vi has a lower bound. Cannot be fixed.")
    end
    if has_upper_bound(m, vi)
        error("Variable $vi has an upper bound. Cannot be fixed.")
    end
    if is_fixed(m, vi)
        error("Variable $vi is already fixed.")
    end
    m._variable_info[vi.value].lower_bound = eq.value
    m._variable_info[vi.value].upper_bound = eq.value
    m._variable_info[vi.value].has_lower_bound = true
    m._variable_info[vi.value].has_upper_bound = true
    m._variable_info[vi.value].is_fixed = true
    return CI{SV, ET}(vi.value)
end