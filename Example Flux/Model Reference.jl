using Flux
#

"""Basic Layers
These core layers form the foundation of almost all neural networks."""

""" Flux.Chain 
Chain multiple layers / functions together, 
so that they are called in sequence on a given input. """
# Signature : Chain(layers...)
m = Chain(x -> x^2, x -> x+1);
m(5) == 26

m = Chain(Dense(10, 5), Dense(5, 2))
x = rand(10)
m(x) == m[2](m[1](x))

""" Flux.Dense 
Create a traditional Dense layer with parameters W and b. (Weight and bias)"""
# Signature : Dense(in::Integer, out::Integer, σ = identity)

d = Dense(5, 2)
d(rand(5))

##

""" Convoltutional Layers : Flux.Conv 

Apply a Conv layer to a 1-channel input using a 2×2 window filter size, 
giving us a 16-channel output. Output is activated with ReLU. """
# signature : Conv(filter, in => out, σ = identity; init = glorot_uniform,
#                   stride = 1, pad = 0, dilation = 1)

#   Data stored in WHCN order (width, height, # channels, batch size). 
#   Use pad=SamePad() to apply padding so that outputsize == inputsize / stride

filter = (2,2)
inSize = 1 # 1 channel input
outSize = 16 # 16 channel output

Conv(filter, inSize => outSize, relu)
##

""" Max Pooling : Flux.MaxPool (Type)
""" 
# Signature : MaxPool(k; pad = 0, stride = k)
# Max pooling layer. k is the size of the window for each dimension of the input.
# Use pad=SamePad() to apply padding so that outputsize == inputsize / stride.

""" Transpose Convoltution : Flux.ConvTranspose (Type)
"""
#= Signature 

ConvTranspose(filter, in=>out)
ConvTranspose(filter, in=>out, activation)
ConvTranspose(filter, in => out, σ = identity; init = glorot_uniform,
              stride = 1, pad = 0, dilation = 1) 
              
=#

# Use pad=SamePad() padding so that outputsize == stride * inputsize - stride + 1.


""" Regularization and Normalization """

""" Flux.normalize (function)
"""
# Signature : normalise(x; dims, ϵ=1e-5)
# Normalise x to mean 0 and standard deviation 1 across the dimensions given by dims. 
# ϵ is a small additive factor added to the denominator for numerical stability.

""" Flux.BatchNorm - (Type) : Batch Normalization 

BatchNorm computes the mean and variance for each each W×H×1×N slice
     and shifts them to have a new mean and variance"""
# Signature 
#= 
BatchNorm(channels::Integer, σ = identity;
          initβ = zeros, initγ = ones,
          ϵ = 1e-8, momentum = .1) 
=#

m = Chain(
  Dense(28^2, 64),
  BatchNorm(64, relu),
  Dense(64, 10),
  BatchNorm(10),
  softmax)
