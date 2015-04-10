# Squared Exponential Function with istropic distance

@doc """
# Description
Constructor for the isotropic Squared Exponential kernel (covariance)

k(x,x') = σ²exp(-(x-x')ᵀ(x-x')/2l²)
# Arguments:
* `ll::Float64`: Log of the length scale l
* `lσ::Float64`: Log of the signal standard deviation σ
""" ->
type SE <: Kernel
    ll::Float64      # Log of Length scale
    lσ::Float64      # Log of Signal std
    SE(ll::Float64=0.0, lσ::Float64=0.0) = new(ll,lσ)
end

function kern(se::SE, x::Vector{Float64}, y::Vector{Float64})
    ell = exp(se.ll)
    sigma2 = exp(2*se.lσ)
    K = sigma2*exp(-0.5*norm(x-y)^2/ell^2)
    return K
end

get_params(se::SE) = Float64[se.ll, se.lσ]
num_params(se::SE) = 2

function set_params!(se::SE, hyp::Vector{Float64})
    length(hyp) == 2 || throw(ArgumentError("Squared exponential only has two parameters"))
    se.ll, se.lσ = hyp
end

function grad_kern(se::SE, x::Vector{Float64}, y::Vector{Float64})
    ell = exp(se.ll)
    sigma2 = exp(2*se.lσ)
    
    dK_ell = sigma2*norm(x-y)^2/ell^2*exp(-0.5*norm(x-y)^2/ell^2)
    dK_sigma = 2.0*sigma2*exp(-0.5*norm(x-y)^2/ell^2)
    
    dK_theta = [dK_ell,dK_sigma]
    return dK_theta
end
