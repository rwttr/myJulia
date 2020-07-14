img = rand(4,4)

# generate an image that starts black in the upper left
# and gets bright in the lower right
img = Array(reshape(range(0,stop=1,length=10^4), 100, 100))
# make a copy
img_c = img[51:70, 21:70] # red
# make a view
img_v = @view img[16:35, 41:90] # blue


using Images

Gray(0.0) # black
Gray(1.0) # white
RGB(1.0, 0.0, 0.0) # red
RGB(0.0, 1.0, 0.0) # green
RGB(0.0, 0.0, 1.0) # blue

img_gray = rand(Gray, 2, 2)
img_rgb = rand(RGB, 2, 2)
img_lab = rand(Lab, 2, 2)

#display image with size val, and type
display("text/plain",img_gray)

# Color Conversion
RGB.(img_gray)
Gray.(img_rgb)

# Convert Array Formatting
# ---------------------------------------------------------
# view image in channel x  height x width
img_CHW = channelview(img_rgb)

# view image in height x width x depth
img_HWC = permutedims(img_CHW, (2, 3, 1))

# Overuse -- lose colorant information 
img_CHW = permutedims(img_HWC, (3, 1, 2))
img_rgb = colorview(RGB, img_CHW)
# ---------------------------------------------------------

#view version (pointer) / construction version (copy)
img_num = rand(4, 4)

img_gray_copy = Gray.(img_num) # construction
img_num_copy = Float64.(img_gray_copy) # construction

img_gray_view = colorview(Gray, img_num) # view
img_num_view = channelview(img_gray_view) # view

# intensity values 0=black,1=white 
# 8 bit (0-255) encoding in N0f8
img_n0f8 = rand(N0f8, 2, 2)

# lazy conversion auto select float type
img_n0f8_float = float.(img_n0f8)

# raw value view
img_n0f8_raw = rawview(img_n0f8)
float.(img_n0f8_raw)

#Conversions between the storage type without changing the color type 
img = rand(Gray{N0f8}, 2, 2)
display("text/plain",img)

img_float32 = float32.(img)
display("text/plain",img_float32)

img_n0f16 = n0f16.(img_float32)
display("text/plain",img_n0f16)

#with no specify the destination type : use float.()
img_n0f8 = rand(Gray{N0f8}, 2, 2)
img_float = float.(img_n0f8)

# conversion without new memory allocation : using MapedArrays
# of_eltype()
using MappedArrays

img_float_view = of_eltype(Gray{Float32}, img_n0f8)
display("text/plain",img_float_view)

# element type
eltype(img_float_view)

# using ImageSegmentation
