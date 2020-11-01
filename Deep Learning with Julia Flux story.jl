"""
Article : "Deep Learning with Julia, Flux.jl story" by Artur Jurgas
https://towardsdatascience.com/deep-learning-with-julia-flux-jl-story-7544c99728ca
"""
using Flux
using Flux: Data.DataLoader
using Flux: onehotbatch, onecold, crossentropy
using Flux: @epochs
using Statistics
using MLDatasets

## Data Preparation
# Load the data
x_train, y_train = MLDatasets.MNIST.traindata();
x_valid, y_valid = MLDatasets.MNIST.testdata();

""" Flux will expect our image data to be in W,H,C,N order
 (width, height, # channels, batch size) 
 so we will have to add a channel layer. 
 A function for that called unsqueeze. """

# Add the channel layer
x_train = Flux.unsqueeze(x_train, 3);
x_valid = Flux.unsqueeze(x_valid, 3);

""" One-Hot Encoding for Cross Entropy Loss """
# Encode labels (one-hot encoding) 
y_train = onehotbatch(y_train, 0:9);
y_valid = onehotbatch(y_valid, 0:9);

# Create the full dataset
train_data = DataLoader(x_train, y_train, batchsize=128);

## Model Layers
model = Chain(
    # 28x28 => 14x14
    Conv((5, 5), 1 => 8, pad=2, stride=2, relu),
    # 14x14 => 7x7
    Conv((3, 3), 8 => 16, pad=1, stride=2, relu),
    # 7x7 => 4x4
    Conv((3, 3), 16 => 32, pad=1, stride=2, relu),
    # 4x4 => 2x2
    Conv((3, 3), 32 => 32, pad=1, stride=2, relu),
    
    # Average pooling on each width x height feature map
    GlobalMeanPool(),
    # flatten layers reduce dimension to 1x1 called singletons.
    flatten,
    
    Dense(32, 10),
    softmax);

# Getting predictions (Example)
ŷ = model(x_train);
# Decoding predictions
ŷ = onecold(ŷ);
println("Prediction of first image: $(ŷ[1])")


""" Loss function, optimizer and metric """
accuracy(ŷ, y) = mean(onecold(ŷ) .== onecold(y));
# Loss Function
loss(x, y) = Flux.crossentropy(model(x), y);

# learning rate
lr = 0.1;
# Gradient Descent optimizer
opt = Descent(lr);

""" Flux’s differentiation library Zygote works is different from PyTorch. 
Flux need to get the parameters out of model by params function """
ps = Flux.params(model);

# Training the model
number_epochs = 3;
# Epoch marco for run training once at a time
# call the train! function with the loss, parameters, data, and optimizer.
@epochs number_epochs Flux.train!(loss, ps, train_data, opt)
accuracy(model(x_train), y_train)


""" #Custom training loop 

We loop over the training dataset (from DataLoader). 
Then we use the "do" keyword to map the loss calculations to the gradient function. 
    We then call the update! with the optimizer, 
    parameters and saved gradient and it is done.

"""
# loop over the training dataset (from DataLoader)
for batch in train_data
    
    gradient = Flux.gradient(ps) do
      # Remember that inside the loss() is the model
      # `...` syntax is for unpacking data
      training_loss = loss(batch...)
      return training_loss
    end
    
    Flux.update!(opt, ps, gradient)
#   this code fragment can replace Flux.update!
#   for x in ps
#       x .-= lr .* gradient[x] # Update parameters
#   end
end

"""
Let’s create some callbacks. 
They are essentially functions that will be called while training.
"""
# Flux.train!() function signatures
# train!(loss, data, opt, cb = () -> println("training"))

loss_vector = Vector{Float64}()
callback() = push!(loss_vector, loss(x_train, y_train))
Flux.train!(loss, ps, train_data, opt, cb=callback)

