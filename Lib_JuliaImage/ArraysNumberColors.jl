# array of Numbers

img = rand(2,2) # Float64
a = [1,2,3,4]   # Int64

# conversion Int64 to Float64
convert(Array{Float64}, a)
map(Float64, a)
Float64.(a) #broadcasting

# Numbers vs Colors
using Colors

# Gray Wrapper
imgg = Gray.(img)
display("text/plain",imgg)

# dump shows the "internal" representation of an object
dump(imgg[1,1])

# obtain Gray Object's value by 
imgg[1,1].val # val field, not recommended
real(imgg[1,1]) # real()
gray(imgg[1,1]) # gray()

#Gray "wrapper" is an interpretation of the values, 
#img and imgg compare as equal
img == imgg

# Color Wrapper
imgc = rand(RGB{Float32},2,2)
display("text/plain",imgc)

# object RGB has 3 fields
dump(imgc[1,1])

c = imgc[1,1]; 
# accssing  r g b fields by red(), green(), blue()
(red(c), green(c), blue(c))
