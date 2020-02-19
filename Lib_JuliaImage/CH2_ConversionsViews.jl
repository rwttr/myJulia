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
# Gray.() <-> real.()
# array of consecutive numbers: collect(range)
a = reshape(collect(0.1:0.1:0.6), 3, 2)
# create RGB object
c = [RGB(a[1,j], a[2,j], a[3,j]) for j = 1:2]
# obtain color values from RGB objects in c
x = [getfield(c[j], i) for i = 1:3, j = 1:2]
