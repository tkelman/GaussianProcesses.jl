# This file contains a list of the currently available covariance functions

import Base.show

abstract Kernel

# Returns matrix where D[i,j] = kernel(x1[i], x2[j])
#
# Arguments:
#  x1 matrix of observations (each column is an observation)
#  x2 matrix of observations (each column is an observation)
#  k kernel object
function crossKern(x1::Matrix{Float64}, x2::Matrix{Float64}, k::Kernel)
    d(x,y) = kern(k, x, y)
    return crossKern(x1, x2, d)
end

# Returns matrix of distances D where D[i,j] = kernel(x1[i], x1[j])
#
# Arguments:
#  x matrix of observations (each column is an observation)
#  k kernel object
function crossKern(x::Matrix{Float64}, k::Kernel)
    d(x,y) = kern(k, x, y)
    return crossKern(x, d)
end

# Calculates the stack [dk / dθᵢ] of kernel matrix gradients
function grad_stack!(stack::AbstractArray, x::Matrix{Float64}, k::Kernel)
    d, nobsv = size(x)
    for j in 1:nobsv, i in 1:nobsv
        @inbounds stack[i,j,:] = grad_kern(k, x[:,i], x[:,j])
    end
    return stack
end

function grad_stack(x::Matrix{Float64}, k::Kernel)
    n = num_params(k)
    d, nobsv = size(x)
    stack = Array(Float64, nobsv, nobsv, n)
    grad_stack!(stack, x, k)
    return stack
end

##############################
# Parameter name definitions #
##############################

# This generates names like [:ll_1, :ll_2, ...] for parameter vectors
get_param_names(n::Int, prefix::Symbol) = [symbol(prefix, :_, i) for i in 1:n]
get_param_names(v::Vector, prefix::Symbol) = get_param_names(length(v), prefix)

# Fallback. Yields names like :Matl2Iso_param_1 => 0.5
# Ideally this is never used, because the names are uninformative.
get_param_names(obj::Union{Kernel, Mean}) =
    get_param_names(num_params(obj),
                    symbol(typeof(obj).name.name, :_param_))

""" `composite_param_names(objects, prefix)`, where `objects` is a
vector of kernels/means, calls `get_param_names` on each object and prefixes the
name returned with `prefix` + object #. Eg.

    get_param_names(ProdKernel(Mat(1/2, 1/2, 1/2), SEArd([0.0, 1.0],0.0)))

yields

    :pk1_ll  
    :pk1_lσ  
    :pk2_ll_1
    :pk2_ll_2
    :pk2_lσ  
"""
function composite_param_names(objects, prefix)
    p = Symbol[]
    for (i, obj) in enumerate(objects)
        append!(p, [symbol(prefix, i, :_, sym) for sym in get_param_names(obj)])
    end
    p
end

function show(io::IO, k::Kernel, depth::Int = 0)
    pad = repeat(" ", 2*depth)
    print(io, "$(pad)Type: $(typeof(k)), Params: ")
    # params_dict = zip(get_param_names(k), get_params(k))
    # for (k, val) in params_dict
    #     print(io, "$(k)=$(val) ")
    # end
    show(io, get_params(k))
    print(io, "\n")
end

include("stationary.jl")

include("lin.jl")               # Linear covariance function
include("se.jl")                # Squared exponential covariance function
include("rq.jl")                # Rational quadratic covariance function
include("mat.jl")               # Matern covariance function
include("periodic.jl")          # Periodic covariance function
include("poly.jl")              # Polnomial covariance function
include("noise.jl")             # White noise covariance function

# Composite kernels
include("sum_kernel.jl")        # Sum of kernels
include("prod_kernel.jl")       # Product of kernels
