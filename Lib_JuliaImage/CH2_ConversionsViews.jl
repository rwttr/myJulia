# Sharing memory : Introduction to Views
a = [1,2,3,4]
b = Int.(a) # copy of a

a == b #test for size and vals equivalent
a === b #test for memory
b[1]=5 # change in b, a doesn't change


a = [1,2,3]
b = a # a and b are same object (same memory)

# view object (distinct object, same value)
# but share same memory
# ---------------------------------------
v = view(a, :) #change in v affect a
r = reshape(1:15, 3, 5)
r = reshape(a,1,:) # reshape also return view of a
r[1] = 7

# View for fixed-point and raw
# ------------------------------------------
using FixedPointNumbers
x = 0.5N0f8
# switch representation : reinterpret()
y =reinterpret(UInt8,x)
reinterpret(N0f8, y)

# apply to array
a = [0.2N0f8, 0.8N0f8]
b = reinterpret.(UInt8,a)
# a,b not share memory because boardcasting

# view version : rawview()
using Images
v = rawview(a)
v[2] = 0xff
# change in v affect a

c = [0x11, 0x22]
normedview(c) # normedview(N0f8, c)

# View for converting numbers and colors
# --------------------------------------------
# Gray.() <-> real.()
# Always create new copy of data
# array of consecutive numbers: collect(range)
a = reshape(collect(0.1:0.1:0.6), 3, 2)
# create RGB object
c = [RGB(a[1,j], a[2,j], a[3,j]) for j = 1:2]
# obtain color values from RGB objects in c
x = [getfield(c[j], i) for i = 1:3, j = 1:2]

# colorview(), channelview()
# always return a view of the original array
colv = colorview(RGB,a)
display("text/plain",colv)

chanv = channelview(c)

# Example
using Colors, Images
r = range(0,stop=1,length=11)
b = range(0,stop=1,length=11)
img1d = colorview(RGB, r, zeroarray, b)
# expand zeros : zeroarray constant
display("text/plain",img1d)

# Changing the order of dimensions
# -------------------------------------------

# permutedims()
# new copy of data with rearranged the origial
pc = permutedims(a, (2,1))

# PermutedDimsArray()
# view version of permutedims : PermutedDimsArray()
pv = PermutedDimsArray(a, (2,1))
#suitable for accessing 3-channel pixel

# Adding padding
a1=reshape([1,2],2,1)
a2 = [1.0,2.0]'

# Padd arrays to have common size
# array view : paddedviews()
a1p, a2p = paddedviews(0, a1, a2); # 0 is fill value

# StackViews 
# Combines Multiple images into a single view
# ---------------------------------------------------
img1 = reshape(1:8, (2,4))
img2 = reshape(11:18, (2,4))
sv = StackedView(img1, img2)
imgMatrix = reshape(sv, (2, 8))
imgMatrix = reshape(sv, (2, :))

# However
# if share memory is a problem : uses copy