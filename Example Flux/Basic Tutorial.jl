### Flux Tutorial : Basic ###
# v0.11.14
##
using Markdown
using InteractiveUtils
using Flux
##
##
""" Taking Gradients
Flux's core feature is taking gradients of Julia code. 
The gradient function takes another Julia function f and a set of arguments, 
	and returns the gradient with respect to each argument. 
	(It's a good idea to try pasting these examples in the Julia terminal.) 
"""
f(x) = 3x^2 + 2x + 1;
df(x) = gradient(f, x)[1]; # df/dx = 6x + 2
# test for df
df(2)
d2f(x) = gradient(df, x)[1]; # d²f/dx² = 6
d2f(2)
##
""" When a function has many parameters, 
we can get gradients of each one at the same time:"""
f(x, y) = sum((x .- y).^2);
gradient(f, [2, 1], [2, 0])
##
"""But machine learning models can have hundreds of parameters! 
To handle this, Flux lets you work with collections of parameters, via params. 
You can get the gradient of all parameters used in a program without 
explicitly passing them in."""
x = [2, 1];
y = [2, 0];

gs = gradient(params(x, y)) do
	f(x, y)
  end

gs[x]
gs[y]
""" Here, gradient takes a zero-argument function; 
no arguments are necessary because the params tell it what to differentiate.

This will come in really handy when dealing with big, complicated models. 
For now, though, let's start with something simple. """

#---------------------------------------------------------------------------------------

""" Simple Models
Consider a simple linear regression, 
which tries to predict an output array y from an input x"""

W = rand(2, 5)
b = rand(2)

predict(x) = W*x .+ b

function loss(x, y)
  ŷ = predict(x)
  sum((y .- ŷ).^2)
end

x, y = rand(5), rand(2) # Dummy data
loss(x, y)

""" To improve the prediction we can take the gradients of
 W and b with respect to the loss and perform gradient descent."""

gs = gradient(() -> loss(x, y), params(W, b))

""" Now that we have gradients, 
we can pull them out and update W to train the model. """

W̄ = gs[W]
W .-= 0.1 .* W̄
loss(x, y)

""" The loss has decreased a little, 
meaning that our prediction x is closer to the target y. 
If we have some data we can already try training the model.

""" 
# ------------------------------------------------------------------------------------
"""
All deep learning in Flux, 
however complex, is a simple generalisation of this example. 
Of course, models can look very different – 
they might have millions of parameters or complex control flow. 
Let's see how Flux handles more complex models. """

""" Building Layers
It's common to create more complex models than the linear regression above. 
For example, we might want to have two linear layers with a nonlinearity 
like sigmoid (σ) in between them. In the above style we could write this as: """

using Flux

W1 = rand(3, 5)
b1 = rand(3)
layer1(x) = W1 * x .+ b1

W2 = rand(2, 3)
b2 = rand(2)
layer2(x) = W2 * x .+ b2

model(x) = layer2(σ.(layer1(x))) # Stack Layer

model(rand(5)) # => 2-element vector

""" This works but is fairly unwieldy, 
with a lot of repetition – especially as we add more layers. 
One way to factor this out is to create a function that returns linear layers. """

using Random
	function linear(in, out)
		W = randn(out, in)
		b = randn(out)
		x -> W * x .+ b
		end
	  
linear1 = linear(5, 3) # we can access linear1.W etc
linear2 = linear(3, 2)
	  
model(x) = linear2(σ.(linear1(x)))
model(rand(5)) # => 2-element vector

""" Another (equivalent) way is to create a struct that 
explicitly represents the affine layer. """

struct Affine
	W
	b
  end
  
Affine(in::Integer, out::Integer) = Affine(randn(out, in), randn(out))
  
# Overload call, so the object can be used as a function
(m::Affine)(x) = m.W * x .+ m.b
  
a = Affine(10, 5)
a(rand(10)) # => 5-element vector

# (There is one small difference with Dense – for convenience 
# it also takes an activation function, like Dense(10, 5, σ).)

# -----------------------------------------------------------------------------

"""Stacking It Up
It's pretty common to write models that look something like: """

layer1 = Dense(10, 5, σ)
layer2 = Dense(10, 5, σ)
layer3 = Dense(10, 5, σ)
# ...
model(x) = layer3(layer2(layer1(x)))

""" For long chains, 
it might be a bit more intuitive to have a list of layers, like this: """

layers = [Dense(10, 5, σ), Dense(5, 2), softmax]
model(x) = foldl((x, m) -> m(x), layers, init = x)
model(rand(10)) # => 2-element vector

""" Handily, this is also provided for in Flux: """
model2 = Chain(
  Dense(10, 5, σ),
  Dense(5, 2),
  softmax)

model2(rand(10)) # => 2-element vector

""" This quickly starts to look like a high-level deep learning library; 
yet you can see how it falls out of simple abstractions, 
and we lose none of the power of Julia code.

A nice property of this approach is that because "models" are just functions 
(possibly with trainable parameters), 
you can also see this as simple function composition. """

m = Dense(5, 2) ∘ Dense(10, 5, σ)
m(rand(10))

""" Likewise, Chain will happily work with any Julia function."""
m = Chain(x -> x^2, x -> x+1)

""" outdims() enables you to calculate the spatial output dimensions of layers 
like Conv when applied to input images of a given size. """

m = Chain(Conv((3, 3), 3 => 16), Conv((3, 3), 16 => 32))
Flux.outdims(m, (10, 10)) == (6, 6)
