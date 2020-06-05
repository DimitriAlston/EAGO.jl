using Revise
using JuMP, EAGO, Ipopt

m = Model(optimizer_with_attributes(EAGO.Optimizer, "verbosity" => 4,
                                                    "output_iterations" => 1,
                                                    "cp_repetitions" => -1,
                                                    "iteration_limit" => 100000,
                                                    "cut_min_iterations" => 2,
                                                    "cut_max_iterations" => 2,
                                                    "objective_cut_on" => true,
                                                    "subgrad_tighten" => true,
                                                    "obbt_depth" => 12,
                                                    "fbbt_lp_depth" => -1,
                                                    "obbt_aggressive_on" => true))

#m = Model(Ipopt.Optimizer)

# ----- Variables ----- #
x_Idx = Any[2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]
@variable(m, x[x_Idx])
JuMP.set_lower_bound(x[2], 0.0)
JuMP.set_upper_bound(x[2], 2.0)

JuMP.set_lower_bound(x[3], 0.0)
JuMP.set_upper_bound(x[3], 1.6)

JuMP.set_lower_bound(x[4], 0.0)
JuMP.set_upper_bound(x[4], 1.2)

JuMP.set_lower_bound(x[5], 0.0)
JuMP.set_upper_bound(x[5], 5.0)

JuMP.set_lower_bound(x[6], 0.0)
JuMP.set_upper_bound(x[6], 2.0)

JuMP.set_lower_bound(x[7], 0.85)
JuMP.set_upper_bound(x[7], 0.93)

JuMP.set_lower_bound(x[8], 0.9)
JuMP.set_upper_bound(x[8], 0.95)

JuMP.set_lower_bound(x[9], 3.0)
JuMP.set_upper_bound(x[9], 12.0)

JuMP.set_lower_bound(x[10], 1.2)
JuMP.set_upper_bound(x[10], 4.0)

JuMP.set_lower_bound(x[11], 1.45)
JuMP.set_upper_bound(x[11], 1.62)

JuMP.set_lower_bound(x[12], 0.99)
JuMP.set_upper_bound(x[12], 1.01010101010101)

JuMP.set_lower_bound(x[13], 0.99)
JuMP.set_upper_bound(x[13], 1.01010101010101)

JuMP.set_lower_bound(x[14], 0.9)
JuMP.set_upper_bound(x[14], 1.11111111111111)

JuMP.set_lower_bound(x[15], 0.99)
JuMP.set_upper_bound(x[15], 1.01010101010101)


# ----- Constraints ----- #
@constraint(m, e2, -0.819672131147541*x[2]+x[5]-0.819672131147541*x[6] == 0.0)

@NLconstraint(m, e3, 0.98*x[4]-x[7]*(0.01*x[5]*x[10]+x[4]) == 0.0) # first

@NLconstraint(m, e4, -x[2]*x[9] + 10*x[3] + x[6] == 0.0)

@NLconstraint(m, e7, x[10]*x[14]+22.2*x[11] == 35.82)

@NLconstraint(m, e8, x[11]*x[15]-3*x[8] == -1.33)

@NLconstraint(m, e5, x[5]*x[12]-x[2]*(1.12+0.13167*x[9]-0.0067*x[9]^2) == 0.0)

@NLconstraint(m, e6, x[8]*x[13]-0.01*(1.098*x[9]-0.038*x[9]^2)-0.325*x[7] == 0.57425)

#=
@NLconstraint(m, e3a, 0.98*x[4]-x[7]*(0.01*x[5]*x[10]+x[4]) <= 0.0)
@NLconstraint(m, e4a, -x[2]*x[9]+10*x[3]+x[6] <= 0.0)
@NLconstraint(m, e7a, x[10]*x[14]+22.2*x[11] <= 35.82)
@NLconstraint(m, e8a, x[11]*x[15]-3*x[8] <= -1.33)
@NLconstraint(m, e5a, x[5]*x[12]-x[2]*(1.12+0.13167*x[9]-0.0067*x[9]^2) <= 0.0)
@NLconstraint(m, e6a, x[8]*x[13]-0.01*(1.098*x[9]-0.038*x[9]^2)-0.325*x[7] <= 0.57425)
=#
#=
@NLconstraint(m, e3b, -(0.98*x[4]-x[7]*(0.01*x[5]*x[10]+x[4])) <= 0.0)
@NLconstraint(m, e4b, -(-x[2]*x[9]+10*x[3]+x[6]) <= 0.0)
@NLconstraint(m, e7b, -(x[10]*x[14]+22.2*x[11]) <= -35.82)
@NLconstraint(m, e8b, -(x[11]*x[15]-3*x[8]) <= 1.33)
@NLconstraint(m, e5b, -(x[5]*x[12]-x[2]*(1.12+0.13167*x[9]-0.0067*x[9]^2)) <= 0.0)
@NLconstraint(m, e6b, -(x[8]*x[13]-0.01*(1.098*x[9]-0.038*x[9]^2)-0.325*x[7]) <= -0.57425)
=#
# EQ TO LEQ/LEQ fixes issue....
# OPTION 1: CC BOUND NOT ADDED CORRECTLY...
# OPTION 2: CC BOUND INCORRECT FOR SOME TERMS...

# ALL EQ -> (0.0, 0.0) BOUNDS
# ALL LEQ -> (-Inf, 0.0) BOUNDs

# NOT A SQR VS MULT ISSUE
#@NLconstraint(m, e5, x[5]*x[12]-x[2]*(1.12+0.13167*x[9]-0.0067*x[9]*x[9]) == 0.0)
#@NLconstraint(m, e6, x[8]*x[13]-0.01*(1.098*x[9]-0.038*x[9]*x[9])-0.325*x[7] == 0.57425)

# NOT A BOUND ISSUE
#@NLconstraint(m, e6, x[8]*x[13]-0.01*(1.098*x[9]-0.038*x[9]*x[9])-0.325*x[7] - 0.57425 == 0.0)
#@NLconstraint(m, e7, x[10]*x[14]+22.2*x[11] - 35.82 == 0.0)
#@NLconstraint(m, e8, x[11]*x[15]-3*x[8] + 1.33 == 0.0)

#=
-1.7650
=#
# ----- Objective ----- #
@NLobjective(m, Min, 5.04*x[2] + 0.35*x[3] + x[4] + 3.36*x[6] - 6.3*x[5]*x[8])
#@objective(m, Min, x[2])
JuMP.optimize!(m)

println("primal status = $(primal_status(m))")
println("termination status = $(termination_status(m))")
