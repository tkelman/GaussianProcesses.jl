# Polynomial covariance function 

@doc """
# Description
Constructor for the Polynomial kernel (covariance)

k(x,x') = σ²(xᵀx'+c)ᵈ
# Arguments:
* `lc::Float64`: Log of the constant c
* `lσ::Float64`: Log of the signal standard deviation σ
* `d::Int64`   : Degree of the Polynomial
""" ->
type POLY <: Kernel
    lc::Float64      # Log of constant
    lσ::Float64      # Log of signal std
    deg::Int64       # degree of polynomial
    POLY(lc::Float64, lσ::Float64, deg::Int64) = new(lc, lσ, deg)
end

function kern(poly::POLY, x::Vector{Float64}, y::Vector{Float64})
    c = exp(poly.lc)
    sigma2 = exp(2*poly.lσ)

    K = sigma2*(c+dot(x,y)).^poly.deg
    return K
end

get_params(poly::POLY) = Float64[poly.lc, poly.lσ]
num_params(poly::POLY) = 2

function set_params!(poly::POLY, hyp::Vector{Float64})
    length(hyp) == 2 || throw(ArgumentError("Polynomial function has two parameters"))
    poly.lc, poly.lσ = hyp
end

function grad_kern(poly::POLY, x::Vector{Float64}, y::Vector{Float64})
    c = exp(poly.lc)
    sigma2 = exp(2*poly.lσ)
    
    dK_c   = c*poly.deg*sigma2*(c+dot(x,y)).^(poly.deg-1)
    dK_sigma = 2.0*sigma2*(c+dot(x,y)).^poly.deg
    dK_theta = [dK_c,dK_sigma]
    return dK_theta
end
